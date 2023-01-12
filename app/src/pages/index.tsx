import { type NextPage } from "next";
import Head from "next/head";
import Link from "next/link";
import { prisma } from "../server/db/client";
import {type t_portfolios } from "@prisma/client";
import { Box, Card, CardActions, CardContent,  Stack, Typography, useTheme } from "@mui/material";
import { createAvatar } from '@dicebear/avatars'
import * as style from '@dicebear/avatars-bottts-sprites'

export const getServerSideProps = async () => {
  const portfolios = await prisma.t_portfolios.findMany({})
  return ({
    props: {
      portfolios
    }
  })
}

const Home: NextPage<{ portfolios: t_portfolios[] }> = (props) => {
  const theme = useTheme()
  return (
    <>
      <Head>
        <title>W@tch IT</title>
        <meta name="description" content="W@tch IT Riskmanagement Suit" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Stack direction="row" justifyContent={"center"}>

        <Card sx={{ padding: 8, gap: 4, grow: 0, display: "flex", flexDirection: "column", alignItems: "center" }}>
          <Typography variant="h4" sx={{ textAlign: "center" }}>Choose a portfolio</Typography>
          <Box sx={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: 4
          }}>
            {props.portfolios.map((portfolio) => (
              <Link style={{ color: "inherit", textDecoration: "none" }}
                href={`/portfolio/${portfolio.id}`}
                key={portfolio.id}>
                <Card
                  sx={{
                    backgroundColor: theme.palette.primary.main,
                    color: theme.palette.common.white,
                    cursor: "pointer",
                    transition: "all 0.2s ease-in-out",
                    "&:hover": {
                      boxShadow: theme.shadows[24],
                      transform: "scale(1.1)"
                    }
                  }}>
                  <CardContent sx={{ display: "grid", justifyContent: "center", alignItems: "center" }}>
                    <div style={{ height: 120, width: 120 }}
                      dangerouslySetInnerHTML={{ __html: createAvatar(style, { seed: portfolio.name }) }}></div>
                  </CardContent>
                  <CardActions sx={{ display: "grid", justifyContent: "center", alignItems: "center" }}>
                    <Typography>
                      {portfolio.name}
                    </Typography>
                  </CardActions>
                </Card>
              </Link>
            ))}
          </Box>
        </Card>
      </Stack>
    </>
  );
};

export default Home;
