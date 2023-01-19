import { type GetServerSideProps, type NextPage } from "next"
import Head from "next/head"
import { prisma } from "../../server/db/client"
import type { t_backtesting_results, t_portfolios, t_prices, t_snapshots, t_stocks, t_var_limit_results } from "@prisma/client"
import { Box, Card, Grid, IconButton, Stack, TextField, Typography, useTheme } from "@mui/material"
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline'
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline'
import AddIcon from '@mui/icons-material/Add'
import RemoveIcon from '@mui/icons-material/Remove'
import CloseIcon from '@mui/icons-material/Close'
import {
    ArcElement,
    ChartData,
    DoughnutController
} from 'chart.js';
import {
    Chart as ChartJS,
    LinearScale,
    TimeScale,
    BarElement,
    PointElement,
    LineElement,
    Legend,
    Tooltip,
    LineController,
    BarController,
    ScatterController,
    PieController
} from 'chart.js'
import { Chart } from 'react-chartjs-2'

import 'chartjs-adapter-date-fns'
import { enUS } from 'date-fns/locale'
import { DatePicker } from "@mui/x-date-pickers";

import { createAvatar } from '@dicebear/avatars'
import * as style from '@dicebear/avatars-bottts-sprites'

export const getServerSideProps: GetServerSideProps = async (context) => {
    // portfolio
    const portfolio = await prisma.t_portfolios.findFirst({ where: { id: Number(context.query.id) } })

    //  var limit
    const varLimits = await prisma.t_var_limit_results.findMany({
        where: { portfolio_id: Number(context.query.id) },
        orderBy: { date: "desc" },
        take: 1
    })
    const varLimit = {
        ...varLimits[0],
        value: varLimits[0]!.value.toNumber(),
        date: varLimits[0]!.date.toISOString()
    }

    //  backtesting data
    const backtestingData = await prisma.t_backtesting_results.findMany({
        where: { portfolio_id: Number(context.query.id) },
        orderBy: { date: "desc" },
        take: 250
    })
    //  order backtgsting data by date asceding
    backtestingData.reverse()
    const backtestingDataFormatted = backtestingData.map((data) => ({
        ...data,
        value: data.value.toNumber(),
        dailyreturns: data.dailyreturns.toNumber(),
        date: data.date.toISOString()
    }))

    // prices
    const prices = await prisma.t_prices.findMany({})
    const pricesFormatted = prices.map((data) => ({
        isin: data.isin,
        date: data.date.toISOString(),
        close: data.close.toNumber()
    }))

    // portfolio snapshots
    const snapshots = await prisma.t_snapshots.findMany({
        where: {
            portfolio_id: Number(context.query.id)
        }
    })
    const snapshotsFormatted = snapshots.map((data) => ({
        ...data,
        date: data.date.toISOString(),
        close: prices.find((price) => (price.isin === data.isin && price.date.toISOString() === data.date.toISOString()))?.close.toNumber()
    }))

    // available stocks
    const availableStocks = await prisma.t_stocks.findMany({})



    return ({
        props: {
            portfolio,
            varLimit,
            backtestingData: backtestingDataFormatted,
            snapshots: snapshotsFormatted,
            availableStocks,
            prices: pricesFormatted
        }
    })
}

type IVarLimitResult = Omit<t_var_limit_results, "value" | "date"> & { value: number, date: string }
type IBacktestingData = Omit<t_backtesting_results, "value" | "date"> & { value: number, date: string, dailyreturns: number }
type IPrices = Omit<t_prices, "date" | "close" | "dailyreturns"> & { date: string, close: number }
type ISnapshots = Omit<t_snapshots, "date"> & { date: string, close: number }

ChartJS.register(
    LinearScale,
    TimeScale,
    BarElement,
    PointElement,
    LineElement,
    Legend,
    Tooltip,
    LineController,
    ScatterController,
    BarController,
    PieController,
    DoughnutController,
    ArcElement
);

const currencyFormatter = new Intl.NumberFormat('en-US', {
    style: "currency",
    currency: "EUR",
})

const Portfolio: NextPage<{
    portfolio: t_portfolios,
    varLimit: IVarLimitResult,
    backtestingData: IBacktestingData[],
    snapshots: ISnapshots[],
    availableStocks: t_stocks[],
    prices: IPrices[]
}> = (props) => {

    const theme = useTheme()

    const backtestingData: ChartData = {
        labels: props.backtestingData.map((data) => new Date(data.date)),

        datasets: [
            {
                label: 'VaR',
                data: props.backtestingData.map((data) => data.value),
                fill: false,
                borderColor: theme.palette.error.main,
                backgroundColor: theme.palette.error.main,
                radius: 1,
                hoverRadius: 6
            },
            {
                label: "Returns",
                data: props.backtestingData.map((data) => data.dailyreturns),
                pointBorderColor: theme.palette.primary.main,
                pointBackgroundColor: theme.palette.primary.main,
                type: "scatter",
                pointRadius: 2,
                pointHoverRadius: 6
            }
        ]
    }

    const snapshotData: ChartData = {
        labels: [...new Set(props.snapshots.map((data) => data.date))]
            .map((date) => new Date(date)),

        datasets: (props.availableStocks.map((stock) => ({
            label: stock.name,
            data: props.snapshots
                .filter((data) => data.isin === stock.isin)
                .map((data) => data.amount * data.close),
            backgroundColor: stock.name === "Deutsche Bank" ? theme.palette.primary.main : theme.palette.secondary.main,
        })))
    }

    const getPortfolioValue = () => {
        if (props.snapshots.length === 0) return 0
        const lastDate = props.snapshots[props.snapshots.length - 1]!.date
        const value = props.snapshots
            .filter((data) => data.date === lastDate)
            .reduce((acc, data) => acc + data.amount * data.close, 0)
        return value
    }

    const getLastPrice = (isin: string) => {
        if (props.snapshots.length === 0) return 0
        const lastDate = props.snapshots[props.snapshots.length - 1]!.date

        const price = props.prices
            .filter(price => price.date === lastDate)
            .find((price) => price.isin === isin)

        return price?.close
    }

    const getCurrentComposition = (): any[] | null => {
        if (props.snapshots.length === 0) return null
        const lastDate = props.snapshots[props.snapshots.length - 1]!.date

        const lastDateData = props.snapshots
            .filter((data) => data.date === lastDate)

        const composition = lastDateData
            .map((data) => ({
                name: props.availableStocks.find((stock) => stock.isin === data.isin)?.name,
                amount: data.amount,
                price: getLastPrice(data.isin),
                value: data.amount * (getLastPrice(data.isin) || 0)
            }))
        return composition
    }

    const portfolioComposition: ChartData = {
        labels: props.availableStocks.map((stock) => stock.name),

        datasets: [{
            label: "Portfolio Composition",
            data: getCurrentComposition()!.map((data) => data.value)!,
            backgroundColor: props.availableStocks.map((stock) => stock.name === "Deutsche Bank" ? theme.palette.primary.main : theme.palette.secondary.main),
        }]
    }

    return (
        <>
            <Head>
                <title>{props.portfolio.name}</title>
                <meta name="description" content="W@tch IT Riskmanagement Suit" />
                <link rel="icon" href="/favicon.ico" />
            </Head>

            <Grid container spacing={4} alignItems="stretch">
                <Grid item xs={12} sx={{ display: "flex", flexDirection: "row", alignItems: "end", gap: 1 }}>
                    <div style={{ height: 60, width: 60 }}
                        dangerouslySetInnerHTML={{ __html: createAvatar(style, { seed: props.portfolio.name }) }}></div>
                    <Typography color="primary" variant="h4" flexGrow={1}>{props.portfolio.name}</Typography>

                    {/* BACK BUTTON */}
                    <IconButton title="Back to Home" href="/">
                        <CloseIcon color="error" fontSize="large" />
                    </IconButton>
                </Grid>

                {/* GRAPH */}
                <Grid item md={8} sm={12} xs={12}>
                    <Card sx={{ padding: 4, height: "100%", boxSizing: "border-box" }}>
                        <Typography sx={{
                            borderBottom: "solid",
                            borderBottomColor: theme.palette.primary.main,
                            borderBottomWidth: 3,
                            marginBottom: 2
                        }} variant="h2">Backtesting</Typography>
                        <Chart options={{
                            indexAxis: "x",
                            scales: {
                                x: {
                                    type: "time",
                                    adapters: {
                                        date: {
                                            locale: enUS
                                        }
                                    }
                                },
                                y: {
                                    ticks: {
                                        callback: (tickValue: string | number) => ((Number(tickValue) * 100).toFixed(2) + "%")
                                    }
                                }
                            }
                        }} type="line" data={backtestingData} />
                    </Card>
                </Grid>

                {/* LIMIT INDICATOR */}
                <Grid item md={4} sm={12} xs={12}>
                    <Card sx={{ padding: 4, height: "100%", boxSizing: "border-box" }}>
                        <Typography sx={{
                            borderBottom: "solid",
                            borderBottomColor: theme.palette.primary.main,
                            borderBottomWidth: 3,
                            marginBottom: 2
                        }} variant="h2">Info</Typography>

                        {/* NAV */}
                        <Stack direction="row" spacing={1}>
                            <Typography variant="body1">NAV:</Typography>
                            <Typography variant="body1" fontWeight={"bold"}>{currencyFormatter.format(getPortfolioValue())}</Typography>
                        </Stack>

                        {/* OVERSHOOTS */}
                        <Stack direction="row" spacing={1}>
                            <Typography variant="body1">Overshoots:</Typography>
                            <Typography variant="body1" fontWeight={"bold"}>{props.backtestingData.filter(data => data.dailyreturns < data.value).length}</Typography>
                        </Stack>

                        {/* VALUE AT RISK */}
                        <Stack direction="row" spacing={1} sx={{ marginTop: 4 }}>
                            <Typography variant="body1">V@R (1d):</Typography>
                            <Typography variant="body1" fontWeight={"bold"}>{(Math.abs(props.varLimit.value / Math.sqrt(20)) * 100).toFixed(2)}%</Typography>
                        </Stack>
                        <Stack direction="row" spacing={1}>
                            <Typography variant="body1">V@R (20d):</Typography>
                            <Typography variant="body1" fontWeight={"bold"}>{(Math.abs(props.varLimit.value) * 100).toFixed(2)}%</Typography>
                        </Stack>

                        <Box sx={{ marginTop: 4, fontSize: theme.typography.h1.fontSize, display: "flex", flexDirection: "column", alignItems: "center" }}>
                            {Math.abs(props.varLimit.value) > 0.2 ?
                                <>
                                    <ErrorOutlineIcon fontSize="inherit" color="error" />
                                    <Typography fontWeight="bold" sx={{ color: theme.palette.error.main }}>Violation!</Typography>
                                    <Typography sx={{ color: theme.palette.error.main, textAlign: "center" }}>VaR for next 20 days is greater than 20%!</Typography>
                                </>
                                :
                                <>
                                    <CheckCircleOutlineIcon fontSize="inherit" color="success" />
                                    <Typography fontWeight="bold" sx={{ color: theme.palette.success.main }}>No Violation!</Typography>

                                </>

                            }
                        </Box>


                    </Card>
                </Grid>

                {/* PORTFOLIO SNAPSHOTS */}
                <Grid item md={8} sm={12} xs={12}>
                    <Card sx={{ padding: 4, height: "100%", boxSizing: "border-box" }}>
                        <Typography sx={{
                            borderBottom: "solid",
                            borderBottomColor: theme.palette.primary.main,
                            borderBottomWidth: 3,
                            marginBottom: 2
                        }} variant="h2">Portfolio Value</Typography>

                        {/* GRAPH */}
                        <Chart options={{
                            indexAxis: "x",
                            responsive: true,
                            interaction: {
                                intersect: false
                            },
                            scales: {
                                x: {
                                    type: "time",
                                    adapters: {
                                        date: {
                                            locale: enUS
                                        }
                                    },
                                    stacked: true
                                },
                                y: {
                                    stacked: true,
                                    ticks: {
                                        callback: (tickValue: string | number) => (currencyFormatter.format(Number(tickValue)))
                                    }
                                },

                            }
                        }} type="bar" data={snapshotData} />
                    </Card>
                </Grid>


                {/* CURRENT COMPOSITION */}
                <Grid item md={4} sm={12} xs={12}>
                    <Card sx={{ padding: 4, height: "100%", boxSizing: "border-box" }}>
                        <Typography sx={{
                            borderBottom: "solid",
                            borderBottomColor: theme.palette.primary.main,
                            borderBottomWidth: 3,
                            marginBottom: 2
                        }} variant="h2">Portfolio Composition</Typography>

                        {/* GRAPH */}
                        <Chart type="doughnut" options={{ responsive: true }} data={portfolioComposition} />
                    </Card>
                </Grid>

                {/* TRADE BOOKING */}
                <Grid item xs={12}>
                    <Card sx={{ padding: 4, height: "100%", boxSizing: "border-box" }}>
                        <Typography sx={{
                            borderBottom: "solid",
                            borderBottomColor: theme.palette.primary.main,
                            borderBottomWidth: 3,
                            marginBottom: 2
                        }} variant="h2">Book Trades</Typography>
                        <Stack direction="column" spacing={2}>
                            {props.availableStocks.map(stock => (
                                <Stack key={stock.isin} direction="row" alignItems="center" spacing={1}>
                                    <Typography sx={{ flexGrow: 1 }} variant="body1" title={stock.isin}>{stock.name} @ {currencyFormatter.format(getLastPrice(stock.isin)!)}</Typography>
                                    <TextField sx={{}} size="small" type="number" label="Amount" variant="standard" />
                                    <DatePicker label="Date" renderInput={(params) => <TextField {...params} size="small" variant="standard" />} value={null} onChange={() => null} />
                                    <IconButton color="success" size="small">
                                        <AddIcon />
                                    </IconButton>
                                    <IconButton color="error" size="small">
                                        <RemoveIcon />
                                    </IconButton>
                                </Stack>
                            ))
                            }
                        </Stack>
                    </Card>
                </Grid>
            </Grid>
        </>
    );
};

export default Portfolio;
