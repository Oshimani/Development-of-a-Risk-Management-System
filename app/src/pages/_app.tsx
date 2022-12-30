import { Container, Stack, ThemeProvider, Typography, createTheme } from "@mui/material";
import { type AppType } from "next/dist/shared/lib/utils";
import SecurityIcon from '@mui/icons-material/Security';

const MyApp: AppType = ({ Component, pageProps }) => {
  const theme = createTheme({
typography:{
  body1:{
    fontSize: "1.5rem"
  }
}
  })

  return (
    <ThemeProvider theme={theme}>

      <Container>
        <Stack spacing={4} direction="row">
          <SecurityIcon sx={{ fontSize: theme.typography.h1.fontSize }} />
          <Typography variant="h1">Riskmanagement</Typography>
        </Stack>
        <Component {...pageProps} />
      </Container>
    </ThemeProvider>
  )
};

export default MyApp;
