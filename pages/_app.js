import '../styles/globals.css'
import Head from 'next/head'
import { Layout } from '../components/layout/Layout'
import { AppProvider } from '../context/AppContext'

function MyApp({ Component, pageProps }) {
  return (
    <>
      <Head>
        <title>Enterprise NAC TCO & ROI Calculator</title>
        <meta name="description" content="Compare the TCO and ROI of Portnox Cloud vs traditional NAC solutions" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <AppProvider>
        <Layout>
          <Component {...pageProps} />
        </Layout>
      </AppProvider>
    </>
  )
}

export default MyApp
