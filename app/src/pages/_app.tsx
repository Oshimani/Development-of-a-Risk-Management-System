import { Container, Stack, ThemeProvider, Typography, createTheme } from "@mui/material";
import { type AppType } from "next/dist/shared/lib/utils";
import InsightsIcon from '@mui/icons-material/Insights';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { LocalizationProvider } from "@mui/x-date-pickers";

import '../styles/global.css'
import Link from "next/link";

const MyApp: AppType = ({ Component, pageProps }) => {
  const theme = createTheme({
    typography: {
      h1: {
        fontSize: "4rem"
      },
      h2: {
        fontSize: "2rem"
      },
      h3: {
        fontSize: "1.5rem"
      },
      body1: {
        fontSize: "1.2rem"
      }
    }
  })

  return (
    <ThemeProvider theme={theme}>
      <LocalizationProvider dateAdapter={AdapterDateFns}>
        <Container>

          {/* HEADER */}
          <Stack spacing={4} mb={8} direction="row" justifyContent={"center"}>
            <Link title="Back to Home" style={{ color: "inherit", textDecoration: "none" }} href="/">
              <Stack spacing={1} direction="column" alignItems="center">
                <InsightsIcon color="primary" sx={{ fontSize: theme.typography.h1.fontSize }} />
                <Typography sx={{ textDecoration: "none" }}
                  // color={theme.palette.common.black}
                  variant="h1">Risky Business</Typography>
                <Typography variant="h3"
                  color={theme.palette.primary.main}
                  fontWeight={theme.typography.fontWeightLight}>Riskmanagement suit</Typography>
              </Stack>
            </Link>
          </Stack>

          {/* CONTENT */}
          <Component {...pageProps} />

        </Container>
      </LocalizationProvider>
    </ThemeProvider>
  )
};

export default MyApp;
