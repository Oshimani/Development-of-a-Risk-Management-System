import { Container, Stack, ThemeProvider, createTheme } from "@mui/material";
import { type AppType } from "next/dist/shared/lib/utils";
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { LocalizationProvider } from "@mui/x-date-pickers";

import '../styles/global.css'
import Link from "next/link";

import Logo from "../components/logo";

const MyApp: AppType = ({ Component, pageProps }) => {
  const theme = createTheme({
    palette: {
      primary: {
        main: "hsl(185, 83%, 41%)"
      },
      secondary: {
        main: "hsl(313, 91%, 44%)"
      }
    },
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
    },
    components: {
      MuiCard: {
        styleOverrides: {
          root: {
            backgroundColor: "hsl(240, 19%, 75%)"
          }
        }
      }
    }
  })

  return (
    <ThemeProvider theme={theme}>
      <LocalizationProvider dateAdapter={AdapterDateFns}>
        <Container>

          {/* HEADER */}
          {Component.name === "Home" &&
            <Stack spacing={4} mb={8} direction="row" justifyContent={"center"}>
              <Link title="Back to Home" style={{ color: "inherit", textDecoration: "none" }} href="/">
                <Stack spacing={1} direction="column" alignItems="center">
                  <Logo />
                </Stack>
              </Link>
            </Stack>
          }

          {/* CONTENT */}
          <Component {...pageProps} />

        </Container>
      </LocalizationProvider>
    </ThemeProvider>
  )
};

export default MyApp;
