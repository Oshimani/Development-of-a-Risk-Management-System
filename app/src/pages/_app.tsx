import { Container, Stack, ThemeProvider, Typography, createTheme } from "@mui/material";
import { type AppType } from "next/dist/shared/lib/utils";
import InsightsIcon from '@mui/icons-material/Insights';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { LocalizationProvider } from "@mui/x-date-pickers";

import '../styles/global.css'

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
          <Stack spacing={4} direction="row" justifyContent={"center"}>
            <Stack spacing={1} direction="column" alignItems="center">
              <InsightsIcon color="primary" sx={{ fontSize: theme.typography.h1.fontSize }} />
              <Typography variant="h1">Risky Business</Typography>
              <Typography variant="h3"
                color={theme.palette.primary.main}
                fontWeight={theme.typography.fontWeightLight}>Riskmanagement suit</Typography>
            </Stack>
          </Stack>

          <Component {...pageProps} />

        </Container>
      </LocalizationProvider>
    </ThemeProvider>
  )
};

export default MyApp;
