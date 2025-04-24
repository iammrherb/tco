/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['www.portnox.com', 'www.cisco.com', 'www.arubanetworks.com', 'www.forescout.com', 'www.fortinet.com', 'www.securew2.com', 'www.ivanti.com', 'www.microsoft.com'],
    unoptimized: process.env.NODE_ENV !== 'development',
  },
  webpack(config) {
    config.module.rules.push({
      test: /\.svg$/,
      use: ["@svgr/webpack"]
    });
    return config;
  }
}

module.exports = nextConfig
