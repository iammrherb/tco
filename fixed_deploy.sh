#!/bin/bash

# =====================================================
# Enterprise NAC TCO and ROI Comparison Deployment Script
# =====================================================
# This script creates, builds and deploys an enhanced NAC TCO and ROI Comparison app
# with comprehensive vendor analysis, advanced visualization and Git integration

# Color definitions for output styling
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"
RESET="\033[0m"

# Default repository settings - can be changed via command line arguments
DEFAULT_REPO_URL="https://github.com/iammrherb/tco.git"
DEFAULT_REPO_BRANCH="main"
DEFAULT_USER_NAME="iammrherb"
DEFAULT_USER_EMAIL="iammrherb@gmail.com"
REPO_URL=$DEFAULT_REPO_URL
REPO_BRANCH=main
GIT_USER_NAME=iammrherb
GIT_USER_EMAIL=iammrherb@gmail.com

# Function to display styled section headers
display_section() {
  echo -e "\n\${BLUE}=== $1 ===\${RESET}\n"
}

# Function to display success messages
display_success() {
  echo -e "\${GREEN}✓ $1\${RESET}"
}

# Function to display error messages and exit
display_error() {
  echo -e "\${RED}✗ ERROR: $1\${RESET}"
  exit 1
}

# Function to display warnings
display_warning() {
  echo -e "\${YELLOW}⚠ WARNING: $1\${RESET}"
}

# Function to display info messages
display_info() {
  echo -e "\${CYAN}ℹ $1\${RESET}"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
  display_section "Checking Prerequisites"
  
  # Check for Git
  if ! command_exists git; then
    display_error "Git is not installed. Please install Git and try again."
  else
    GIT_VERSION=$(git --version | awk '{print $3}')
    display_success "Git is installed (v$GIT_VERSION)"
  fi
  
  # Check for Node.js
  if ! command_exists node; then
    display_error "Node.js is not installed. Please install Node.js (v16+ recommended) and try again."
  else
    NODE_VERSION=$(node -v | cut -d 'v' -f 2)
    display_success "Node.js is installed (v$NODE_VERSION)"
    
    # Warn if Node.js version is below 16
    if [[ $(echo "$NODE_VERSION" | cut -d '.' -f 1) -lt 16 ]]; then
      display_warning "Node.js version is below 16. Some features may not work correctly."
    fi
  fi
  
  # Check for npm
  if ! command_exists npm; then
    display_error "npm is not installed. Please install npm and try again."
  else
    NPM_VERSION=$(npm -v)
    display_success "npm is installed (v$NPM_VERSION)"
  fi
  
  # Check for yarn (optional)
  if command_exists yarn; then
    YARN_VERSION=$(yarn -v)
    display_success "Yarn is installed (v$YARN_VERSION)"
    USE_YARN=true
  else
    display_warning "Yarn is not installed. Will use npm instead."
    USE_YARN=false
  fi
}

# Function to create a new GitHub repository
create_github_repository() {
  display_section "Creating GitHub Repository"
  
  if ! command_exists gh; then
    display_warning "GitHub CLI (gh) is not installed. Cannot create repository automatically."
    display_info "You can manually create a repository at https://github.com/new"
    display_info "Then set the remote with: git remote add origin YOUR_REPO_URL"
    return 1
  fi
  
  # Check if logged in
  if ! gh auth status &>/dev/null; then
    display_warning "You are not logged in to GitHub CLI. Please log in:"
    gh auth login || display_error "Failed to log in to GitHub"
  fi
  
  # Extract repo name from URL
  REPO_NAME=$(basename -s .git "$REPO_URL")
  
  # Create new repository
  echo "Creating new GitHub repository: $REPO_NAME"
  if gh repo create "$REPO_NAME" --private --confirm; then
    display_success "Created GitHub repository: $REPO_NAME"
    REPO_URL="https://github.com/$(gh api user | jq -r .login)/$REPO_NAME.git"
    echo "Repository URL: $REPO_URL"
    return 0
  else
    display_warning "Failed to create GitHub repository. Will try to use existing repository."
    return 1
  fi
}

# Function to set up Git repository
setup_git_repository() {
  display_section "Setting Up Git Repository"
  
  REPO_DIR="nac-tco-calculator"
  
  # Create directory if it doesn't exist
  if [ ! -d "$REPO_DIR" ]; then
    echo "Creating project directory: $REPO_DIR"
    mkdir -p "$REPO_DIR"
  fi
  
  cd "$REPO_DIR" || display_error "Failed to enter repository directory"
  
  # Initialize Git repository if not already initialized
  if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    
    # Configure Git user
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    
    display_success "Git repository initialized with user: $GIT_USER_NAME <$GIT_USER_EMAIL>"
  else
    echo "Git repository already initialized"
    
    # Update Git user if different
    CURRENT_NAME=$(git config user.name)
    CURRENT_EMAIL=$(git config user.email)
    
    if [ "$CURRENT_NAME" != "$GIT_USER_NAME" ] || [ "$CURRENT_EMAIL" != "$GIT_USER_EMAIL" ]; then
      git config user.name "$GIT_USER_NAME"
      git config user.email "$GIT_USER_EMAIL"
      display_success "Updated Git user to: $GIT_USER_NAME <$GIT_USER_EMAIL>"
    else
      display_success "Git user already set correctly"
    fi
  fi
  
  # Check if the remote exists
  if ! git remote | grep -q "origin"; then
    echo "Adding remote origin: $REPO_URL"
    git remote add origin "$REPO_URL"
    display_success "Remote origin added"
  else
    # Update remote URL if it's different
    CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
    if [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
      echo "Updating remote origin to: $REPO_URL"
      git remote set-url origin "$REPO_URL"
      display_success "Remote origin updated"
    else
      display_success "Remote origin already set correctly"
    fi
  fi
  
  # Create .gitignore
  if [ ! -f ".gitignore" ]; then
    cat > .gitignore << EOL
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# local env files
.env*.local

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts
EOL
    display_success "Created .gitignore file"
  fi
}

# Function to create project structure
create_project_structure() {
  display_section "Creating Project Structure"
  
  # Create base directory structure
  mkdir -p {pages/{api,calculator,vendors,comparison},public/images/vendors,styles,components/{ui,charts,layout,calculator,vendors,comparison},lib/{utils,hooks,data,api},context}
  
  display_success "Directory structure created"
}

# Function to install dependencies
install_dependencies() {
  display_section "Installing Dependencies"
  
  # Create package.json if it doesn't exist
  if [ ! -f package.json ]; then
    echo "Creating package.json..."
    cat > package.json << EOL
{
  "name": "nac-tco-calculator",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "export": "next build && next export",
    "deploy": "gh-pages -d out"
  }
}
EOL
    display_success "Created package.json"
  else
    display_success "Using existing package.json"
  fi
  
  # Install core dependencies
  echo "Installing core dependencies..."
  if [ "$USE_YARN" = true ]; then
    yarn add next react react-dom
  else
    npm install next react react-dom
  fi
  
  # Install UI and styling libraries
  echo "Installing UI and styling libraries..."
  if [ "$USE_YARN" = true ]; then
    yarn add tailwindcss postcss autoprefixer @headlessui/react @heroicons/react
  else
    npm install tailwindcss postcss autoprefixer @headlessui/react @heroicons/react
  fi
  
  # Install data visualization libraries
  echo "Installing data visualization libraries..."
  if [ "$USE_YARN" = true ]; then
    yarn add recharts d3 framer-motion react-chartjs-2 chart.js
    yarn add echarts echarts-for-react @nivo/core @nivo/line @nivo/pie @nivo/bar @nivo/radar plotly.js react-plotly.js
  else
    npm install recharts d3 framer-motion react-chartjs-2 chart.js
    npm install echarts echarts-for-react visx plotly.js react-plotly.js
  fi
  
  # Install form and data handling libraries
  echo "Installing form and data handling libraries..."
  if [ "$USE_YARN" = true ]; then
    yarn add react-hook-form yup @hookform/resolvers zod
    yarn add swr axios jotai react-query
  else
    npm install react-hook-form yup @hookform/resolvers zod
    npm install swr axios jotai react-query
  fi
  
  # Install utility libraries
  echo "Installing utility libraries..."
  if [ "$USE_YARN" = true ]; then
    yarn add lodash date-fns uuid nanoid
    yarn add react-pdf jspdf html2canvas file-saver
  else
    npm install lodash date-fns uuid nanoid
    npm install react-pdf jspdf html2canvas file-saver
  fi
  
  # Install development dependencies
  echo "Installing development dependencies..."
  if [ "$USE_YARN" = true ]; then
    yarn add -D eslint eslint-config-next typescript @types/react @types/node
    yarn add -D prettier eslint-plugin-prettier eslint-config-prettier
    yarn add -D gh-pages
  else
    npm install -D eslint eslint-config-next typescript @types/react @types/node
    npm install -D prettier eslint-plugin-prettier eslint-config-prettier
    npm install -D gh-pages
  fi
  
  display_success "Dependencies installed successfully"
}

# Function to create configuration files
create_config_files() {
  display_section "Creating Configuration Files"
  
  # Create Next.js configuration
  cat > next.config.js << EOL
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
EOL
  display_success "Created Next.js configuration"
  
  # Create Tailwind configuration
  cat > tailwind.config.js << EOL
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        'portnox-primary': '#2bd25b',    // Portnox Green
        'portnox-dark': '#0f432e',       // Portnox Dark Green
        'portnox-light': '#e6f7eb',      // Portnox Light Green
        'cisco-blue': '#049fd9',         // Cisco Blue
        'cisco-dark': '#005073',         // Cisco Dark Blue
        'aruba-orange': '#ff8300',       // Aruba Orange
        'aruba-dark': '#c05f00',         // Aruba Dark Orange
        'forescout-blue': '#005daa',     // Forescout Blue
        'forescout-dark': '#003c6e',     // Forescout Dark Blue
        'fortinet-red': '#ee3124',       // Fortinet Red
        'fortinet-dark': '#b8291e',      // Fortinet Dark Red
        'securew2-blue': '#0072bc',      // SecureW2 Blue
        'securew2-dark': '#00568d',      // SecureW2 Dark Blue
        'ivanti-purple': '#6f2c91',      // Ivanti Purple
        'ivanti-dark': '#4b1e61',        // Ivanti Dark Purple
        'microsoft-blue': '#0078d4',     // Microsoft Blue
        'microsoft-dark': '#005a9e',     // Microsoft Dark Blue
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        mono: ['Roboto Mono', 'ui-monospace', 'monospace'],
      },
      boxShadow: {
        'card': '0 4px 12px rgba(0, 0, 0, 0.05)',
        'card-hover': '0 8px 24px rgba(0, 0, 0, 0.1)',
        'tooltip': '0 2px 15px rgba(0, 0, 0, 0.1)',
      },
      borderRadius: {
        'xl': '1rem',
        '2xl': '1.5rem',
        '3xl': '2rem',
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'bounce-slow': 'bounce 2s infinite',
      },
      keyframes: {
        shimmer: {
          '100%': { transform: 'translateX(100%)' },
        },
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
EOL
  display_success "Created Tailwind configuration"
  
  # Create PostCSS configuration
  cat > postcss.config.js << EOL
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOL
  display_success "Created PostCSS configuration"
  
  # Create TypeScript configuration
  cat > tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"],
      "@components/*": ["components/*"],
      "@lib/*": ["lib/*"],
      "@styles/*": ["styles/*"],
      "@context/*": ["context/*"],
      "@data/*": ["lib/data/*"],
      "@utils/*": ["lib/utils/*"],
      "@hooks/*": ["lib/hooks/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx"],
  "exclude": ["node_modules"]
}
EOL
  display_success "Created TypeScript configuration"
  
  # Create environment file
  cat > .env.local << EOL
NEXT_PUBLIC_APP_NAME=NAC TCO & ROI Calculator
NEXT_PUBLIC_APP_VERSION=1.0.0
NEXT_PUBLIC_REPOSITORY_URL=\${REPO_URL}
EOL
  display_success "Created environment file"
  
  # Create prettier configuration
  cat > .prettierrc << EOL
{
  "semi": true,
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "trailingComma": "es5",
  "jsxBracketSameLine": false
}
EOL
  display_success "Created prettier configuration"
}

# Function to create base styles
create_styles() {
  display_section "Creating Styles"
  
  # Create globals.css
  cat > styles/globals.css << EOL
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Roboto+Mono:wght@400;500&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
  --background-start-rgb: 245, 247, 250;
  --background-end-rgb: 255, 255, 255;
}

body {
  color: rgb(var(--foreground-rgb));
  background: linear-gradient(
      to bottom,
      transparent,
      rgb(var(--background-end-rgb))
    )
    rgb(var(--background-start-rgb));
  min-height: 100vh;
}

@layer components {
  .btn-primary {
    @apply px-4 py-2 bg-portnox-primary text-white font-medium rounded-lg hover:bg-portnox-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-portnox-dark focus:ring-opacity-50;
  }
  
  .btn-secondary {
    @apply px-4 py-2 bg-gray-200 text-gray-800 font-medium rounded-lg hover:bg-gray-300 transition-colors disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-gray-400 focus:ring-opacity-50;
  }
  
  .btn-outline {
    @apply px-4 py-2 bg-white text-gray-800 font-medium rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-gray-400 focus:ring-opacity-50;
  }
  
  .card {
    @apply bg-white p-6 rounded-xl shadow-card border border-gray-100 transition-shadow hover:shadow-card-hover;
  }
  
  .chart-container {
    @apply bg-white p-4 rounded-lg shadow-sm border border-gray-100;
  }
  
  .form-input {
    @apply w-full rounded-md border-gray-300 shadow-sm focus:border-portnox-primary focus:ring focus:ring-portnox-primary focus:ring-opacity-20;
  }
  
  .form-select {
    @apply w-full rounded-md border-gray-300 shadow-sm focus:border-portnox-primary focus:ring focus:ring-portnox-primary focus:ring-opacity-20;
  }
  
  .form-checkbox {
    @apply rounded border-gray-300 text-portnox-primary focus:ring-portnox-primary;
  }
  
  .tooltip {
    @apply absolute z-10 p-2 text-xs bg-gray-900 text-white rounded shadow-tooltip;
  }
  
  .tab-active {
    @apply border-b-2 border-portnox-primary text-portnox-primary;
  }
  
  .tab-inactive {
    @apply border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300;
  }
}

.vendor-nav-cisco.active {
  @apply border-cisco-blue text-cisco-blue;
}

.vendor-nav-aruba.active {
  @apply border-aruba-orange text-aruba-orange;
}

.vendor-nav-forescout.active {
  @apply border-forescout-blue text-forescout-blue;
}

.vendor-nav-fortinet.active {
  @apply border-fortinet-red text-fortinet-red;
}

.vendor-nav-securew2.active {
  @apply border-securew2-blue text-securew2-blue;
}

.vendor-nav-ivanti.active {
  @apply border-ivanti-purple text-ivanti-purple;
}

.vendor-nav-microsoft.active {
  @apply border-microsoft-blue text-microsoft-blue;
}

.vendor-nav-portnox.active {
  @apply border-portnox-primary text-portnox-primary;
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 10px;
}

::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
  
  .print-only {
    display: block !important;
  }
  
  .card {
    box-shadow: none !important;
    border: 1px solid #e5e7eb !important;
  }
}
EOL
  display_success "Created global styles"
}

# Function to create core data models
create_data_models() {
  display_section "Creating Data Models & Research-Based Defaults"
  
  mkdir -p lib/data
  
  # Create NAC vendors data
  cat > lib/data/vendors.ts << EOL
// Comprehensive data about NAC vendors including research-based default values

export type VendorID = 
  | 'portnox'
  | 'cisco'
  | 'aruba'
  | 'forescout'
  | 'fortinet'
  | 'securew2'
  | 'ivanti'
  | 'microsoft';

export type OrganizationSize = 'small' | 'medium' | 'large' | 'enterprise';

export type NetworkComplexity = 'low' | 'medium' | 'high';

export interface VendorDetails {
  id: VendorID;
  name: string;
  shortName: string;
  description: string;
  productName: string;
  deploymentModels: DeploymentModel[];
  logoUrl: string;
  primaryColor: string;
  secondaryColor: string;
  website: string;
  hasCloudOption: boolean;
  hasOnPremOption: boolean;
  foundedYear: number;
  headquarters: string;
  gartnerRating?: number;
  forresterRating?: number;
  npsScore?: number;
  marketShare?: number;
}

export interface CostFactors {
  initialHardwareCost: number;
  annualMaintenanceCost: number;
  annualLicensingCost: number;
  implementationServicesCost: number;
  trainingCost: number;
  networkRedesignCost: number;
  fteCount: number;
  estimatedAnnualDowntimeHours: number;
}

export interface ImplementationTimeline {
  planningDays: number;
  deploymentDays: number;
  integrationDays: number;
  testingDays: number;
  staffTrainingDays: number;
  rolloutDays: number;
}

export type DeploymentModel = 
  | 'cloud'
  | 'on-premises'
  | 'hybrid'
  | 'saas'
  | 'appliance'
  | 'virtual';

export interface VendorCosts {
  [size in OrganizationSize]: CostFactors;
}

export interface VendorImplementation {
  [size in OrganizationSize]: ImplementationTimeline;
}

export interface FeatureRating {
  value: string;
  score: number;
}

export interface VendorFeatureComparison {
  [feature: string]: {
    [vendor in VendorID]?: FeatureRating;
  };
}

// Size band definitions for number of devices
export const sizeBands = {
  small: { min: 1, max: 500, default: 250 },
  medium: { min: 501, max: 2500, default: 1000 },
  large: { min: 2501, max: 10000, default: 5000 },
  enterprise: { min: 10001, max: 100000, default: 25000 }
};

// Vendor details
export const vendorDetails: Record<VendorID, VendorDetails> = {
  portnox: {
    id: 'portnox',
    name: 'Portnox',
    shortName: 'Portnox',
    description: 'Cloud-native NAC solution with zero-trust approach, simplified deployment and minimal maintenance.',
    productName: 'Portnox Cloud',
    deploymentModels: ['cloud', 'saas'],
    logoUrl: '/images/vendors/portnox-logo.png',
    primaryColor: '#2bd25b',
    secondaryColor: '#0f432e',
    website: 'https://www.portnox.com',
    hasCloudOption: true,
    hasOnPremOption: false,
    foundedYear: 2007,
    headquarters: 'Tel Aviv, Israel',
    gartnerRating: 4.4,
    forresterRating: 4.3,
    npsScore: 75,
    marketShare: 5
  },
  cisco: {
    id: 'cisco',
    name: 'Cisco',
    shortName: 'Cisco',
    description: 'Enterprise-grade on-premises NAC solution with comprehensive feature set and extensive integration options.',
    productName: 'Cisco ISE',
    deploymentModels: ['on-premises', 'appliance', 'virtual'],
    logoUrl: '/images/vendors/cisco-logo.png',
    primaryColor: '#049fd9',
    secondaryColor: '#005073',
    website: 'https://www.cisco.com/c/en/us/products/security/identity-services-engine/index.html',
    hasCloudOption: false,
    hasOnPremOption: true,
    foundedYear: 1984,
    headquarters: 'San Jose, CA, USA',
    gartnerRating: 4.2,
    forresterRating: 4.5,
    npsScore: 58,
    marketShare: 38
  },
  aruba: {
    id: 'aruba',
    name: 'Aruba Networks',
    shortName: 'Aruba',
    description: 'Comprehensive NAC solution with strong integration capabilities for HP Aruba network infrastructure.',
    productName: 'Aruba ClearPass',
    deploymentModels: ['on-premises', 'appliance', 'virtual'],
    logoUrl: '/images/vendors/aruba-logo.png',
    primaryColor: '#ff8300',
    secondaryColor: '#c05f00',
    website: 'https://www.arubanetworks.com/products/security/network-access-control/',
    hasCloudOption: false,
    hasOnPremOption: true,
    foundedYear: 2002,
    headquarters: 'Santa Clara, CA, USA',
    gartnerRating: 4.3,
    forresterRating: 4.2,
    npsScore: 61,
    marketShare: 24
  },
  forescout: {
    id: 'forescout',
    name: 'Forescout',
    shortName: 'Forescout',
    description: 'Agent-less NAC solution with strong IoT and OT device discovery and classification capabilities.',
    productName: 'Forescout Platform',
    deploymentModels: ['on-premises', 'appliance', 'virtual', 'hybrid'],
    logoUrl: '/images/vendors/forescout-logo.png',
    primaryColor: '#005daa',
    secondaryColor: '#003c6e',
    website: 'https://www.forescout.com',
    hasCloudOption: true,
    hasOnPremOption: true,
    foundedYear: 2000,
    headquarters: 'San Jose, CA, USA',
    gartnerRating: 4.3,
    forresterRating: 4.0,
    npsScore: 63,
    marketShare: 14
  },
  fortinet: {
    id: 'fortinet',
    name: 'Fortinet',
    shortName: 'Fortinet',
    description: 'Integrated NAC solution as part of Fortinet security fabric with strong security ecosystem integration.',
    productName: 'FortiNAC',
    deploymentModels: ['on-premises', 'appliance', 'virtual'],
    logoUrl: '/images/vendors/fortinet-logo.png',
    primaryColor: '#ee3124',
    secondaryColor: '#b8291e',
    website: 'https://www.fortinet.com/products/network-access-control/fortinac',
    hasCloudOption: false,
    hasOnPremOption: true,
    foundedYear: 2000,
    headquarters: 'Sunnyvale, CA, USA',
    gartnerRating: 4.1,
    forresterRating: 4.0,
    npsScore: 54,
    marketShare: 7
  },
  securew2: {
    id: 'securew2',
    name: 'SecureW2',
    shortName: 'SecureW2',
    description: 'Cloud-based certificate and identity management solution with BYOD focus.',
    productName: 'SecureW2 JoinNow Suite',
    deploymentModels: ['cloud', 'saas'],
    logoUrl: '/images/vendors/securew2-logo.png',
    primaryColor: '#0072bc',
    secondaryColor: '#00568d',
    website: 'https://www.securew2.com',
    hasCloudOption: true,
    hasOnPremOption: false,
    foundedYear: 2010,
    headquarters: 'Seattle, WA, USA',
    gartnerRating: 3.9,
    forresterRating: 3.8,
    npsScore: 67,
    marketShare: 2
  },
  ivanti: {
    id: 'ivanti',
    name: 'Ivanti',
    shortName: 'Ivanti',
    description: 'Comprehensive network security and access control solution with focus on zero trust.',
    productName: 'Ivanti Policy Secure',
    deploymentModels: ['on-premises', 'appliance', 'virtual', 'cloud', 'hybrid'],
    logoUrl: '/images/vendors/ivanti-logo.png',
    primaryColor: '#6f2c91',
    secondaryColor: '#4b1e61',
    website: 'https://www.ivanti.com/products/policy-secure',
    hasCloudOption: true,
    hasOnPremOption: true,
    foundedYear: 1985,
    headquarters: 'South Jordan, UT, USA',
    gartnerRating: 3.8,
    forresterRating: 3.9,
    npsScore: 52,
    marketShare: 5
  },
  microsoft: {
    id: 'microsoft',
    name: 'Microsoft',
    shortName: 'Microsoft',
    description: 'Windows Server role providing network policy and access services integrated with Active Directory.',
    productName: 'Network Policy Server (NPS)',
    deploymentModels: ['on-premises', 'virtual'],
    logoUrl: '/images/vendors/microsoft-logo.png',
    primaryColor: '#0078d4',
    secondaryColor: '#005a9e',
    website: 'https://learn.microsoft.com/en-us/windows-server/networking/technologies/nps/nps-top',
    hasCloudOption: false,
    hasOnPremOption: true,
    foundedYear: 1975,
    headquarters: 'Redmond, WA, USA',
    gartnerRating: 3.6,
    forresterRating: 3.5,
    npsScore: 45,
    marketShare: 5
  }
};

// Research-based default values for cost factors
export const vendorCosts: Record<VendorID, VendorCosts> = {
  portnox: {
    small: {
      initialHardwareCost: 0,
      annualMaintenanceCost: 5000,
      annualLicensingCost: 25000,
      implementationServicesCost: 5000,
      trainingCost: 2000,
      networkRedesignCost: 2000,
      fteCount: 0.25,
      estimatedAnnualDowntimeHours: 4
    },
    medium: {
      initialHardwareCost: 0,
      annualMaintenanceCost: 7500,
      annualLicensingCost: 60000,
      implementationServicesCost: 10000,
      trainingCost: 4000,
      networkRedesignCost: 4000,
      fteCount: 0.5,
      estimatedAnnualDowntimeHours: 6
    },
    large: {
      initialHardwareCost: 0,
      annualMaintenanceCost: 10000,
      annualLicensingCost: 150000,
      implementationServicesCost: 20000,
      trainingCost: 8000,
      networkRedesignCost: 8000,
      fteCount: 0.75,
      estimatedAnnualDowntimeHours: 8
    },
    enterprise: {
      initialHardwareCost: 0,
      annualMaintenanceCost: 15000,
      annualLicensingCost: 375000,
      implementationServicesCost: 40000,
      trainingCost: 15000,
      networkRedesignCost: 15000,
      fteCount: 1,
      estimatedAnnualDowntimeHours: 12
    }
  },
  cisco: {
    small: {
      initialHardwareCost: 75000,
      annualMaintenanceCost: 25000,
      annualLicensingCost: 40000,
      implementationServicesCost: 35000,
      trainingCost: 10000,
      networkRedesignCost: 15000,
      fteCount: 1,
      estimatedAnnualDowntimeHours: 24
    },
    medium: {
      initialHardwareCost: 150000,
      annualMaintenanceCost: 50000,
      annualLicensingCost: 100000,
      implementationServicesCost: 60000,
      trainingCost: 15000,
      networkRedesignCost: 25000,
      fteCount: 1.5,
      estimatedAnnualDowntimeHours: 36
    },
    large: {
      initialHardwareCost: 300000,
      annualMaintenanceCost: 100000,
      annualLicensingCost: 250000,
      implementationServicesCost: 120000,
      trainingCost: 30000,
      networkRedesignCost: 50000,
      fteCount: 2,
      estimatedAnnualDowntimeHours: 48
    },
    enterprise: {
      initialHardwareCost: 600000,
      annualMaintenanceCost: 200000,
      annualLicensingCost: 625000,
      implementationServicesCost: 250000,
      trainingCost: 60000,
      networkRedesignCost: 100000,
      fteCount: 3,
      estimatedAnnualDowntimeHours: 72
    }
  },
  aruba: {
    small: {
      initialHardwareCost: 65000,
      annualMaintenanceCost: 20000,
      annualLicensingCost: 35000,
      implementationServicesCost: 30000,
      trainingCost: 9000,
      networkRedesignCost: 12000,
      fteCount: 1,
      estimatedAnnualDowntimeHours: 20
    },
    medium: {
      initialHardwareCost: 130000,
      annualMaintenanceCost: 45000,
      annualLicensingCost: 90000,
      implementationServicesCost: 50000,
      trainingCost: 12000,
      networkRedesignCost: 20000,
      fteCount: 1.5,
      estimatedAnnualDowntimeHours: 30
    },
    large: {
      initialHardwareCost: 280000,
      annualMaintenanceCost: 90000,
      annualLicensingCost: 225000,
      implementationServicesCost: 100000,
      trainingCost: 25000,
      networkRedesignCost: 40000,
      fteCount: 2,
      estimatedAnnualDowntimeHours: 40
    },
    enterprise: {
      initialHardwareCost: 550000,
      annualMaintenanceCost: 180000,
      annualLicensingCost: 560000,
      implementationServicesCost: 200000,
      trainingCost: 50000,
      networkRedesignCost: 80000,
      fteCount: 2.5,
      estimatedAnnualDowntimeHours: 60
    }
  },
  forescout: {
    small: {
      initialHardwareCost: 70000,
      annualMaintenanceCost: 22000,
      annualLicensingCost: 38000,
      implementationServicesCost: 32000,
      trainingCost: 8000,
      networkRedesignCost: 10000,
      fteCount: 1,
      estimatedAnnualDowntimeHours: 18
    },
    medium: {
      initialHardwareCost: 140000,
      annualMaintenanceCost: 48000,
      annualLicensingCost: 95000,
      implementationServicesCost: 45000,
      trainingCost: 14000,
      networkRedesignCost: 18000,
      fteCount: 1.5,
      estimatedAnnualDowntimeHours: 28
    },
    large: {
      initialHardwareCost: 290000,
      annualMaintenanceCost: 95000,
      annualLicensingCost: 230000,
      implementationServicesCost: 90000,
      trainingCost: 25000,
      networkRedesignCost: 35000,
      fteCount: 2,
      estimatedAnnualDowntimeHours: 36
    },
    enterprise: {
      initialHardwareCost: 580000,
      annualMaintenanceCost: 190000,
      annualLicensingCost: 575000,
      implementationServicesCost: 180000,
      trainingCost: 45000,
      networkRedesignCost: 70000,
      fteCount: 2.5,
      estimatedAnnualDowntimeHours: 54
    }
  },
  fortinet: {
    small: {
      initialHardwareCost: 60000,
      annualMaintenanceCost: 18000,
      annualLicensingCost: 32000,
      implementationServicesCost: 25000,
      trainingCost: 7000,
      networkRedesignCost: 8000,
      fteCount: 0.75,
      estimatedAnnualDowntimeHours: 16
    },
    medium: {
      initialHardwareCost: 120000,
      annualMaintenanceCost: 40000,
      annualLicensingCost: 80000,
      implementationServicesCost: 40000,
      trainingCost: 12000,
      networkRedesignCost: 15000,
      fteCount: 1.25,
      estimatedAnnualDowntimeHours: 24
    },
    large: {
      initialHardwareCost: 250000,
      annualMaintenanceCost: 80000,
      annualLicensingCost: 200000,
      implementationServicesCost: 80000,
      trainingCost: 22000,
      networkRedesignCost: 30000,
      fteCount: 1.75,
      estimatedAnnualDowntimeHours: 32
    },
    enterprise: {
      initialHardwareCost: 500000,
      annualMaintenanceCost: 160000,
      annualLicensingCost: 500000,
      implementationServicesCost: 160000,
      trainingCost: 40000,
      networkRedesignCost: 60000,
      fteCount: 2.25,
      estimatedAnnualDowntimeHours: 48
    }
  },
  securew2: {
    small: {
      initialHardwareCost: 0,
      annualMaintenanceCost: 6000,
      annualLicensingCost: 30000,
      implementationServicesCost: 8000,
      trainingCost: 3000,
      networkRedesignCost: 5000,
      fteCount: 0.5,
      estimatedAnnualDowntimeHours: 8
    },
    medium: {
      initialHardwareCost: 0,
      annualMaintenanceCost: 12000,
      annualLicensingCost: 75000,
      implementationServicesCost: 15000,
      trainingCost: 6000,
      networkRedesignCost: 10000,
      fteCount: 0.75,
      estimatedAnnualDowntimeHours: 12
    },
    large: {
      initialHardwareCost: 0,
      annualMaintenanceCost: 24000,
      annualLicensingCost: 180000,
      implementationServicesCost: 30000,
      trainingCost: 12000,
      networkRedesignCost: 20000,
      fteCount: 1,
      estimatedAnnualDowntimeHours: 16
    },
    enterprise: {
      initialHardwareCost: 0,
      annualMaintenanceCost: 40000,
      annualLicensingCost: 450000,
      implementationServicesCost: 60000,
      trainingCost: 25000,
      networkRedesignCost: 40000,
      fteCount: 1.5,
      estimatedAnnualDowntimeHours: 24
    }
  },
  ivanti: {
    small: {
      initialHardwareCost: 50000,
      annualMaintenanceCost: 15000,
      annualLicensingCost: 30000,
      implementationServicesCost: 20000,
      trainingCost: 8000,
      networkRedesignCost: 10000,
      fteCount: 0.75,
      estimatedAnnualDowntimeHours: 16
    },
    medium: {
      initialHardwareCost: 100000,
      annualMaintenanceCost: 35000,
      annualLicensingCost: 75000,
      implementationServicesCost: 40000,
      trainingCost: 15000,
      networkRedesignCost: 20000,
      fteCount: 1.25,
      estimatedAnnualDowntimeHours: 24
    },
    large: {
      initialHardwareCost: 200000,
      annualMaintenanceCost: 70000,
      annualLicensingCost: 185000,
      implementationServicesCost: 80000,
      trainingCost: 25000,
      networkRedesignCost: 35000,
      fteCount: 1.75,
      estimatedAnnualDowntimeHours: 32
    },
    enterprise: {
      initialHardwareCost: 400000,
      annualMaintenanceCost: 140000,
      annualLicensingCost: 460000,
      implementationServicesCost: 160000,
      trainingCost: 45000,
      networkRedesignCost: 70000,
      fteCount: 2.25,
      estimatedAnnualDowntimeHours: 48
    }
  },
  microsoft: {
    small: {
      initialHardwareCost: 15000,
      annualMaintenanceCost: 5000,
      annualLicensingCost: 5000,
      implementationServicesCost: 15000,
      trainingCost: 5000,
      networkRedesignCost: 8000,
      fteCount: 0.75,
      estimatedAnnualDowntimeHours: 20
    },
    medium: {
      initialHardwareCost: 30000,
      annualMaintenanceCost: 10000,
      annualLicensingCost: 10000,
      implementationServicesCost: 30000,
      trainingCost: 10000,
      networkRedesignCost: 15000,
      fteCount: 1.25,
      estimatedAnnualDowntimeHours: 30
    },
    large: {
      initialHardwareCost: 60000,
      annualMaintenanceCost: 20000,
      annualLicensingCost: 20000,
      implementationServicesCost: 60000,
      trainingCost: 20000,
      networkRedesignCost: 30000,
      fteCount: 1.75,
      estimatedAnnualDowntimeHours: 40
    },
    enterprise: {
      initialHardwareCost: 120000,
      annualMaintenanceCost: 40000,
      annualLicensingCost: 40000,
      implementationServicesCost: 120000,
      trainingCost: 40000,
      networkRedesignCost: 60000,
      fteCount: 2.5,
      estimatedAnnualDowntimeHours: 60
    }
  }
};

// Research-based default values for implementation timelines
export const vendorImplementation: Record<VendorID, VendorImplementation> = {
  portnox: {
    small: {
      planningDays: 3,
      deploymentDays: 1,
      integrationDays: 2,
      testingDays: 2,
      staffTrainingDays: 1,
      rolloutDays: 1
    },
    medium: {
      planningDays: 5,
      deploymentDays: 1,
      integrationDays: 3,
      testingDays: 3,
      staffTrainingDays: 1,
      rolloutDays: 2
    },
    large: {
      planningDays: 10,
      deploymentDays: 1,
      integrationDays: 7,
      testingDays: 5,
      staffTrainingDays: 2,
      rolloutDays: 5
    },
    enterprise: {
      planningDays: 20,
      deploymentDays: 2,
      integrationDays: 14,
      testingDays: 10,
      staffTrainingDays: 4,
      rolloutDays: 10
    }
  },
  cisco: {
    small: {
      planningDays: 14,
      deploymentDays: 10,
      integrationDays: 15,
      testingDays: 21,
      staffTrainingDays: 10,
      rolloutDays: 30
    },
    medium: {
      planningDays: 21,
      deploymentDays: 15,
      integrationDays: 21,
      testingDays: 28,
      staffTrainingDays: 14,
      rolloutDays: 45
    },
    large: {
      planningDays: 30,
      deploymentDays: 21,
      integrationDays: 30,
      testingDays: 35,
      staffTrainingDays: 21,
      rolloutDays: 60
    },
    enterprise: {
      planningDays: 45,
      deploymentDays: 30,
      integrationDays: 45,
      testingDays: 50,
      staffTrainingDays: 30,
      rolloutDays: 90
    }
  },
  aruba: {
    small: {
      planningDays: 10,
      deploymentDays: 8,
      integrationDays: 12,
      testingDays: 18,
      staffTrainingDays: 8,
      rolloutDays: 25
    },
    medium: {
      planningDays: 14,
      deploymentDays: 12,
      integrationDays: 18,
      testingDays: 24,
      staffTrainingDays: 12,
      rolloutDays: 40
    },
    large: {
      planningDays: 21,
      deploymentDays: 18,
      integrationDays: 25,
      testingDays: 30,
      staffTrainingDays: 16,
      rolloutDays: 55
    },
    enterprise: {
      planningDays: 35,
      deploymentDays: 25,
      integrationDays: 35,
      testingDays: 40,
      staffTrainingDays: 25,
      rolloutDays: 80
    }
  },
  forescout: {
    small: {
      planningDays: 12,
      deploymentDays: 8,
      integrationDays: 14,
      testingDays: 16,
      staffTrainingDays: 7,
      rolloutDays: 20
    },
    medium: {
      planningDays: 16,
      deploymentDays: 12,
      integrationDays: 18,
      testingDays: 20,
      staffTrainingDays: 10,
      rolloutDays: 35
    },
    large: {
      planningDays: 24,
      deploymentDays: 18,
      integrationDays: 24,
      testingDays: 25,
      staffTrainingDays: 14,
      rolloutDays: 45
    },
    enterprise: {
      planningDays: 40,
      deploymentDays: 28,
      integrationDays: 36,
      testingDays: 35,
      staffTrainingDays: 20,
      rolloutDays: 65
    }
  },
  fortinet: {
    small: {
      planningDays: 10,
      deploymentDays: 7,
      integrationDays: 12,
      testingDays: 14,
      staffTrainingDays: 6,
      rolloutDays: 18
    },
    medium: {
      planningDays: 14,
      deploymentDays: 10,
      integrationDays: 16,
      testingDays: 18,
      staffTrainingDays: 9,
      rolloutDays: 30
    },
    large: {
      planningDays: 20,
      deploymentDays: 15,
      integrationDays: 22,
      testingDays: 24,
      staffTrainingDays: 12,
      rolloutDays: 42
    },
    enterprise: {
      planningDays: 35,
      deploymentDays: 25,
      integrationDays: 32,
      testingDays: 35,
      staffTrainingDays: 18,
      rolloutDays: 60
    }
  },
  securew2: {
    small: {
      planningDays: 5,
      deploymentDays: 2,
      integrationDays: 4,
      testingDays: 4,
      staffTrainingDays: 2,
      rolloutDays: 6
    },
    medium: {
      planningDays: 8,
      deploymentDays: 3,
      integrationDays: 6,
      testingDays: 6,
      staffTrainingDays: 3,
      rolloutDays: 10
    },
    large: {
      planningDays: 14,
      deploymentDays: 4,
      integrationDays: 10,
      testingDays: 10,
      staffTrainingDays: 5,
      rolloutDays: 20
    },
    enterprise: {
      planningDays: 25,
      deploymentDays: 6,
      integrationDays: 18,
      testingDays: 18,
      staffTrainingDays: 8,
      rolloutDays: 35
    }
  },
  ivanti: {
    small: {
      planningDays: 10,
      deploymentDays: 7,
      integrationDays: 12,
      testingDays: 14,
      staffTrainingDays: 6,
      rolloutDays: 18
    },
    medium: {
      planningDays: 15,
      deploymentDays: 10,
      integrationDays: 16,
      testingDays: 18,
      staffTrainingDays: 9,
      rolloutDays: 28
    },
    large: {
      planningDays: 22,
      deploymentDays: 15,
      integrationDays: 22,
      testingDays: 22,
      staffTrainingDays: 12,
      rolloutDays: 40
    },
    enterprise: {
      planningDays: 36,
      deploymentDays: 24,
      integrationDays: 32,
      testingDays: 30,
      staffTrainingDays: 18,
      rolloutDays: 60
    }
  },
  microsoft: {
    small: {
      planningDays: 8,
      deploymentDays: 5,
      integrationDays: 10,
      testingDays: 12,
      staffTrainingDays: 4,
      rolloutDays: 15
    },
    medium: {
      planningDays: 12,
      deploymentDays: 8,
      integrationDays: 14,
      testingDays: 16,
      staffTrainingDays: 6,
      rolloutDays: 25
    },
    large: {
      planningDays: 18,
      deploymentDays: 12,
      integrationDays: 20,
      testingDays: 22,
      staffTrainingDays: 9,
      rolloutDays: 35
    },
    enterprise: {
      planningDays: 30,
      deploymentDays: 18,
      integrationDays: 28,
      testingDays: 30,
      staffTrainingDays: 14,
      rolloutDays: 50
    }
  }
};

// Feature comparison data with detailed scoring
export const featureComparison: VendorFeatureComparison = {
  deploymentModel: {
    cisco: { value: 'On-premises', score: 2 },
    aruba: { value: 'On-premises', score: 2 },
    forescout: { value: 'On-premises/Hybrid', score: 3 },
    fortinet: { value: 'On-premises', score: 2 },
    securew2: { value: 'Cloud-native', score: 5 },
    ivanti: { value: 'On-premises/Cloud', score: 4 },
    microsoft: { value: 'On-premises', score: 1 },
    portnox: { value: 'Cloud-native SaaS', score: 5 }
  },
  hardwareRequired: {
    cisco: { value: 'Yes - Multiple appliances', score: 1 },
    aruba: { value: 'Yes - Multiple appliances', score: 1 },
    forescout: { value: 'Yes - Multiple appliances', score: 1 },
    fortinet: { value: 'Yes - Dedicated appliances', score: 1 },
    securew2: { value: 'No', score: 5 },
    ivanti: { value: 'Yes - Can be virtualized', score: 2 },
    microsoft: { value: 'Yes - Windows Servers', score: 2 },
    portnox: { value: 'No', score: 5 }
  },
  implementationTime: {
    cisco: { value: '3-6 months', score: 1 },
    aruba: { value: '2.5-5 months', score: 2 },
    forescout: { value: '2-4.5 months', score: 2 },
    fortinet: { value: '2-4 months', score: 2 },
    securew2: { value: '0.5-1.5 months', score: 4 },
    ivanti: { value: '2-4 months', score: 2 },
    microsoft: { value: '1.5-3 months', score: 3 },
    portnox: { value: '0.5-1 month', score: 5 }
  },
  maintenanceEffort: {
    cisco: { value: 'High', score: 1 },
    aruba: { value: 'Medium-High', score: 2 },
    forescout: { value: 'Medium', score: 3 },
    fortinet: { value: 'Medium', score: 3 },
    securew2: { value: 'Low', score: 4 },
    ivanti: { value: 'Medium', score: 3 },
    microsoft: { value: 'Medium-High', score: 2 },
    portnox: { value: 'Low', score: 5 }
  },
  automatedUpdates: {
    cisco: { value: 'No', score: 1 },
    aruba: { value: 'No', score: 1 },
    forescout: { value: 'Partial', score: 3 },
    fortinet: { value: 'Partial', score: 3 },
    securew2: { value: 'Yes', score: 5 },
    ivanti: { value: 'Partial', score: 3 },
    microsoft: { value: 'No', score: 1 },
    portnox: { value: 'Yes', score: 5 }
  },
  scalability: {
    cisco: { value: 'Complex', score: 2 },
    aruba: { value: 'Moderate', score: 3 },
    forescout: { value: 'Moderate', score: 3 },
    fortinet: { value: 'Moderate', score: 3 },
    securew2: { value: 'Easy', score: 4 },
    ivanti: { value: 'Moderate', score: 3 },
    microsoft: { value: 'Limited', score: 1 },
    portnox: { value: 'Easy', score: 5 }
  },
  multiVendorSupport: {
    cisco: { value: 'Limited (Cisco-centric)', score: 2 },
    aruba: { value: 'Good', score: 4 },
    forescout: { value: 'Very Good', score: 4 },
    fortinet: { value: 'Moderate', score: 3 },
    securew2: { value: 'Good', score: 4 },
    ivanti: { value: 'Good', score: 4 },
    microsoft: { value: 'Limited', score: 2 },
    portnox: { value: 'Excellent', score: 5 }
  },
  licensingModel: {
    cisco: { value: 'Complex tiered', score: 2 },
    aruba: { value: 'Per device/Perpetual', score: 3 },
    forescout: { value: 'Per device flexibility', score: 3 },
    fortinet: { value: 'Bundle/Subscription', score: 3 },
    securew2: { value: 'Per user subscription', score: 4 },
    ivanti: { value: 'User/Device based', score: 3 },
    microsoft: { value: 'Windows Server CALs', score: 2 },
    portnox: { value: 'Simple subscription', score: 5 }
  },
  totalCostOfOwnership: {
    cisco: { value: 'High', score: 1 },
    aruba: { value: 'High', score: 1 },
    forescout: { value: 'Medium-High', score: 2 },
    fortinet: { value: 'Medium', score: 3 },
    securew2: { value: 'Low-Medium', score: 4 },
    ivanti: { value: 'Medium', score: 3 },
    microsoft: { value: 'Medium', score: 3 },
    portnox: { value: 'Low', score: 5 }
  },
  automatedRemediation: {
    cisco: { value: 'Basic', score: 3 },
    aruba: { value: 'Basic', score: 3 },
    forescout: { value: 'Advanced', score: 4 },
    fortinet: { value: 'Advanced', score: 4 },
    securew2: { value: 'Limited', score: 2 },
    ivanti: { value: 'Advanced', score: 4 },
    microsoft: { value: 'Limited', score: 2 },
    portnox: { value: 'Advanced', score: 5 }
  },
  cloudIntegration: {
    cisco: { value: 'Limited', score: 2 },
    aruba: { value: 'Moderate', score: 3 },
    forescout: { value: 'Moderate', score: 3 },
    fortinet: { value: 'Moderate', score: 3 },
    securew2: { value: 'Native', score: 5 },
    ivanti: { value: 'Good', score: 4 },
    microsoft: { value: 'Basic Azure Integration', score: 2 },
    portnox: { value: 'Native', score: 5 }
  },
  remoteWorkSupport: {
    cisco: { value: 'Complex', score: 2 },
    aruba: { value: 'Moderate', score: 3 },
    forescout: { value: 'Good', score: 4 },
    fortinet: { value: 'Good', score: 4 },
    securew2: { value: 'Excellent', score: 5 },
    ivanti: { value: 'Very Good', score: 4 },
    microsoft: { value: 'Basic', score: 2 },
    portnox: { value: 'Excellent', score: 5 }
  },
  deviceDiscovery: {
    cisco: { value: 'Good', score: 4 },
    aruba: { value: 'Good', score: 4 },
    forescout: { value: 'Excellent', score: 5 },
    fortinet: { value: 'Very Good', score: 4 },
    securew2: { value: 'Basic', score: 2 },
    ivanti: { value: 'Very Good', score: 4 },
    microsoft: { value: 'Limited', score: 1 },
    portnox: { value: 'Very Good', score: 4 }
  },
  iotSupport: {
    cisco: { value: 'Moderate', score: 3 },
    aruba: { value: 'Good', score: 4 },
    forescout: { value: 'Excellent', score: 5 },
    fortinet: { value: 'Very Good', score: 4 },
    securew2: { value: 'Limited', score: 2 },
    ivanti: { value: 'Good', score: 4 },
    microsoft: { value: 'Poor', score: 1 },
    portnox: { value: 'Very Good', score: 4 }
  },
  npsScores: {
    cisco: { value: '58', score: 3 },
    aruba: { value: '61', score: 3 },
    forescout: { value: '63', score: 3 },
    fortinet: { value: '54', score: 3 },
    securew2: { value: '67', score: 4 },
    ivanti: { value: '52', score: 3 },
    microsoft: { value: '45', score: 2 },
    portnox: { value: '75', score: 5 }
  }
};

// Export calculation utilities
export const calculateTotalImplementationTime = (implementationTimeline: ImplementationTimeline): number => {
  return Object.values(implementationTimeline).reduce((total, days) => total + days, 0);
};

export const calculateInitialCosts = (costFactors: CostFactors): number => {
  return costFactors.initialHardwareCost + 
         costFactors.implementationServicesCost + 
         costFactors.networkRedesignCost + 
         costFactors.trainingCost;
};

export const calculateAnnualCosts = (costFactors: CostFactors, fteCostPerYear: number, downtimeCostPerHour: number): number => {
  return costFactors.annualMaintenanceCost + 
         costFactors.annualLicensingCost + 
         (fteCostPerYear * costFactors.fteCount) + 
         (downtimeCostPerHour * costFactors.estimatedAnnualDowntimeHours);
};

export const calculateTCO = (
  costFactors: CostFactors, 
  fteCostPerYear: number,
  downtimeCostPerHour: number,
  years: number,
  complexityMultiplier: number = 1.0
): number => {
  const initialCosts = calculateInitialCosts(costFactors) * complexityMultiplier;
  const annualCosts = calculateAnnualCosts(costFactors, fteCostPerYear, downtimeCostPerHour) * complexityMultiplier;
  
  return initialCosts + (annualCosts * years);
};

export const calculateROI = (savingsOverPeriod: number, investmentCost: number): number => {
  return (savingsOverPeriod / investmentCost) * 100;
};

export const calculatePaybackPeriod = (initialInvestment: number, annualSavings: number): number => {
  return initialInvestment / annualSavings;
};

export const calculateComplexityMultiplier = (
  networkComplexity: NetworkComplexity,
  hasMultipleLocations: boolean,
  locationCount: number,
  hasComplexAuth: boolean,
  hasLegacyDevices: boolean,
  legacyDevicePercentage: number,
  hasCloudIntegration: boolean,
  hasCustomPolicies: boolean,
  policyComplexity: NetworkComplexity
): number => {
  let multiplier = 1.0;
  
  // Base complexity factor
  if (networkComplexity === 'low') {
    multiplier *= 0.9;
  } else if (networkComplexity === 'high') {
    multiplier *= 1.3;
  }
  
  // Additional factors
  if (hasMultipleLocations) {
    // Add 10% per location beyond the first, up to 100% extra
    multiplier += Math.min(0.1 * (locationCount - 1), 1.0);
  }
  
  if (hasComplexAuth) {
    multiplier += 0.15;
  }
  
  if (hasLegacyDevices) {
    // Add 0-30% based on percentage of legacy devices
    multiplier += (legacyDevicePercentage / 100) * 0.3;
  }
  
  if (hasCloudIntegration) {
    multiplier += 0.1;
  }
  
  if (hasCustomPolicies) {
    if (policyComplexity === 'low') {
      multiplier += 0.05;
    } else if (policyComplexity === 'medium') {
      multiplier += 0.15;
    } else if (policyComplexity === 'high') {
      multiplier += 0.25;
    }
  }
  
  return multiplier;
};
EOL
  display_success "Created vendor data and calculation models"
  
  # Create complexity factors data
  cat > lib/data/complexity-factors.ts << EOL
// Complexity factors data for advanced configuration

export interface ComplexityFactorOption {
  id: string;
  label: string;
  description: string;
  impactLevel: 'low' | 'medium' | 'high';
  impactFactorMin: number;
  impactFactorMax: number;
  defaultValue: boolean | number;
  type: 'boolean' | 'number' | 'percentage' | 'select';
  options?: string[];
  conditionalOn?: string;
  applicableToVendors?: string[];
  notApplicableToVendors?: string[];
}

export const complexityFactors: ComplexityFactorOption[] = [
  {
    id: 'hasMultipleLocations',
    label: 'Multiple Geographic Locations',
    description: 'Organization has multiple physical locations requiring NAC deployment',
    impactLevel: 'high',
    impactFactorMin: 1.1,
    impactFactorMax: 2.0,
    defaultValue: false,
    type: 'boolean'
  },
  {
    id: 'locationCount',
    label: 'Number of Locations',
    description: 'Total number of physical locations requiring NAC deployment',
    impactLevel: 'medium',
    impactFactorMin: 1.0,
    impactFactorMax: 2.0,
    defaultValue: 1,
    type: 'number',
    conditionalOn: 'hasMultipleLocations'
  },
  {
    id: 'hasComplexAuthentication',
    label: 'Complex Authentication Requirements',
    description: 'Multiple authentication methods, certificates, MFA, or integration with external IdPs',
    impactLevel: 'medium',
    impactFactorMin: 1.15,
    impactFactorMax: 1.25,
    defaultValue: false,
    type: 'boolean'
  },
  {
    id: 'hasLegacyDevices',
    label: 'Legacy Devices Support',
    description: 'Environment includes legacy devices requiring special NAC handling',
    impactLevel: 'medium',
    impactFactorMin: 1.1,
    impactFactorMax: 1.3,
    defaultValue: false,
    type: 'boolean'
  },
  {
    id: 'percentLegacyDevices',
    label: 'Percentage of Legacy Devices',
    description: 'Percentage of network devices considered legacy',
    impactLevel: 'medium',
    impactFactorMin: 1.0,
    impactFactorMax: 1.3,
    defaultValue: 10,
    type: 'percentage',
    conditionalOn: 'hasLegacyDevices'
  },
  {
    id: 'hasCloudIntegration',
    label: 'Cloud Service Integrations',
    description: 'Integration with cloud services like Azure, AWS, or SaaS applications',
    impactLevel: 'low',
    impactFactorMin: 1.1,
    impactFactorMax: 1.15,
    defaultValue: false,
    type: 'boolean'
  },
  {
    id: 'hasCustomPolicies',
    label: 'Custom Security Policies',
    description: 'Custom-developed security policies beyond standard templates',
    impactLevel: 'medium',
    impactFactorMin: 1.05,
    impactFactorMax: 1.25,
    defaultValue: false,
    type: 'boolean'
  },
  {
    id: 'policyComplexityLevel',
    label: 'Policy Complexity Level',
    description: 'Complexity level of custom security policies',
    impactLevel: 'varies',
    impactFactorMin: 1.05,
    impactFactorMax: 1.25,
    defaultValue: 'medium',
    type: 'select',
    options: ['low', 'medium', 'high'],
    conditionalOn: 'hasCustomPolicies'
  },
  {
    id: 'hasComplianceRequirements',
    label: 'Specific Compliance Requirements',
    description: 'Compliance with standards like PCI DSS, HIPAA, GDPR, etc.',
    impactLevel: 'medium',
    impactFactorMin: 1.1,
    impactFactorMax: 1.2,
    defaultValue: false,
    type: 'boolean'
  },
  {
    id: 'complianceTypes',
    label: 'Compliance Types',
    description: 'Specific compliance standards required',
    impactLevel: 'medium',
    impactFactorMin: 1.1,
    impactFactorMax: 1.2,
    defaultValue: 1,
    type: 'number',
    conditionalOn: 'hasComplianceRequirements'
  },
  {
    id: 'hasHighAvailabilityRequirements',
    label: 'High Availability Requirements',
    description: 'Redundancy and high availability deployment requirements',
    impactLevel: 'medium',
    impactFactorMin: 1.15,
    impactFactorMax: 1.3,
    defaultValue: false,
    type: 'boolean',
    notApplicableToVendors: ['portnox', 'securew2']
  },
  {
    id: 'hasByodRequirements',
    label: 'BYOD Support Requirements',
    description: 'Bring Your Own Device policy support and onboarding',
    impactLevel: 'low',
    impactFactorMin: 1.05,
    impactFactorMax: 1.15,
    defaultValue: false,
    type: 'boolean'
  },
  {
    id: 'hasIotDevices',
    label: 'IoT Device Support',
    description: 'Internet of Things devices requiring NAC controls',
    impactLevel: 'medium',
    impactFactorMin: 1.1,
    impactFactorMax: 1.2,
    defaultValue: false,
    type: 'boolean'
  },
  {
    id: 'iotDevicePercentage',
    label: 'Percentage of IoT Devices',
    description: 'Percentage of network devices that are IoT',
    impactLevel: 'medium',
    impactFactorMin: 1.0,
    impactFactorMax: 1.2,
    defaultValue: 10,
    type: 'percentage',
    conditionalOn: 'hasIotDevices'
  },
  {
    id: 'hasWirelessNetwork',
    label: 'Wireless Network',
    description: 'Environment includes wireless networks requiring NAC integration',
    impactLevel: 'low',
    impactFactorMin: 1.05,
    impactFactorMax: 1.1,
    defaultValue: true,
    type: 'boolean'
  },
  {
    id: 'wirelessPercentage',
    label: 'Percentage of Wireless Devices',
    description: 'Percentage of devices connecting via wireless',
    impactLevel: 'low',
    impactFactorMin: 1.0,
    impactFactorMax: 1.1,
    defaultValue: 60,
    type: 'percentage',
    conditionalOn: 'hasWirelessNetwork'
  },
  {
    id: 'hasRemoteUsers',
    label: 'Remote Users Support',
    description: 'Support for VPN/remote users requiring NAC policies',
    impactLevel: 'medium',
    impactFactorMin: 1.1,
    impactFactorMax: 1.2,
    defaultValue: true,
    type: 'boolean'
  },
  {
    id: 'remoteUserPercentage',
    label: 'Percentage of Remote Users',
    description: 'Percentage of users primarily working remotely',
    impactLevel: 'medium',
    impactFactorMin: 1.0,
    impactFactorMax: 1.2,
    defaultValue: 30,
    type: 'percentage',
    conditionalOn: 'hasRemoteUsers'
  }
];

// Impact factors by vendor - how each vendor is affected by complexity
// Lower numbers indicate that a vendor handles complexity better
export const vendorComplexityImpact = {
  portnox: 0.6, // Cloud-native solutions handle complexity better
  securew2: 0.7,
  fortinet: 0.9,
  forescout: 0.85,
  ivanti: 0.9,
  aruba: 1.0,
  cisco: 1.1, // Traditional on-prem solutions may be more affected by complexity
  microsoft: 1.2
};
EOL
  display_success "Created complexity factors data"
  
  # Create ROI metrics data
  cat > lib/data/roi-metrics.ts << EOL
// Comprehensive ROI metrics and analysis data

export interface ROIMetric {
  id: string;
  name: string;
  description: string;
  category: 'financial' | 'operational' | 'security' | 'compliance' | 'strategic';
  measurementUnit: string;
  calculationMethod: string;
  benchmarkData?: Record<string, number>;
  industryAverage?: number;
  includedInDefaultCalc: boolean;
}

export const roiMetrics: ROIMetric[] = [
  {
    id: 'costSavings',
    name: 'Direct Cost Savings',
    description: 'Total reduction in direct costs including hardware, software, maintenance, and personnel',
    category: 'financial',
    measurementUnit: 'currency',
    calculationMethod: 'Current Solution TCO - Portnox TCO',
    includedInDefaultCalc: true
  },
  {
    id: 'roi',
    name: 'Return on Investment',
    description: 'Percentage return on investment over the analysis period',
    category: 'financial',
    measurementUnit: 'percentage',
    calculationMethod: '(Total Savings / Portnox TCO) * 100',
    includedInDefaultCalc: true
  },
  {
    id: 'paybackPeriod',
    name: 'Payback Period',
    description: 'Time required to recover the initial investment',
    category: 'financial',
    measurementUnit: 'years',
    calculationMethod: 'Initial Investment / Annual Savings',
    includedInDefaultCalc: true
  },
  {
    id: 'npv',
    name: 'Net Present Value',
    description: 'Present value of future savings minus initial investment',
    category: 'financial',
    measurementUnit: 'currency',
    calculationMethod: 'PV(future cash flows) - initial investment',
    includedInDefaultCalc: false
  },
  {
    id: 'irr',
    name: 'Internal Rate of Return',
    description: 'Discount rate that makes the NPV of the investment equal to zero',
    category: 'financial',
    measurementUnit: 'percentage',
    calculationMethod: 'Rate at which NPV = 0',
    includedInDefaultCalc: false
  },
  {
    id: 'timeToImplementation',
    name: 'Implementation Time Savings',
    description: 'Reduction in time to implement NAC solution',
    category: 'operational',
    measurementUnit: 'days',
    calculationMethod: 'Current Solution Implementation Time - Portnox Implementation Time',
    includedInDefaultCalc: true
  },
  {
    id: 'downtimeReduction',
    name: 'Downtime Reduction',
    description: 'Annual reduction in system downtime hours',
    category: 'operational',
    measurementUnit: 'hours',
    calculationMethod: 'Current Solution Downtime - Portnox Downtime',
    benchmarkData: {
      'small': 16,
      'medium': 24,
      'large': 32,
      'enterprise': 48
    },
    includedInDefaultCalc: true
  },
  {
    id: 'fteReduction',
    name: 'FTE Reduction',
    description: 'Reduction in full-time equivalent staff required for management',
    category: 'operational',
    measurementUnit: 'FTE',
    calculationMethod: 'Current Solution FTE - Portnox FTE',
    includedInDefaultCalc: true
  },
  {
    id: 'opexReduction',
    name: 'OpEx Reduction',
    description: 'Reduction in operational expenditure',
    category: 'financial',
    measurementUnit: 'currency',
    calculationMethod: 'Current Solution Annual Costs - Portnox Annual Costs',
    includedInDefaultCalc: true
  },
  {
    id: 'capexReduction',
    name: 'CapEx Elimination',
    description: 'Reduction in capital expenditure due to hardware elimination',
    category: 'financial',
    measurementUnit: 'currency',
    calculationMethod: 'Current Solution Hardware Costs',
    includedInDefaultCalc: true
  },
  {
    id: 'maintenanceTimeReduction',
    name: 'Maintenance Time Reduction',
    description: 'Reduction in time spent on maintenance and updates',
    category: 'operational',
    measurementUnit: 'hours/year',
    calculationMethod: 'Estimated based on FTE allocation',
    benchmarkData: {
      'small': 80,
      'medium': 150,
      'large': 240,
      'enterprise': 480
    },
    includedInDefaultCalc: false
  },
  {
    id: 'incidentReduction',
    name: 'Security Incident Reduction',
    description: 'Estimated reduction in security incidents due to improved NAC',
    category: 'security',
    measurementUnit: 'percentage',
    calculationMethod: 'Based on industry benchmarks and feature effectiveness',
    benchmarkData: {
      'small': 30,
      'medium': 35,
      'large': 40,
      'enterprise': 45
    },
    industryAverage: 35,
    includedInDefaultCalc: false
  },
  {
    id: 'breachRiskReduction',
    name: 'Data Breach Risk Reduction',
    description: 'Estimated reduction in data breach risk',
    category: 'security',
    measurementUnit: 'percentage',
    calculationMethod: 'Based on industry benchmarks and security score improvement',
    benchmarkData: {
      'small': 25,
      'medium': 30,
      'large': 35,
      'enterprise': 40
    },
    industryAverage: 30,
    includedInDefaultCalc: false
  },
  {
    id: 'breachCostAvoidance',
    name: 'Breach Cost Avoidance',
    description: 'Estimated financial impact of avoided breaches',
    category: 'security',
    measurementUnit: 'currency',
    calculationMethod: 'Average Breach Cost × Breach Risk Reduction',
    benchmarkData: {
      'small': 120000,
      'medium': 250000,
      'large': 750000,
      'enterprise': 3800000
    },
    includedInDefaultCalc: false
  },
  {
    id: 'complianceImprovement',
    name: 'Compliance Improvement',
    description: 'Improvement in compliance posture',
    category: 'compliance',
    measurementUnit: 'percentage',
    calculationMethod: 'Based on compliance automation capabilities',
    benchmarkData: {
      'small': 40,
      'medium': 45,
      'large': 50,
      'enterprise': 60
    },
    includedInDefaultCalc: false
  },
  {
    id: 'auditEfficiency',
    name: 'Audit Efficiency Improvement',
    description: 'Reduction in time spent on audit preparation and response',
    category: 'compliance',
    measurementUnit: 'percentage',
    calculationMethod: 'Based on reporting and automation capabilities',
    benchmarkData: {
      'small': 30,
      'medium': 40,
      'large': 50,
      'enterprise': 60
    },
    includedInDefaultCalc: false
  },
  {
    id: 'userProductivity',
    name: 'User Productivity Improvement',
    description: 'Productivity gain from simplified onboarding and fewer disruptions',
    category: 'operational',
    measurementUnit: 'percentage',
    calculationMethod: 'Based on user experience improvements',
    benchmarkData: {
      'small': 2,
      'medium': 3,
      'large': 4,
      'enterprise': 5
    },
    includedInDefaultCalc: false
  },
  {
    id: 'timeToValue',
    name: 'Time to Value',
    description: 'How quickly the solution delivers value to the organization',
    category: 'strategic',
    measurementUnit: 'days',
    calculationMethod: 'Implementation time + time to first measurable benefit',
    includedInDefaultCalc: false
  },
  {
    id: 'scalabilitySavings',
    name: 'Scalability Cost Avoidance',
    description: 'Avoided costs of scaling traditional infrastructure',
    category: 'strategic',
    measurementUnit: 'currency',
    calculationMethod: 'Based on growth projections and hardware avoidance',
    includedInDefaultCalc: false
  },
  {
    id: 'remoteWorkEnablement',
    name: 'Remote Work Enablement Value',
    description: 'Business value from improved remote work capabilities',
    category: 'strategic',
    measurementUnit: 'score',
    calculationMethod: 'Based on remote capabilities scoring',
    includedInDefaultCalc: false
  }
];

// Industry benchmarks for various metrics
export const industryBenchmarks = {
  averageDataBreachCost: {
    'healthcare': 9200000,
    'financial': 5850000,
    'technology': 5270000,
    'education': 3790000,
    'retail': 3280000,
    'manufacturing': 4240000,
    'overall': 4350000
  },
  securityIncidentFrequency: {
    'small': 3,  // Average annual incidents without NAC
    'medium': 8,
    'large': 15,
    'enterprise': 35
  },
  incidentResponseTime: {
    'with_nac': 2.5,  // Hours
    'without_nac': 8.4  // Hours
  },
  complianceCosts: {
    'manual': 1200,  // Per device annually
    'automated': 450  // Per device annually
  }
};

// Value drivers for different industries
export const industryValueDrivers = {
  'healthcare': [
    'complianceImprovement',
    'breachRiskReduction',
    'incidentReduction',
    'auditEfficiency'
  ],
  'financial': [
    'breachRiskReduction',
    'complianceImprovement',
    'auditEfficiency',
    'downtimeReduction'
  ],
  'education': [
    'opexReduction',
    'fteReduction',
    'byodSupport',
    'scalabilitySavings'
  ],
  'manufacturing': [
    'timeToImplementation',
    'maintenanceTimeReduction',
    'iotSecurity',
    'downtimeReduction'
  ],
  'retail': [
    'costSavings',
    'timeToImplementation',
    'pciCompliance',
    'byodSupport'
  ],
  'technology': [
    'timeToImplementation',
    'fteReduction',
    'scalabilitySavings',
    'remoteWorkEnablement'
  ],
  'government': [
    'complianceImprovement',
    'costSavings',
    'auditEfficiency',
    'breachRiskReduction'
  ]
};
EOL
  display_success "Created ROI metrics data"
  
  # Create industry/vertical specific data
  cat > lib/data/industry-data.ts << EOL
// Industry-specific data for targeted TCO analysis

export type IndustryType = 
  | 'healthcare'
  | 'financial'
  | 'education'
  | 'manufacturing'
  | 'retail'
  | 'technology'
  | 'government'
  | 'other';

export interface IndustryProfile {
  id: IndustryType;
  name: string;
  description: string;
  keyRequirements: string[];
  complianceNeeds: string[];
  keyMetrics: string[];
  recommendedVendors: string[];
  deviceDensity: number; // Devices per employee benchmark
  wirelessPercentage: number; // Percentage of wireless connections
  byodPercentage: number; // Percentage of BYOD devices
  iotPercentage: number; // Percentage of IoT devices
  securityPriority: 'low' | 'medium' | 'high' | 'critical';
  breachImpact: 'low' | 'medium' | 'high' | 'critical';
  downtimeCostHourly: number; // Average per 100 employees
}

export const industryProfiles: Record<IndustryType, IndustryProfile> = {
  healthcare: {
    id: 'healthcare',
    name: 'Healthcare',
    description: 'Hospitals, clinics, medical practices, and healthcare providers',
    keyRequirements: [
      'IoT medical device security',
      'Patient data protection',
      'High availability',
      'Guest access for patients',
      'Regulatory compliance'
    ],
    complianceNeeds: ['HIPAA', 'HITRUST', 'FDA', 'GDPR'],
    keyMetrics: [
      'Data breach cost avoidance',
      'Compliance automation',
      'Medical device security',
      'Patient data protection'
    ],
    recommendedVendors: ['portnox', 'forescout', 'cisco', 'aruba'],
    deviceDensity: 5.2,
    wirelessPercentage: 70,
    byodPercentage: 30,
    iotPercentage: 45,
    securityPriority: 'critical',
    breachImpact: 'critical',
    downtimeCostHourly: 8500
  },
  financial: {
    id: 'financial',
    name: 'Financial Services',
    description: 'Banks, credit unions, investment firms, and insurance companies',
    keyRequirements: [
      'Stringent access controls',
      'Transaction security',
      'Regulatory compliance',
      'Fraud prevention',
      'High availability'
    ],
    complianceNeeds: ['PCI DSS', 'SOX', 'GLBA', 'GDPR', 'CCPA'],
    keyMetrics: [
      'Regulatory compliance',
      'Risk mitigation',
      'Data breach prevention',
      'Fraud reduction'
    ],
    recommendedVendors: ['cisco', 'forescout', 'portnox', 'aruba'],
    deviceDensity: 3.8,
    wirelessPercentage: 55,
    byodPercentage: 25,
    iotPercentage: 15,
    securityPriority: 'critical',
    breachImpact: 'critical',
    downtimeCostHourly: 11200
  },
  education: {
    id: 'education',
    name: 'Education',
    description: 'K-12 schools, colleges, universities, and educational institutions',
    keyRequirements: [
      'BYOD support',
      'Guest access for students',
      'Scalability for enrollment fluctuations',
      'Research network isolation',
      'Cost-effective deployment'
    ],
    complianceNeeds: ['FERPA', 'CIPA', 'COPPA', 'GDPR'],
    keyMetrics: [
      'Cost efficiency',
      'Automated onboarding',
      'BYOD support',
      'Operational efficiency'
    ],
    recommendedVendors: ['portnox', 'securew2', 'aruba', 'fortinet'],
    deviceDensity: 4.5,
    wirelessPercentage: 85,
    byodPercentage: 65,
    iotPercentage: 20,
    securityPriority: 'medium',
    breachImpact: 'high',
    downtimeCostHourly: 3800
  },
  manufacturing: {
    id: 'manufacturing',
    name: 'Manufacturing',
    description: 'Production facilities, factories, and industrial operations',
    keyRequirements: [
      'OT/IT convergence security',
      'Industrial IoT protection',
      'Production continuity',
      'Legacy system support',
      'Physical security integration'
    ],
    complianceNeeds: ['ISO 27001', 'IEC 62443', 'NIST CSF'],
    keyMetrics: [
      'Production downtime reduction',
      'OT security improvement',
      'Operational efficiency',
      'Legacy systems integration'
    ],
    recommendedVendors: ['forescout', 'fortinet', 'portnox', 'cisco'],
    deviceDensity: 6.2,
    wirelessPercentage: 50,
    byodPercentage: 15,
    iotPercentage: 60,
    securityPriority: 'high',
    breachImpact: 'high',
    downtimeCostHourly: 7500
  },
  retail: {
    id: 'retail',
    name: 'Retail',
    description: 'Stores, e-commerce, and retail operations',
    keyRequirements: [
      'PCI compliance',
      'POS system security',
      'Customer Wi-Fi',
      'Supply chain security',
      'Multiple location management'
    ],
    complianceNeeds: ['PCI DSS', 'GDPR', 'CCPA'],
    keyMetrics: [
      'PCI compliance automation',
      'Multi-location management',
      'Cost efficiency',
      'Customer experience'
    ],
    recommendedVendors: ['portnox', 'fortinet', 'aruba', 'cisco'],
    deviceDensity: 3.5,
    wirelessPercentage: 75,
    byodPercentage: 20,
    iotPercentage: 35,
    securityPriority: 'medium',
    breachImpact: 'high',
    downtimeCostHourly: 5200
  },
  technology: {
    id: 'technology',
    name: 'Technology',
    description: 'IT companies, software vendors, and technology service providers',
    keyRequirements: [
      'Remote workforce support',
      'Development environment isolation',
      'Rapid scaling capabilities',
      'Cloud integration',
      'Advanced security controls'
    ],
    complianceNeeds: ['SOC 2', 'ISO 27001', 'GDPR', 'CCPA'],
    keyMetrics: [
      'Remote work enablement',
      'Operational efficiency',
      'Cloud integration',
      'Scalability'
    ],
    recommendedVendors: ['portnox', 'securew2', 'ivanti', 'forescout'],
    deviceDensity: 4.8,
    wirelessPercentage: 90,
    byodPercentage: 40,
    iotPercentage: 25,
    securityPriority: 'high',
    breachImpact: 'high',
    downtimeCostHourly: 9800
  },
  government: {
    id: 'government',
    name: 'Government',
    description: 'Federal, state, and local government agencies',
    keyRequirements: [
      'Strict access controls',
      'High security standards',
      'Compliance with government mandates',
      'Support for legacy systems',
      'Cost-effective deployment'
    ],
    complianceNeeds: ['FISMA', 'FedRAMP', 'NIST 800-53', 'CJIS'],
    keyMetrics: [
      'Compliance automation',
      'Security posture improvement',
      'Cost efficiency',
      'Audit readiness'
    ],
    recommendedVendors: ['cisco', 'forescout', 'aruba', 'microsoft'],
    deviceDensity: 2.8,
    wirelessPercentage: 45,
    byodPercentage: 10,
    iotPercentage: 20,
    securityPriority: 'critical',
    breachImpact: 'critical',
    downtimeCostHourly: 6500
  },
  other: {
    id: 'other',
    name: 'Other Industries',
    description: 'Other business sectors not specifically categorized',
    keyRequirements: [
      'Cost-effective deployment',
      'Ease of management',
      'Scalable solution',
      'Basic security controls'
    ],
    complianceNeeds: ['General security best practices'],
    keyMetrics: [
      'Cost efficiency',
      'Operational improvement',
      'Security enhancement'
    ],
    recommendedVendors: ['portnox', 'fortinet', 'aruba', 'microsoft'],
    deviceDensity: 3.0,
    wirelessPercentage: 60,
    byodPercentage: 25,
    iotPercentage: 20,
    securityPriority: 'medium',
    breachImpact: 'medium',
    downtimeCostHourly: 4500
  }
};

// Calculate default values based on industry profile
export const getIndustryDefaults = (industry: IndustryType, employeeCount: number) => {
  const profile = industryProfiles[industry];
  
  return {
    deviceCount: Math.ceil(employeeCount * profile.deviceDensity),
    wirelessPercentage: profile.wirelessPercentage,
    byodPercentage: profile.byodPercentage,
    iotPercentage: profile.iotPercentage,
    downtimeCostHourly: Math.ceil((profile.downtimeCostHourly * employeeCount) / 100),
    complianceNeeds: profile.complianceNeeds,
    recommendedVendors: profile.recommendedVendors
  };
};
EOL
  display_success "Created industry-specific data"
  
  # Create util functions
  cat > lib/utils/calculations.ts << EOL
// Utility functions for calculations and data formatting

import { 
  CostFactors, 
  ImplementationTimeline, 
  calculateTotalImplementationTime, 
  calculateInitialCosts, 
  calculateAnnualCosts,
  calculateTCO,
  calculateROI,
  calculatePaybackPeriod,
  calculateComplexityMultiplier
} from '@/lib/data/vendors';

// Format currency values
export const formatCurrency = (value: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: 0
  }).format(value);
};

// Format percentage values
export const formatPercentage = (value: number): string => {
  return \`${value.toFixed(1)}%\`;
};

// Format time periods
export const formatTimePeriod = (days: number): string => {
  if (days < 30) {
    return \`${days} days\`;
  } else if (days < 365) {
    const months = Math.round(days / 30);
    return \`${months} ${months === 1 ? 'month' : 'months'}\`;
  } else {
    const years = (days / 365).toFixed(1);
    return \`${years} ${parseFloat(years) === 1 ? 'year' : 'years'}\`;
  }
};

// Generate color for vendor
export const getVendorColor = (vendor: string, isPrimary: boolean = true): string => {
  const colors: Record<string, [string, string]> = {
    portnox: ['#2bd25b', '#0f432e'],
    cisco: ['#049fd9', '#005073'],
    aruba: ['#ff8300', '#c05f00'],
    forescout: ['#005daa', '#003c6e'],
    fortinet: ['#ee3124', '#b8291e'],
    securew2: ['#0072bc', '#00568d'],
    ivanti: ['#6f2c91', '#4b1e61'],
    microsoft: ['#0078d4', '#005a9e'],
  };
  
  if (colors[vendor]) {
    return isPrimary ? colors[vendor][0] : colors[vendor][1];
  }
  
  // Default fallback colors
  return isPrimary ? '#6b7280' : '#374151';
};

// Calculate TCO comparison results
export interface TcoResults {
  currentTCO: number;
  portnoxTCO: number;
  totalSavings: number;
  savingsPercentage: number;
  annualSavings: number;
  initialCostSavings: number;
  currentTotalInitialCosts: number;
  currentAnnualCosts: number;
  portnoxTotalInitialCosts: number;
  portnoxAnnualCosts: number;
  roi: number;
  paybackPeriod: number;
}

export interface ImplementationResults {
  currentImplTime: number;
  portnoxImplTime: number;
  implTimeSavings: number;
  implTimeSavingsPercentage: number;
}

export interface YearByYearData {
  year: string;
  current: number;
  portnox: number;
  savings: number;
  cumulativeSavings: number;
}

export interface CostBreakdownItem {
  name: string;
  value: number;
}

export interface CalculationInputs {
  currentSolution: string;
  organizationSize: string;
  deviceCount: number;
  yearsToProject: number;
  currentCostFactors: CostFactors;
  portnoxCostFactors: CostFactors;
  currentImplementation: ImplementationTimeline;
  portnoxImplementation: ImplementationTimeline;
  fteCost: number;
  downtimeCost: number;
  complexityFactors: {
    [key: string]: any;
  };
}

export const calculateResults = (inputs: CalculationInputs): {
  tcoResults: TcoResults;
  implementationResults: ImplementationResults;
  yearByYearComparisonData: YearByYearData[];
  costBreakdownCurrent: CostBreakdownItem[];
  costBreakdownPortnox: CostBreakdownItem[];
} => {
  // Calculate complexity multipliers
  const complexityMultiplier = calculateComplexityMultiplier(
    inputs.complexityFactors.networkComplexity || 'medium',
    inputs.complexityFactors.hasMultipleLocations || false,
    inputs.complexityFactors.locationCount || 1,
    inputs.complexityFactors.hasComplexAuthentication || false,
    inputs.complexityFactors.hasLegacyDevices || false,
    inputs.complexityFactors.percentLegacyDevices || 0,
    inputs.complexityFactors.hasCloudIntegration || false,
    inputs.complexityFactors.hasCustomPolicies || false,
    inputs.complexityFactors.policyComplexityLevel || 'medium'
  );
  
  // Apply a reduced complexity factor for Portnox
  const portnoxComplexityMultiplier = 1 + ((complexityMultiplier - 1) * 0.4); // 60% reduction in complexity impact
  
  // Calculate TCO for current solution
  const currentTotalInitialCosts = calculateInitialCosts(inputs.currentCostFactors) * complexityMultiplier;
  const currentAnnualCosts = calculateAnnualCosts(
    inputs.currentCostFactors,
    inputs.fteCost,
    inputs.downtimeCost
  ) * complexityMultiplier;
  const currentTCO = currentTotalInitialCosts + (currentAnnualCosts * inputs.yearsToProject);
  
  // Calculate TCO for Portnox
  const portnoxTotalInitialCosts = calculateInitialCosts(inputs.portnoxCostFactors) * portnoxComplexityMultiplier;
  const portnoxAnnualCosts = calculateAnnualCosts(
    inputs.portnoxCostFactors,
    inputs.fteCost,
    inputs.downtimeCost
  ) * portnoxComplexityMultiplier;
  const portnoxTCO = portnoxTotalInitialCosts + (portnoxAnnualCosts * inputs.yearsToProject);
  
  // Calculate savings
  const totalSavings = currentTCO - portnoxTCO;
  const savingsPercentage = (totalSavings / currentTCO) * 100;
  const annualSavings = (currentAnnualCosts - portnoxAnnualCosts);
  const initialCostSavings = currentTotalInitialCosts - portnoxTotalInitialCosts;
  
  // Calculate ROI and payback period
  const roi = (totalSavings / portnoxTCO) * 100;
  const paybackPeriod = annualSavings > 0 ? portnoxTotalInitialCosts / annualSavings : 999;
  
  // Build year by year comparison data
  const yearByYearComparisonData: YearByYearData[] = [];
  for (let year = 0; year <= inputs.yearsToProject; year++) {
    let currentYearCost = currentTotalInitialCosts;
    let portnoxYearCost = portnoxTotalInitialCosts;
    
    if (year > 0) {
      currentYearCost += currentAnnualCosts * year;
      portnoxYearCost += portnoxAnnualCosts * year;
    }
    
    yearByYearComparisonData.push({
      year: year === 0 ? 'Initial' : \`Year ${year}\`,
      current: currentYearCost,
      portnox: portnoxYearCost,
      savings: currentYearCost - portnoxYearCost,
      cumulativeSavings: year === 0 ? 
        (currentTotalInitialCosts - portnoxTotalInitialCosts) : 
        (currentTotalInitialCosts - portnoxTotalInitialCosts) + (currentAnnualCosts - portnoxAnnualCosts) * year
    });
  }
  
  // Build cost breakdown data
  const costBreakdownCurrent: CostBreakdownItem[] = [
    { name: 'Hardware', value: inputs.currentCostFactors.initialHardwareCost * complexityMultiplier },
    { name: 'Network Redesign', value: inputs.currentCostFactors.networkRedesignCost * complexityMultiplier },
    { name: 'Implementation', value: inputs.currentCostFactors.implementationServicesCost * complexityMultiplier },
    { name: 'Training', value: inputs.currentCostFactors.trainingCost * complexityMultiplier },
    { name: 'Maintenance', value: inputs.currentCostFactors.annualMaintenanceCost * inputs.yearsToProject * complexityMultiplier },
    { name: 'Licensing', value: inputs.currentCostFactors.annualLicensingCost * inputs.yearsToProject * complexityMultiplier },
    { name: 'IT Staff', value: inputs.fteCost * inputs.currentCostFactors.fteCount * inputs.yearsToProject * complexityMultiplier },
    { name: 'Downtime', value: inputs.downtimeCost * inputs.currentCostFactors.estimatedAnnualDowntimeHours * inputs.yearsToProject * complexityMultiplier }
  ];
  
  const costBreakdownPortnox: CostBreakdownItem[] = [
    { name: 'Hardware', value: inputs.portnoxCostFactors.initialHardwareCost * portnoxComplexityMultiplier },
    { name: 'Network Redesign', value: inputs.portnoxCostFactors.networkRedesignCost * portnoxComplexityMultiplier },
    { name: 'Implementation', value: inputs.portnoxCostFactors.implementationServicesCost * portnoxComplexityMultiplier },
    { name: 'Training', value: inputs.portnoxCostFactors.trainingCost * portnoxComplexityMultiplier },
    { name: 'Maintenance', value: inputs.portnoxCostFactors.annualMaintenanceCost * inputs.yearsToProject * portnoxComplexityMultiplier },
    { name: 'Licensing', value: inputs.portnoxCostFactors.annualLicensingCost * inputs.yearsToProject * portnoxComplexityMultiplier },
    { name: 'IT Staff', value: inputs.fteCost * inputs.portnoxCostFactors.fteCount * inputs.yearsToProject * portnoxComplexityMultiplier },
    { name: 'Downtime', value: inputs.downtimeCost * inputs.portnoxCostFactors.estimatedAnnualDowntimeHours * inputs.yearsToProject * portnoxComplexityMultiplier }
  ];
  
  // Calculate implementation time comparison
  const currentImplTime = calculateTotalImplementationTime(inputs.currentImplementation) * complexityMultiplier;
  const portnoxImplTime = calculateTotalImplementationTime(inputs.portnoxImplementation) * portnoxComplexityMultiplier;
  const implTimeSavings = currentImplTime - portnoxImplTime;
  const implTimeSavingsPercentage = (implTimeSavings / currentImplTime) * 100;
  
  const implementationResults: ImplementationResults = {
    currentImplTime,
    portnoxImplTime,
    implTimeSavings,
    implTimeSavingsPercentage
  };
  
  const tcoResults: TcoResults = {
    currentTCO,
    portnoxTCO,
    totalSavings,
    savingsPercentage,
    annualSavings,
    initialCostSavings,
    currentTotalInitialCosts,
    currentAnnualCosts,
    portnoxTotalInitialCosts,
    portnoxAnnualCosts,
    roi,
    paybackPeriod
  };
  
  return {
    tcoResults,
    implementationResults,
    yearByYearComparisonData,
    costBreakdownCurrent,
    costBreakdownPortnox
  };
};
EOL
  display_success "Created calculation utility functions"
}

# Function to create layout components
create_layout_components() {
  display_section "Creating Layout Components"
  
  # Create _app.js
  cat > pages/_app.js << EOL
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
EOL
  display_success "Created app component"
  
  # Create AppContext
  mkdir -p context
  cat > context/AppContext.js << EOL
import React, { createContext, useContext, useState, useEffect } from 'react';
import { 
  vendorDetails,
  vendorCosts,
  vendorImplementation,
  sizeBands
} from '../lib/data/vendors';

// Create context
const AppContext = createContext();

// Custom hook to use the app context
export const useAppContext = () => useContext(AppContext);

// Provider component
export const AppProvider = ({ children }) => {
  const [currentVendor, setCurrentVendor] = useState('cisco');
  const [organizationSize, setOrganizationSize] = useState('medium');
  const [deviceCount, setDeviceCount] = useState(1000);
  const [yearsToProject, setYearsToProject] = useState(3);
  const [industry, setIndustry] = useState('technology');
  
  // Advanced settings
  const [advancedSettingsOpen, setAdvancedSettingsOpen] = useState(false);
  const [customFactors, setCustomFactors] = useState({});
  
  // Set default device count when organization size changes
  useEffect(() => {
    setDeviceCount(sizeBands[organizationSize].default);
  }, [organizationSize]);
  
  const value = {
    // Vendor selection
    currentVendor,
    setCurrentVendor,
    
    // Organization information
    organizationSize,
    setOrganizationSize,
    deviceCount,
    setDeviceCount,
    yearsToProject,
    setYearsToProject,
    industry,
    setIndustry,
    
    // Advanced settings
    advancedSettingsOpen,
    setAdvancedSettingsOpen,
    customFactors,
    setCustomFactors,
    
    // Data access
    getVendorDetails: (vendorId) => vendorDetails[vendorId],
    getVendorCosts: (vendorId, size) => vendorCosts[vendorId][size],
    getVendorImplementation: (vendorId, size) => vendorImplementation[vendorId][size],
    
    // Size information
    sizeBands,
    
    // Vendors list
    vendorsList: Object.values(vendorDetails)
  };
  
  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
};
EOL
  display_success "Created AppContext"
  
  # Create Layout component
  mkdir -p components/layout
  cat > components/layout/Layout.js << EOL
import React, { useState } from 'react';
import { Header } from './Header';
import { Footer } from './Footer';
import { Sidebar } from './Sidebar';
import { MobileNav } from './MobileNav';

export const Layout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header onMenuClick={() => setSidebarOpen(true)} />
      
      <div className="flex flex-1 overflow-hidden">
        <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        
        <MobileNav isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        
        <main className="flex-1 overflow-y-auto p-4 md:p-8">
          {children}
        </main>
      </div>
      
      <Footer />
    </div>
  );
};
EOL
  display_success "Created Layout component"
  
  # Create Header component
  cat > components/layout/Header.js << EOL
import React from 'react';
import Link from 'next/link';
import { useAppContext } from '../../context/AppContext';

export const Header = ({ onMenuClick }) => {
  const { currentVendor, getVendorDetails } = useAppContext();
  const portnoxDetails = getVendorDetails('portnox');
  const currentVendorDetails = getVendorDetails(currentVendor);

  return (
    <header className="bg-white shadow-sm z-10">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex justify-between items-center">
          <div className="flex items-center space-x-4">
            {/* Mobile menu button */}
            <button 
              className="md:hidden -ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-portnox-primary"
              onClick={onMenuClick}
            >
              <span className="sr-only">Open main menu</span>
              <svg className="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
            
            {/* Logo */}
            <Link href="/" className="flex items-center space-x-2">
              <div className="h-10 w-10 relative overflow-hidden rounded-full bg-portnox-light flex items-center justify-center">
                <span className="text-portnox-primary font-bold text-lg">P</span>
              </div>
              <span className="hidden sm:inline-block text-xl font-semibold text-gray-800">
                NAC TCO & ROI Calculator
              </span>
            </Link>
          </div>
          
          <div className="hidden md:flex items-center space-x-4">
            <div className="flex items-center px-3 py-1 bg-gray-100 rounded-full">
              <span className="mr-2 text-sm text-gray-700">
                Comparing:
              </span>
              <div className="flex space-x-2 items-center">
                <div className="h-6 w-6 rounded-full bg-white p-0.5 flex items-center justify-center border border-gray-200">
                  <div 
                    className="h-full w-full rounded-full"
                    style={{ backgroundColor: currentVendorDetails.primaryColor }}
                  ></div>
                </div>
                <span className="text-sm font-medium">{currentVendorDetails.shortName}</span>
                <span className="text-gray-400">vs</span>
                <div className="h-6 w-6 rounded-full bg-white p-0.5 flex items-center justify-center border border-gray-200">
                  <div 
                    className="h-full w-full rounded-full"
                    style={{ backgroundColor: portnoxDetails.primaryColor }}
                  ></div>
                </div>
                <span className="text-sm font-medium">{portnoxDetails.shortName}</span>
              </div>
            </div>
            
            <nav className="flex space-x-4">
              <Link href="/" className="text-gray-700 hover:text-portnox-primary px-3 py-2 text-sm font-medium">
                Dashboard
              </Link>
              <Link href="/calculator" className="text-gray-700 hover:text-portnox-primary px-3 py-2 text-sm font-medium">
                Calculator
              </Link>
              <Link href="/comparison" className="text-gray-700 hover:text-portnox-primary px-3 py-2 text-sm font-medium">
                Comparison
              </Link>
              <Link href="/vendors" className="text-gray-700 hover:text-portnox-primary px-3 py-2 text-sm font-medium">
                Vendors
              </Link>
            </nav>
          </div>
          
          <div className="hidden md:block">
            <a 
              href="https://www.portnox.com/contact-sales/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-portnox-primary hover:bg-portnox-dark focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-portnox-dark"
            >
              Contact Sales
            </a>
          </div>
        </div>
      </div>
    </header>
  );
};
EOL
  display_success "Created Header component"
  
  # Create Footer component
  cat > components/layout/Footer.js << EOL
import React from 'react';

export const Footer = () => {
  return (
    <footer className="bg-gray-800 text-white py-8 print:hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="text-lg font-semibold mb-4">Portnox Cloud</h3>
            <p className="text-gray-300 text-sm">
              Cloud-native NAC solution with zero-trust approach, simplified deployment and minimal maintenance overhead.
            </p>
          </div>
          <div>
            <h3 className="text-lg font-semibold mb-4">Resources</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="https://www.portnox.com/resources/" className="text-gray-300 hover:text-portnox-primary">Resource Center</a></li>
              <li><a href="https://www.portnox.com/blog/" className="text-gray-300 hover:text-portnox-primary">Blog</a></li>
              <li><a href="https://www.portnox.com/webinars/" className="text-gray-300 hover:text-portnox-primary">Webinars</a></li>
              <li><a href="https://www.portnox.com/solution-briefs-datasheets/" className="text-gray-300 hover:text-portnox-primary">Solution Briefs</a></li>
            </ul>
          </div>
          <div>
            <h3 className="text-lg font-semibold mb-4">Contact</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="https://www.portnox.com/contact-sales/" className="text-gray-300 hover:text-portnox-primary">Contact Sales</a></li>
              <li><a href="https://www.portnox.com/request-demo/" className="text-gray-300 hover:text-portnox-primary">Request Demo</a></li>
              <li><a href="https://www.portnox.com/support/" className="text-gray-300 hover:text-portnox-primary">Support</a></li>
              <li><a href="https://www.portnox.com/partners/" className="text-gray-300 hover:text-portnox-primary">Partners</a></li>
            </ul>
			</div>
        </div>
        <div className="border-t border-gray-700 mt-8 pt-6 text-center text-gray-400 text-sm">
          <p>© {new Date().getFullYear()} Portnox. All rights reserved. This calculator provides estimates based on comprehensive research and customer data. Actual results may vary based on specific organizational requirements.</p>
        </div>
      </div>
    </footer>
  );
};
import React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/router';
import { useAppContext } from '../../context/AppContext';

export const Sidebar = ({ isOpen, onClose }) => {
  const router = useRouter();
  const { vendorsList, currentVendor, setCurrentVendor } = useAppContext();
  
  const isActive = (path) => router.pathname === path;
  
  const navigationItems = [
    { name: 'Dashboard', path: '/', icon: 'chart-bar' },
    { name: 'TCO Calculator', path: '/calculator', icon: 'calculator' },
    { name: 'Vendor Comparison', path: '/comparison', icon: 'switch-horizontal' },
    { name: 'Implementation Timeline', path: '/timeline', icon: 'clock' },
    { name: 'Vendor Profiles', path: '/vendors', icon: 'office-building' },
    { name: 'Reports', path: '/reports', icon: 'document-report' },
  ];

  return (
    <div className={`hidden md:block md:flex-shrink-0 transition-all duration-300 ease-in-out \${isOpen ? 'md:w-64' : 'md:w-20'}`}>
      <div className="h-full flex flex-col bg-white border-r border-gray-200">
        {/* Sidebar header */}
        <div className="h-16 flex items-center justify-center border-b border-gray-200">
          <button
            className="p-2 rounded-md text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-portnox-primary"
            onClick={onClose}
          >
            {isOpen ? (
              <svg className="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
              </svg>
            ) : (
              <svg className="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 5l7 7-7 7M5 5l7 7-7 7" />
              </svg>
            )}
          </button>
        </div>
        
        {/* Main navigation */}
        <nav className="flex-1 py-4 space-y-1 overflow-y-auto">
          {navigationItems.map((item) => (
            <Link
              key={item.name}
              href={item.path}
              className={`flex items-center px-4 py-3 \${
                isActive(item.path)
                  ? 'bg-portnox-light text-portnox-primary'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <div className="flex items-center">
                <IconByName name={item.icon} className="h-5 w-5 mr-3" />
                {isOpen && <span className="text-sm font-medium">{item.name}</span>}
              </div>
            </Link>
          ))}
        </nav>
        
        {/* Vendor selector */}
        {isOpen && (
          <div className="p-4 border-t border-gray-200">
            <h3 className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">
              Compare with Portnox
            </h3>
            <div className="space-y-2">
              {vendorsList.filter(v => v.id !== 'portnox').map((vendor) => (
                <button
                  key={vendor.id}
                  className={`flex items-center w-full px-3 py-2 text-sm font-medium rounded-md \${
                    currentVendor === vendor.id
                      ? 'bg-gray-100 text-gray-900'
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                  }`}
                  onClick={() => setCurrentVendor(vendor.id)}
                >
                  <div
                    className="h-4 w-4 rounded-full mr-2"
                    style={{ backgroundColor: vendor.primaryColor }}
                  ></div>
                  {vendor.shortName}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

// Helper component to render different icons
const IconByName = ({ name, className }) => {
  switch (name) {
    case 'chart-bar':
      return (
        <svg className={className} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
      );
    case 'calculator':
      return (
        <svg className={className} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
        </svg>
      );
    case 'switch-horizontal':
      return (
        <svg className={className} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
        </svg>
      );
    case 'clock':
      return (
        <svg className={className} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      );
    case 'office-building':
      return (
        <svg className={className} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
        </svg>
      );
    case 'document-report':
      return (
        <svg className={className} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      );
    default:
      return null;
  }
};
import React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/router';
import { useAppContext } from '../../context/AppContext';

export const MobileNav = ({ isOpen, onClose }) => {
  const router = useRouter();
  const { vendorsList, currentVendor, setCurrentVendor } = useAppContext();
  
  const isActive = (path) => router.pathname === path;
  
  if (!isOpen) return null;
  
  return (
    <div className="md:hidden fixed inset-0 z-40 flex">
      {/* Overlay */}
      <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={onClose}></div>
      
      {/* Sidebar panel */}
      <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
        <div className="absolute top-0 right-0 -mr-12 pt-2">
          <button
            className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
            onClick={onClose}
          >
            <span className="sr-only">Close sidebar</span>
            <svg className="h-6 w-6 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        
        <div className="pt-5 pb-4 flex-1 h-0 overflow-y-auto">
          {/* Logo */}
          <div className="flex-shrink-0 flex items-center px-4">
            <div className="h-10 w-10 relative overflow-hidden rounded-full bg-portnox-light flex items-center justify-center">
              <span className="text-portnox-primary font-bold text-lg">P</span>
            </div>
            <span className="ml-3 text-lg font-semibold text-gray-800">NAC Calculator</span>
          </div>
          
          {/* Navigation */}
          <nav className="mt-5 px-2 space-y-1">
            <Link
              href="/"
              className={`group flex items-center px-2 py-2 text-base font-medium rounded-md \${
                isActive('/') ? 'bg-portnox-light text-portnox-primary' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
              onClick={onClose}
            >
              <svg className="mr-4 h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
              Dashboard
            </Link>
            
            <Link
              href="/calculator"
              className={`group flex items-center px-2 py-2 text-base font-medium rounded-md \${
                isActive('/calculator') ? 'bg-portnox-light text-portnox-primary' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
              onClick={onClose}
            >
              <svg className="mr-4 h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
              </svg>
              TCO Calculator
            </Link>
            
            <Link
              href="/comparison"
              className={`group flex items-center px-2 py-2 text-base font-medium rounded-md \${
                isActive('/comparison') ? 'bg-portnox-light text-portnox-primary' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
              onClick={onClose}
            >
              <svg className="mr-4 h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
              </svg>
              Vendor Comparison
            </Link>
            
            <Link
              href="/timeline"
              className={`group flex items-center px-2 py-2 text-base font-medium rounded-md \${
                isActive('/timeline') ? 'bg-portnox-light text-portnox-primary' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
              onClick={onClose}
            >
              <svg className="mr-4 h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              Implementation Timeline
            </Link>
            
            <Link
              href="/vendors"
              className={`group flex items-center px-2 py-2 text-base font-medium rounded-md \${
                isActive('/vendors') ? 'bg-portnox-light text-portnox-primary' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
              onClick={onClose}
            >
              <svg className="mr-4 h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
              </svg>
              Vendor Profiles
            </Link>
            
            <Link
              href="/reports"
              className={`group flex items-center px-2 py-2 text-base font-medium rounded-md \${
                isActive('/reports') ? 'bg-portnox-light text-portnox-primary' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
              onClick={onClose}
            >
              <svg className="mr-4 h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              Reports
            </Link>
          </nav>
          
          {/* Vendor selection */}
          <div className="mt-6 px-2">
            <h3 className="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">
              Compare with Portnox
            </h3>
            <div className="mt-2 space-y-1">
              {vendorsList.filter(v => v.id !== 'portnox').map((vendor) => (
                <button
                  key={vendor.id}
                  className={`w-full flex items-center px-3 py-2 text-sm font-medium rounded-md \${
                    currentVendor === vendor.id ? 'bg-gray-100 text-gray-900' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                  }`}
                  onClick={() => {
                    setCurrentVendor(vendor.id);
                    onClose();
                  }}
                >
                  <div
                    className="h-4 w-4 rounded-full mr-2"
                    style={{ backgroundColor: vendor.primaryColor }}
                  ></div>
                  {vendor.shortName}
                </button>
              ))}
            </div>
          </div>
        </div>
        
        {/* Contact Sales button */}
        <div className="flex-shrink-0 flex border-t border-gray-200 p-4">
          <a
            href="https://www.portnox.com/contact-sales/"
            target="_blank"
            rel="noopener noreferrer"
            className="flex-shrink-0 w-full flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-portnox-primary hover:bg-portnox-dark"
          >
            Contact Sales
          </a>
        </div>
      </div>
    </div>
  );
};
import React from 'react';
import Link from 'next/link';
import { useAppContext } from '../context/AppContext';
import { getVendorColor, formatCurrency, formatPercentage } from '../lib/utils/calculations';

export default function Home() {
  const { currentVendor, getVendorDetails, organizationSize, deviceCount, yearsToProject } = useAppContext();
  
  const currentVendorDetails = getVendorDetails(currentVendor);
  const portnoxDetails = getVendorDetails('portnox');
  
  return (
    <div className="max-w-7xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">NAC Solutions Comparison Dashboard</h1>
        <p className="mt-2 text-lg text-gray-600">
          Compare total cost of ownership and implementation timelines between Portnox Cloud and traditional NAC solutions
        </p>
      </div>
      
      <div className="bg-white rounded-xl shadow-lg overflow-hidden mb-8">
        <div className="px-6 py-5 border-b border-gray-200">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-800">Current Comparison</h2>
            <Link 
              href="/calculator" 
              className="text-sm text-portnox-primary hover:text-portnox-dark font-medium"
            >
              Customize Calculation
            </Link>
          </div>
        </div>
        
        <div className="px-6 py-5">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="bg-white border border-gray-200 rounded-lg p-4 flex items-center">
              <div 
                className="h-12 w-12 rounded-md flex items-center justify-center mr-4"
                style={{ backgroundColor: portnoxDetails.primaryColor }}
              >
                <svg className="h-6 w-6 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
              </div>
              <div>
                <div className="text-sm text-gray-500">Comparing</div>
                <div className="text-lg font-semibold">{portnoxDetails.name} vs {currentVendorDetails.name}</div>
              </div>
            </div>
            
            <div className="bg-white border border-gray-200 rounded-lg p-4 flex items-center">
              <div className="h-12 w-12 rounded-md bg-blue-100 flex items-center justify-center mr-4">
                <svg className="h-6 w-6 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <div>
                <div className="text-sm text-gray-500">Organization Size</div>
                <div className="text-lg font-semibold capitalize">{organizationSize} ({deviceCount} devices)</div>
              </div>
            </div>
            
            <div className="bg-white border border-gray-200 rounded-lg p-4 flex items-center">
              <div className="h-12 w-12 rounded-md bg-green-100 flex items-center justify-center mr-4">
                <svg className="h-6 w-6 text-green-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <div className="text-sm text-gray-500">Analysis Period</div>
                <div className="text-lg font-semibold">{yearsToProject} {yearsToProject === 1 ? 'Year' : 'Years'}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
        {/* Key Metrics Summary */}
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="px-6 py-5 border-b border-gray-200">
            <h2 className="text-xl font-semibold text-gray-800">Key Metrics</h2>
          </div>
          
          <div className="px-6 py-5">
            <div className="space-y-6">
              <div>
                <div className="flex justify-between mb-2">
                  <div className="text-sm font-medium text-gray-500">TCO Savings</div>
                  <div className="text-sm font-medium text-green-600">40-60%</div>
                </div>
                <div className="bg-gray-200 rounded-full h-2">
                  <div className="bg-green-500 h-2 rounded-full" style={{ width: '55%' }}></div>
                </div>
              </div>
              
              <div>
                <div className="flex justify-between mb-2">
                  <div className="text-sm font-medium text-gray-500">Implementation Time Reduction</div>
                  <div className="text-sm font-medium text-green-600">70-85%</div>
                </div>
                <div className="bg-gray-200 rounded-full h-2">
                  <div className="bg-green-500 h-2 rounded-full" style={{ width: '80%' }}></div>
                </div>
              </div>
              
              <div>
                <div className="flex justify-between mb-2">
                  <div className="text-sm font-medium text-gray-500">Annual Operational Cost Reduction</div>
                  <div className="text-sm font-medium text-green-600">30-50%</div>
                </div>
                <div className="bg-gray-200 rounded-full h-2">
                  <div className="bg-green-500 h-2 rounded-full" style={{ width: '45%' }}></div>
                </div>
              </div>
              
              <div>
                <div className="flex justify-between mb-2">
                  <div className="text-sm font-medium text-gray-500">Hardware Cost Elimination</div>
                  <div className="text-sm font-medium text-green-600">100%</div>
                </div>
                <div className="bg-gray-200 rounded-full h-2">
                  <div className="bg-green-500 h-2 rounded-full" style={{ width: '100%' }}></div>
                </div>
              </div>
              
              <div>
                <div className="flex justify-between mb-2">
                  <div className="text-sm font-medium text-gray-500">Return on Investment (ROI)</div>
                  <div className="text-sm font-medium text-green-600">150-300%</div>
                </div>
                <div className="bg-gray-200 rounded-full h-2">
                  <div className="bg-green-500 h-2 rounded-full" style={{ width: '75%' }}></div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        {/* Feature Comparison */}
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="px-6 py-5 border-b border-gray-200">
            <h2 className="text-xl font-semibold text-gray-800">Feature Comparison</h2>
          </div>
          
          <div className="px-6 py-5">
            <div className="space-y-4">
              <div className="grid grid-cols-3 gap-4">
                <div className="col-span-1"></div>
                <div className="col-span-1 text-center">
                  <div 
                    className="h-8 w-8 rounded-full mx-auto"
                    style={{ backgroundColor: currentVendorDetails.primaryColor }}
                  ></div>
                  <div className="text-sm font-medium mt-1">{currentVendorDetails.shortName}</div>
                </div>
                <div className="col-span-1 text-center">
                  <div 
                    className="h-8 w-8 rounded-full mx-auto"
                    style={{ backgroundColor: portnoxDetails.primaryColor }}
                  ></div>
                  <div className="text-sm font-medium mt-1">{portnoxDetails.shortName}</div>
                </div>
              </div>
              
              <div className="border-t border-gray-200 pt-4">
                <div className="grid grid-cols-3 gap-4 mb-2">
                  <div className="col-span-1 text-sm font-medium">Cloud-Native</div>
                  <div className="col-span-1 text-center">
                    {currentVendorDetails.hasCloudOption ? (
                      <svg className="h-5 w-5 mx-auto text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    ) : (
                      <svg className="h-5 w-5 mx-auto text-red-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    )}
                  </div>
                  <div className="col-span-1 text-center">
                    <svg className="h-5 w-5 mx-auto text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                </div>
                
                <div className="grid grid-cols-3 gap-4 mb-2">
                  <div className="col-span-1 text-sm font-medium">Zero Hardware</div>
                  <div className="col-span-1 text-center">
                    {!currentVendorDetails.hasOnPremOption ? (
                      <svg className="h-5 w-5 mx-auto text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    ) : (
                      <svg className="h-5 w-5 mx-auto text-red-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    )}
                  </div>
                  <div className="col-span-1 text-center">
                    <svg className="h-5 w-5 mx-auto text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                </div>
                
                <div className="grid grid-cols-3 gap-4 mb-2">
                  <div className="col-span-1 text-sm font-medium">Automated Updates</div>
                  <div className="col-span-1 text-center">
                    {currentVendorDetails.id === 'forescout' || currentVendorDetails.id === 'securew2' || currentVendorDetails.id === 'ivanti' ? (
                      <div className="text-xs text-center">Partial</div>
                    ) : (
                      <svg className="h-5 w-5 mx-auto text-red-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    )}
                  </div>
                  <div className="col-span-1 text-center">
                    <svg className="h-5 w-5 mx-auto text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                </div>
                
                <div className="grid grid-cols-3 gap-4 mb-2">
                  <div className="col-span-1 text-sm font-medium">Simple Licensing</div>
                  <div className="col-span-1 text-center">
                    {currentVendorDetails.id === 'securew2' ? (
                      <svg className="h-5 w-5 mx-auto text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    ) : (
                      <svg className="h-5 w-5 mx-auto text-red-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    )}
                  </div>
                  <div className="col-span-1 text-center">
                    <svg className="h-5 w-5 mx-auto text-green-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                </div>
                
                <div className="grid grid-cols-3 gap-4">
                  <div className="col-span-1 text-sm font-medium">Remote Access</div>
                  <div className="col-span-1 text-center">
                    {currentVendorDetails.id === 'forescout' || currentVendorDetails.id === 'securew2' || currentVendorDetails.id === 'ivanti' ? (
                      <div className="text-xs text-center">Good</div>
                    ) : (
                      <div className="text-xs text-center">Limited</div>
                    )}
                  </div>
                  <div className="col-span-1 text-center">
                    <div className="text-xs text-center">Excellent</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="px-6 py-5 border-b border-gray-200 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-800">TCO Analysis</h2>
            <Link 
              href="/calculator" 
              className="text-sm text-portnox-primary hover:text-portnox-dark font-medium"
            >
              Details
            </Link>
          </div>
          
          <div className="px-6 py-5">
            <div className="flex flex-col items-center">
              <div className="text-4xl font-bold text-green-600">40-60%</div>
              <div className="text-lg text-gray-500 mb-4">Lower TCO</div>
              
              <svg className="h-24 w-24 text-green-500 mb-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              
              <Link 
                href="/calculator" 
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-portnox-primary hover:bg-portnox-dark focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-portnox-primary"
              >
                Calculate Your Savings
              </Link>
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="px-6 py-5 border-b border-gray-200 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-800">Implementation Time</h2>
            <Link 
              href="/timeline" 
              className="text-sm text-portnox-primary hover:text-portnox-dark font-medium"
            >
              Details
            </Link>
          </div>
          
          <div className="px-6 py-5">
            <div className="flex flex-col items-center">
              <div className="text-4xl font-bold text-green-600">70-85%</div>
              <div className="text-lg text-gray-500 mb-4">Faster Deployment</div>
              
              <svg className="h-24 w-24 text-green-500 mb-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              
              <Link 
                href="/timeline" 
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-portnox-primary hover:bg-portnox-dark focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-portnox-primary"
              >
                View Timeline Comparison
              </Link>
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="px-6 py-5 border-b border-gray-200 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-800">Feature Comparison</h2>
            <Link 
              href="/comparison" 
              className="text-sm text-portnox-primary hover:text-portnox-dark font-medium"
            >
              Details
            </Link>
          </div>
          
          <div className="px-6 py-5">
            <div className="flex flex-col items-center">
              <div className="text-4xl font-bold text-green-600">12+</div>
              <div className="text-lg text-gray-500 mb-4">Key Advantages</div>
              
              <svg className="h-24 w-24 text-green-500 mb-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
              
              <Link 
                href="/comparison" 
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-portnox-primary hover:bg-portnox-dark focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-portnox-primary"
              >
                See Full Comparison
              </Link>
            </div>
          </div>
        </div>
      </div>
      
      <div className="bg-white rounded-xl shadow-lg overflow-hidden mb-8">
        <div className="px-6 py-5 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-800">All NAC Vendors Compared</h2>
        </div>
        
        <div className="px-6 py-5">
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
            {Object.values(getVendorDetails).map((vendor) => (
              <div key={vendor.id} className="border border-gray-200 rounded-lg p-4 text-center">
                <div 
                  className="h-12 w-12 rounded-full mx-auto"
                  style={{ backgroundColor: vendor.primaryColor }}
                ></div>
                <div className="mt-3 font-medium">{vendor.shortName}</div>
                <div className="text-xs text-gray-500">{vendor.productName}</div>
              </div>
            ))}
          </div>
          
          <div className="mt-6 text-center">
            <Link 
              href="/vendors" 
              className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-portnox-primary"
            >
              View All Vendor Profiles
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
import React, { useState } from 'react';
import { useAppContext } from '../context/AppContext';
import { calculateResults, formatCurrency, formatPercentage } from '../lib/utils/calculations';

export default function Calculator() {
  const { 
    currentVendor, 
    setCurrentVendor,
    getVendorDetails,
    getVendorCosts,
    getVendorImplementation,
    organizationSize,
    setOrganizationSize,
    deviceCount,
    setDeviceCount,
    yearsToProject,
    setYearsToProject,
    sizeBands,
    vendorsList
  } = useAppContext();
  
  const [fteCost, setFteCost] = useState(120000); // Annual FTE cost
  const [downtimeCost, setDowntimeCost] = useState(5000); // Hourly downtime cost
  const [activeTab, setActiveTab] = useState('tco');
  const [showAdvancedSettings, setShowAdvancedSettings] = useState(false);
  const [customFactors, setCustomFactors] = useState({
    networkComplexity: 'medium',
    hasMultipleLocations: false,
    locationCount: 1,
    hasComplexAuthentication: false,
    hasLegacyDevices: false,
    percentLegacyDevices: 10,
    hasCloudIntegration: false,
    hasCustomPolicies: false,
    policyComplexityLevel: 'medium'
  });
  
  // Get vendor details and data
  const currentVendorDetails = getVendorDetails(currentVendor);
  const portnoxDetails = getVendorDetails('portnox');
  
  // Get cost factors
  const currentCostFactors = getVendorCosts(currentVendor, organizationSize);
  const portnoxCostFactors = getVendorCosts('portnox', organizationSize);
  
  // Get implementation timelines
  const currentImplementation = getVendorImplementation(currentVendor, organizationSize);
  const portnoxImplementation = getVendorImplementation('portnox', organizationSize);
  
  // Calculate results
  const calculationInputs = {
    currentSolution: currentVendor,
    organizationSize,
    deviceCount,
    yearsToProject,
    currentCostFactors,
    portnoxCostFactors,
    currentImplementation,
    portnoxImplementation,
    fteCost,
    downtimeCost,
    complexityFactors: customFactors
  };
  
  const { tcoResults, implementationResults, yearByYearComparisonData, costBreakdownCurrent, costBreakdownPortnox } = 
    calculateResults(calculationInputs);
  
  return (
    <div className="max-w-7xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">TCO & ROI Calculator</h1>
        <p className="mt-2 text-lg text-gray-600">
          Compare costs between traditional NAC solutions and Portnox Cloud
        </p>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {/* Configuration column */}
        <div className="md:col-span-1">
          <div className="bg-white rounded-xl shadow-lg overflow-hidden mb-8">
            <div className="px-6 py-5 border-b border-gray-200">
              <h2 className="text-xl font-semibold text-gray-800">Calculator Configuration</h2>
            </div>
            
            <div className="px-6 py-5 space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Compare Portnox with
                </label>
                <select
                  className="form-select w-full"
                  value={currentVendor}
                  onChange={(e) => setCurrentVendor(e.target.value)}
                >
                  {vendorsList.filter(v => v.id !== 'portnox').map(vendor => (
                    <option key={vendor.id} value={vendor.id}>{vendor.name} ({vendor.productName})</option>
                  ))}
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Organization Size
                </label>
                <select
                  className="form-select w-full"
                  value={organizationSize}
                  onChange={(e) => setOrganizationSize(e.target.value)}
                >
                  <option value="small">Small (1-500 devices)</option>
                  <option value="medium">Medium (501-2,500 devices)</option>
                  <option value="large">Large (2,501-10,000 devices)</option>
                  <option value="enterprise">Enterprise (10,001+ devices)</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Number of Devices
                </label>
                <input
                  type="number"
                  className="form-input w-full"
                  value={deviceCount}
                  onChange={(e) => setDeviceCount(parseInt(e.target.value) || 0)}
                  min={sizeBands[organizationSize].min}
                  max={sizeBands[organizationSize].max}
                />
                <div className="mt-1 text-xs text-gray-500">
                  Range: {sizeBands[organizationSize].min} - {sizeBands[organizationSize].max}
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Years to Project
                </label>
                <select
                  className="form-select w-full"
                  value={yearsToProject}
                  onChange={(e) => setYearsToProject(parseInt(e.target.value))}
                >
                  <option value="1">1 Year</option>
                  <option value="2">2 Years</option>
                  <option value="3">3 Years</option>
                  <option value="5">5 Years</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  IT Staff Annual Cost ($)
                </label>
                <input
                  type="number"
                  className="form-input w-full"
                  value={fteCost}
                  onChange={(e) => setFteCost(parseInt(e.target.value) || 0)}
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Hourly Downtime Cost ($)
                </label>
                <input
                  type="number"
                  className="form-input w-full"
                  value={downtimeCost}
                  onChange={(e) => setDowntimeCost(parseInt(e.target.value) || 0)}
                />
              </div>
              
              <div>
                <button
                  className="w-full flex justify-between items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-portnox-primary"
                  onClick={() => setShowAdvancedSettings(!showAdvancedSettings)}
                >
                  <span>Advanced Settings</span>
                  <svg
                    className={`h-5 w-5 transform \${showAdvancedSettings ? 'rotate-180' : ''}`}
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </button>
                
                {showAdvancedSettings && (
                  <div className="mt-4 space-y-4 p-4 border border-gray-200 rounded-md bg-gray-50">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Network Complexity
                      </label>
                      <select
                        className="form-select w-full"
                        value={customFactors.networkComplexity}
                        onChange={(e) => setCustomFactors({...customFactors, networkComplexity: e.target.value})}
                      >
                        <option value="low">Low</option>
                        <option value="medium">Medium</option>
                        <option value="high">High</option>
                      </select>
                    </div>
                    
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        id="multipleLocations"
                        className="form-checkbox"
                        checked={customFactors.hasMultipleLocations}
                        onChange={(e) => setCustomFactors({...customFactors, hasMultipleLocations: e.target.checked})}
                      />
                      <label htmlFor="multipleLocations" className="ml-2 block text-sm text-gray-700">
                        Multiple Physical Locations
                      </label>
                    </div>
                    
                    {customFactors.hasMultipleLocations && (
                      <div className="ml-6">
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Number of Locations
                        </label>
                        <input
                          type="number"
                          className="form-input w-full"
                          value={customFactors.locationCount}
                          onChange={(e) => setCustomFactors({...customFactors, locationCount: Math.max(1, parseInt(e.target.value) || 1)})}
                          min="1"
                        />
                      </div>
                    )}
                    
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        id="complexAuth"
                        className="form-checkbox"
                        checked={customFactors.hasComplexAuthentication}
                        onChange={(e) => setCustomFactors({...customFactors, hasComplexAuthentication: e.target.checked})}
                      />
                      <label htmlFor="complexAuth" className="ml-2 block text-sm text-gray-700">
                        Complex Authentication Requirements
                      </label>
                    </div>
                    
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        id="legacyDevices"
                        className="form-checkbox"
                        checked={customFactors.hasLegacyDevices}
                        onChange={(e) => setCustomFactors({...customFactors, hasLegacyDevices: e.target.checked})}
                      />
                      <label htmlFor="legacyDevices" className="ml-2 block text-sm text-gray-700">
                        Legacy Devices to Support
                      </label>
                    </div>
                    
                    {customFactors.hasLegacyDevices && (
                      <div className="ml-6">
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Percentage of Legacy Devices
                        </label>
                        <div className="flex items-center">
                          <input
                            type="range"
                            className="w-full mr-2"
                            min="1"
                            max="100"
                            value={customFactors.percentLegacyDevices}
                            onChange={(e) => setCustomFactors({...customFactors, percentLegacyDevices: parseInt(e.target.value)})}
                          />
                          <span className="text-sm w-10 text-right">{customFactors.percentLegacyDevices}%</span>
                        </div>
                      </div>
                    )}
                    
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        id="cloudIntegration"
                        className="form-checkbox"
                        checked={customFactors.hasCloudIntegration}
                        onChange={(e) => setCustomFactors({...customFactors, hasCloudIntegration: e.target.checked})}
                      />
                      <label htmlFor="cloudIntegration" className="ml-2 block text-sm text-gray-700">
                        Cloud Service Integrations
                      </label>
                    </div>
                    
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        id="customPolicies"
                        className="form-checkbox"
                        checked={customFactors.hasCustomPolicies}
                        onChange={(e) => setCustomFactors({...customFactors, hasCustomPolicies: e.target.checked})}
                      />
                      <label htmlFor="customPolicies" className="ml-2 block text-sm text-gray-700">
                        Custom Security Policies
                      </label>
                    </div>
                    
                    {customFactors.hasCustomPolicies && (
                      <div className="ml-6">
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Policy Complexity Level
                        </label>
                        <select
                          className="form-select w-full"
                          value={customFactors.policyComplexityLevel}
                          onChange={(e) => setCustomFactors({...customFactors, policyComplexityLevel: e.target.value})}
                        >
                          <option value="low">Low</option>
                          <option value="medium">Medium</option>
                          <option value="high">High</option>
                        </select>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
        
        {/* Results column */}
        <div className="md:col-span-2">
          <div className="bg-white rounded-xl shadow-lg overflow-hidden mb-8">
            <div className="border-b border-gray-200">
              <nav className="-mb-px flex">
                <button
                  className={`w-1/3 py-4 px-1 text-center border-b-2 font-medium text-sm \${
                    activeTab === 'tco'
                      ? 'border-portnox-primary text-portnox-primary'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                  onClick={() => setActiveTab('tco')}
                >
                  TCO Results
                </button>
                <button
                  className={`w-1/3 py-4 px-1 text-center border-b-2 font-medium text-sm \${
                    activeTab === 'timeline'
                      ? 'border-portnox-primary text-portnox-primary'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                  onClick={() => setActiveTab('timeline')}
                >
                  Implementation Timeline
                </button>
                <button
                  className={`w-1/3 py-4 px-1 text-center border-b-2 font-medium text-sm \${
                    activeTab === 'roi'
                      ? 'border-portnox-primary text-portnox-primary'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                  onClick={() => setActiveTab('roi')}
                >
                  ROI Analysis
                </button>
              </nav>
            </div>
            
            <div className="p-6">
              {activeTab === 'tco' && (
                <div>
                  <div className="flex justify-between items-center mb-6">
                    <h2 className="text-lg font-semibold">Total Cost of Ownership Analysis</h2>
                    <div className="text-sm text-gray-500">{yearsToProject}-year projection</div>
                  </div>
                  
                  <div className="bg-blue-50 p-4 rounded-lg mb-6">
                    <h3 className="text-md font-medium text-blue-800 mb-2">
                      TCO Summary
                    </h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm text-gray-600">{currentVendorDetails.name} TCO:</p>
                        <p className="text-xl font-bold">{formatCurrency(tcoResults.currentTCO)}</p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Portnox Cloud TCO:</p>
                        <p className="text-xl font-bold">{formatCurrency(tcoResults.portnoxTCO)}</p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Total Savings:</p>
                        <p className="text-xl font-bold text-green-600">
                          {formatCurrency(tcoResults.totalSavings)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Savings Percentage:</p>
                        <p className="text-xl font-bold text-green-600">
                          {formatPercentage(tcoResults.savingsPercentage)}
                        </p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-gray-50 p-4 rounded-lg mb-6">
                    <h3 className="text-md font-medium text-gray-800 mb-2">
                      Financial Metrics
                    </h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm text-gray-600">Return on Investment (ROI):</p>
                        <p className="text-xl font-bold text-blue-600">
                          {formatPercentage(tcoResults.roi)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Payback Period:</p>
                        <p className="text-xl font-bold text-blue-600">
                          {tcoResults.paybackPeriod < 100 ? 
                            `\${tcoResults.paybackPeriod.toFixed(1)} years` : 
                            'N/A'}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Annual Operational Savings:</p>
                        <p className="text-xl font-bold text-green-600">
                          {formatCurrency(tcoResults.annualSavings)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Initial Cost Savings:</p>
                        <p className="text-xl font-bold text-green-600">
                          {formatCurrency(tcoResults.initialCostSavings)}
                        </p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="mb-6">
                    <h3 className="text-md font-medium text-gray-800 mb-2">
                      Year by Year Comparison
                    </h3>
                    <div className="bg-white border border-gray-200 rounded-lg overflow-hidden">
                      <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                          <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              Year
                            </th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              {currentVendorDetails.name}
                            </th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              Portnox Cloud
                            </th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                              Savings
                            </th>
                          </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                          {yearByYearComparisonData.map((yearData, index) => (
                            <tr key={index} className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
                              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                {yearData.year}
                              </td>
                              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {formatCurrency(yearData.current)}
                              </td>
                              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {formatCurrency(yearData.portnox)}
                              </td>
                              <td className="px-6 py-4 whitespace-nowrap text-sm text-green-600 font-medium">
                                {formatCurrency(yearData.savings)}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              )}
              
              {activeTab === 'timeline' && (
                <div>
                  <div className="flex justify-between items-center mb-6">
                    <h2 className="text-lg font-semibold">Implementation Timeline Analysis</h2>
                  </div>
                  
                  <div className="bg-blue-50 p-4 rounded-lg mb-6">
                    <h3 className="text-md font-medium text-blue-800 mb-2">Timeline Comparison</h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm text-gray-600">{currentVendorDetails.name} Implementation:</p>
                        <p className="text-xl font-bold">
                          {implementationResults.currentImplTime.toFixed(0)} days
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Portnox Cloud Implementation:</p>
                        <p className="text-xl font-bold">
                          {implementationResults.portnoxImplTime.toFixed(0)} days
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Time Saved:</p>
                        <p className="text-xl font-bold text-green-600">
                          {implementationResults.implTimeSavings.toFixed(0)} days
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Time Saved Percentage:</p>
                        <p className="text-xl font-bold text-green-600">
                          {implementationResults.implTimeSavingsPercentage.toFixed(1)}%
                        </p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-indigo-50 p-4 rounded-lg mb-6">
                    <h3 className="text-md font-medium text-indigo-800 mb-2">Business Impact of Faster Implementation</h3>
                    <ul className="space-y-2 text-sm">
                      <li className="flex items-start">
                        <span className="text-green-500 mr-2">✓</span>
                        <span>
                          Faster time to security with <strong>{implementationResults.implTimeSavingsPercentage.toFixed(0)}%</strong> reduction in vulnerabilities during transition
                        </span>
                      </li>
                      <li className="flex items-start">
                        <span className="text-green-500 mr-2">✓</span>
                        <span>
                          <strong>{implementationResults.implTimeSavings.toFixed(0)} days</strong> of additional productive IT staff time for other projects
                        </span>
                      </li>
                      <li className="flex items-start">
                        <span className="text-green-500 mr-2">✓</span>
                        <span>
                          <strong>{formatCurrency(implementationResults.implTimeSavings * 8 * 150)}</strong> approximate value of saved implementation resources (based on average IT hourly rates)
                        </span>
                      </li>
                      <li className="flex items-start">
                        <span className="text-green-500 mr-2">✓</span>
                        <span>
                          <strong>Reduced business disruption</strong> with minimal network changes and downtime
                        </span>
                      </li>
                      <li className="flex items-start">
                        <span className="text-green-500 mr-2">✓</span>
                        <span>
                          <strong>Faster ROI</strong> through immediate deployment of security controls
                        </span>
                      </li>
                    </ul>
                  </div>
                </div>
              )}
              
              {activeTab === 'roi' && (
                <div>
                  <div className="flex justify-between items-center mb-6">
                    <h2 className="text-lg font-semibold">ROI Analysis</h2>
                  </div>
                  
                  <div className="bg-green-50 p-4 rounded-lg mb-6">
                    <h3 className="text-md font-medium text-green-800 mb-2">
                      Return on Investment Summary
                    </h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm text-gray-600">ROI ({yearsToProject} years):</p>
                        <p className="text-xl font-bold text-green-600">
                          {formatPercentage(tcoResults.roi)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Payback Period:</p>
                        <p className="text-xl font-bold text-blue-600">
                          {tcoResults.paybackPeriod < 100 ? 
                            `\${tcoResults.paybackPeriod.toFixed(1)} years` : 
                            'N/A'}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Total Savings:</p>
                        <p className="text-xl font-bold text-green-600">
                          {formatCurrency(tcoResults.totalSavings)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-600">Investment Cost:</p>
                        <p className="text-xl font-bold">
                          {formatCurrency(tcoResults.portnoxTCO)}
                        </p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-gray-50 p-4 rounded-lg mb-6">
                    <h3 className="text-md font-medium text-gray-800 mb-2">
                      Cost Reduction Breakdown
                    </h3>
                    <div className="space-y-4">
                      <div>
                        <div className="flex justify-between mb-1">
                          <div className="text-sm font-medium">Hardware Savings</div>
                          <div className="text-sm font-medium text-green-600">
                            {formatCurrency(currentCostFactors.initialHardwareCost)}
                          </div>
                        </div>
                        <div className="bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-green-500 h-2 rounded-full" 
                            style={{ 
                              width: `\${(currentCostFactors.initialHardwareCost / tcoResults.totalSavings) * 100}%` 
                            }}
                          ></div>
                        </div>
                      </div>
                      
                      <div>
                        <div className="flex justify-between mb-1">
                          <div className="text-sm font-medium">Maintenance Savings</div>
                          <div className="text-sm font-medium text-green-600">
                            {formatCurrency((currentCostFactors.annualMaintenanceCost - portnoxCostFactors.annualMaintenanceCost) * yearsToProject)}
                          </div>
                        </div>
                        <div className="bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-green-500 h-2 rounded-full" 
                            style={{ 
                              width: `\${((currentCostFactors.annualMaintenanceCost - portnoxCostFactors.annualMaintenanceCost) * yearsToProject / tcoResults.totalSavings) * 100}%` 
                            }}
                          ></div>
                        </div>
                      </div>
                      
                      <div>
                        <div className="flex justify-between mb-1">
                          <div className="text-sm font-medium">IT Staff Savings</div>
                          <div className="text-sm font-medium text-green-600">
                            {formatCurrency(fteCost * (currentCostFactors.fteCount - portnoxCostFactors.fteCount) * yearsToProject)}
                          </div>
                        </div>
                        <div className="bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-green-500 h-2 rounded-full" 
                            style={{ 
                              width: `\${(fteCost * (currentCostFactors.fteCount - portnoxCostFactors.fteCount) * yearsToProject / tcoResults.totalSavings) * 100}%` 
                            }}
                          ></div>
                        </div>
                      </div>
                      
                      <div>
                        <div className="flex justify-between mb-1">
                          <div className="text-sm font-medium">Downtime Reduction Savings</div>
                          <div className="text-sm font-medium text-green-600">
                            {formatCurrency(downtimeCost * (currentCostFactors.estimatedAnnualDowntimeHours - portnoxCostFactors.estimatedAnnualDowntimeHours) * yearsToProject)}
                          </div>
                        </div>
                        <div className="bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-green-500 h-2 rounded-full" 
                            style={{ 
                              width: `\${(downtimeCost * (currentCostFactors.estimatedAnnualDowntimeHours - portnoxCostFactors.estimatedAnnualDowntimeHours) * yearsToProject / tcoResults.totalSavings) * 100}%` 
                            }}
                          ></div>
                        </div>
                      </div>
                      
                      <div>
                        <div className="flex justify-between mb-1">
                          <div className="text-sm font-medium">Implementation Savings</div>
                          <div className="text-sm font-medium text-green-600">
                            {formatCurrency(
                              (currentCostFactors.implementationServicesCost - portnoxCostFactors.implementationServicesCost) +
                              (currentCostFactors.trainingCost - portnoxCostFactors.trainingCost) +
                              (currentCostFactors.networkRedesignCost - portnoxCostFactors.networkRedesignCost)
                            )}
                          </div>
                        </div>
                        <div className="bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-green-500 h-2 rounded-full" 
                            style={{ 
                              width: `\${(
                                (currentCostFactors.implementationServicesCost - portnoxCostFactors.implementationServicesCost) +
                                (currentCostFactors.trainingCost - portnoxCostFactors.trainingCost) +
                                (currentCostFactors.networkRedesignCost - portnoxCostFactors.networkRedesignCost)
                              ) / tcoResults.totalSavings * 100}%` 
                            }}
                          ></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
# Function to create vendor logos (actual images for demo)
create_vendor_logos() {
  display_section "Creating Vendor Logo Placeholders"
  
  mkdir -p public/images/vendors
  
  # Base64 encoded tiny placeholder logos for each vendor
  # In a real environment, you would use actual vendor logos
  
  # Portnox
  cat > public/images/vendors/portnox-logo.png << EOL
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMJSURBVHgB7d0/TBNhHMfx773rH2gDJAal0ETiYCJxcGFxYXFhcXJycXJycnECdkYXJycnJ0wYHRxIHGDQxCKVQAyxQf551t+TJ5Q0LQW5u+f5fR9Cel3u6XOfPM/13pRSSgCshaABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGkAACKABBIAAGiAB/oB/IFCvV9JMo2V7+5dsbv6U5vN1iaKWGAuyLCuSplVpf30qFvPXjEXm7t0HQRjmZGvrlywtrcj29i+xZjAYHgUQ7Ozski9ffsjX1TUZPXVaRkZKzY0fuBFHIlZfW3sjX7781BNAM9QzgBv+q9WvUq/XhZ3jiRA2njgN4tBtGAdwi7xisYu5fbjFYC53Qazq7R0THyYvLnCFXbh4Saxqnnz5UAF+79/v+g9sBvD74EulM5LLnZTjzG/8/Qcgh/J7BhgcPCW9vWNHbrw7HMzOvpLpaRdCl9dLwWQyGYwP/ffzZwiCwNuwpqbuy/j4VTGsJD5MAvn+1Vc9N35iYsJrAO5pZngXoP8WcHDnz9y44X0Y6F4GNk8FbSsWi+IDL5fG7vx/bGxMfOBlBhgePi0+8BKAeyhkfQ3QxMsQMDk56WUdYG0I8LYIrFTuSz7fJQcJw1CmpqbEB28BuEOfTqeDWq0m7eLOBCYnH8ntO/e8HAp24u0qwB0OdjfXAfW9mjSa64CDhW69XpdK5bHcuvvAy3m/T17XAe78f3FxUQ7jRgm3rnBrhk78PvU7hs+rAb8LvSRJgnK5LM0jgMOHBHcYWK1WZXb2jVy+csP78GCF93GAWq0aLC+/a94S/sjOzm+Znf3QHPr9n/cbYT4AB0wlGPjjyZMXbd/4/6sZ4NCnc40W6xcF/SMsYMQPGP0FZpvMGYwAAAAASUVORK5CYII=
EOL
  
  # Cisco
  cat > public/images/vendors/cisco-logo.png << EOL
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMXSURBVHgB7dxRbxJBFMXxMwtUGxONJiZN40vf/f5fwgQTY4OJVmOFXebOAGW7dIFtKDP8f8k8lJbhzD13dlrMzABF09ABKAANoAA0gALQAApAAygADaAANIAC0AAKQAMoAA2gADSAAtAACkADKAANoAA0gALQAApAAygADaAANIAC0AAKQAMoAA2gADSAAtAACkADKAANoAA0gALQAApAAygADaAANIAC0AAKQAMoAA2gADSAAtAACkADKAANoAA0gAKQKaa897KuV1jXS0nztt00r79jXa+wbW80ju81jv+Z/0zDHhiGgWVZsvPzM7XtD23bP1/ZQ8Mw2DgOt/8eBPvHz8vD0dGhnZ6e2OHhoZV2g1R3gHEcrWmO7PPnY7XtqbXtyR5/D//Grmvt5OSTnZ+f2aNH/6y0ABQwDL2apn34vPr8pfb7L7a6cVIZeHt7a2/fvrHLywtLqagA8ZjXdV+1bn9a256Yffywc0G5vLywN29e2+XlhaVSzDHgYRj0ZevK/IffbDY7//7FxYVdXV2ZPyEUUUQ+L2u7Xmm7vvLKj3fq7u5uL+/v1cAPpVw3QJ+vebhH9Xlrp6en9vjxE9ulFIrKN39eHGKQxyfAXUrX96ONoxYODw9tl5I/BHiADw4+WFNHxaPbLvno+KSYALwifT/+lZWf/M9MoA1WbHxSSgC+1X9Nk3p/vXixVF7eSQX5vVBEAF7OvST5pUuaXu19Pt4HH/WSOQAv/l6S4jXzPucp+dZP4gAebvzUCo9jHlM+SRuAF364seKnXH62uORr/6RdBfjx7tvtNyvG95Nc2L3ge8YAUk3n/+Pr3hh+ajyFAJLN4dOo91LmSNIGEId9HvaUMn6KOZKkAcTH8eMoeTPrKQPIUq3zc/2NeUuaYx5zJdkCiOfc11opL/1iyBeOuZIs2QKY3/v/P89ifuTfLU7SAOLlXu5HNz/evXt3Y6nnTdIA/KjnD3XkXn7mpV+aeZM9APxN9sehUcb86PeX1HMnewAogyJOJeNfPHlpvt4PvzXfRVkXfwoAAAAASUVORK5CYII=
EOL
  
  # Aruba
  cat > public/images/vendors/aruba-logo.png << EOL
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAJcSURBVHgB7dwxbxNBEMbx2T0bRBApQhQUiJoGCjo+PB+CgoICUVBQICgQFQVCkaUoIiSKU9jendcJyInvzrfG3v+PtIWV5HjmmfXe+WQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYCxBDePJyYk9fPggbm1txY2NzbCx8f1z+Px9ib0/z/ND8flwcHBQ3njztty587rMVn2vUQzg7du3dv/+vfwybYYY+/hqPp/bycmp7e6+saOjI9N2LQN4/vx53Lm+k0OIpmrdbmEXF7ktFoWpupYBTKfTnGbpj4PzjOBnJ/78+UPe3d0zVdcygJRSztPJn89Vq6pKWWFq0bUMoK7rnKpa/KbGqqrqfxaAD5j/GuxVVVnfz//m1QsBKIYBAQyYv9Xjs/63V58A9N7/Pz/v0QFabgFN09hsNvP78cXy/l+2L1/6rOODHe8CJGZqsLdtm4sif9OB2ACy3zLPqb9KD39/9mNGkFe9c63VQC/L0rvApJ/9Vj2Zy5bj14b+JNN2DUDT1QzAO0DTNMt3OvhNjnXdmLJrGcDe3l4Mi4XF0G+h+/Kezz/2p4PKnUDVFQFUZTGdXopvtl/4Db6f/nMCeMZNJn/Z27cPTdm1DOD4+DhWZWn7+/u+FYSUSrsUQt+/YaIew3YCH8L9zZ+qDj6AL1+/marbdmfjxYsXcTrt78b75aYPIcSQ+rt7/a9CiMvnnZdlqW+9LYA+hOPj4+gdwO/u9e6wvb3tXWH5uutCWO/rvXRxLY/3r/vg7Bf6cFnIy0LugQAAAAAAAAAAAAAAAAAAAAAAAADAmPwGcaX5ULzg+AQAAAAASUVORK5CYII=
EOL
  
  # Forescout
  cat > public/images/vendors/forescout-logo.png << EOL
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAJRSURBVHgB7dtBbtpQFIXhawaCGGRWYQdZRFfRDahgHZVZp5lkhtgB3UG6g2YR3UEGGTXDDCoCJP4jYxI1ihpIcqxz7/+NFJvYxuc9Y798ZQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYNsKZeT56fHIwg40UKGBhhqqaPd9XwP9rr8qL69qnZ5eKCOZBaDQpT7or6YaaDQaq+/7etOTNM/z6vWe9PB4o9OzqbLxXZn48/uwKD4MdLh/pOntSAfDka1MqXXWNrJSF03xh8PRYu+DkXKSzRnAFb/0p/htJep2P+r2/lJbFPc/LnWlG5W9njKRRQDr4vPza50KnJ9fKAcqPgBXfD6bvtlZqqvL/HN3r+N3HQlEBuBW/2gyVqnun/HdWcAlvbxzB9Gpe36PG5Ri7+WlUKe7q0rj2jXu3lZXuxZeOHdpcLf1FBkA/iYugBZjD2BzYv8hEAF8H1f84eGhVt3Ovx/mgtDP+uVWDwECbU4K1etau7vvXvXRRNQZoIlWBVDOtF3VQ0A+Kg9APVXawWCgt9rtVr//9yjY6XS0OgC7y+O7d0WR7gPRr7D91gPQV80T1aVcGrqlv7w80/n5D7fbh3/cx93ncW1tM3dcOgSkyQ26fJuN/rUZZM4AwLshbgtoMQJoMQJoMQJoMQJoMQJoMQJoMQJosbgAynSHoK0QtwW4f2CpwLRm3/0wU+T/BhJAixFAixFAixFAixFAixFAixFAixFAixFAixFAixFAixFAixFAixFAixFAixFAiwEAAAAAAAAAAAAAAAAAdOEPB9TLVB5+c6QAAAAASUVORK5CYII=
EOL
  
  # Fortinet
  cat > public/images/vendors/fortinet-logo.png << EOL
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAKrSURBVHgB7dtNbtNAFMDx8YwbkFhwgtIbwA1acYN2VbFCrNgCJ2iXXbFkxQ1gB+wQK1iBFHIDeAKJTRcpii1n5pWEKi1t3H6N/f+kT5E/Ysc/vxlP7EQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOCqC2QYe/Z04vr1kbNxcgOuRHJOoXuR3HiU6MPyOIi2tLTG0cPLs89qg06fzfXxk9zZIFHRpitZO/Vf/K+Xj6r6YKeO8zvJX9vSlr7X+jh7GbQdg84D4MU/e3Lbpe6F5Lnl1zt5LGGUpO5F2oRgkAAUxffS/W6c4CUu/Y42/eMvkgavB70H4MeLvw5uLPVnxMkjjX1xvDVXMf3yWSdPZ9K33gPQVHwvliSRr8X35JVkWS7jiJ2fxLX9SLrWawB+/fF/1n0T/v7x/TP9tLj8JF3qNQD+xk+bFP9S/OzOrTlrWrb3APwo/i9xc7YPV74UMnELrUeYxe5e0rXeeuDL3/w1vvhVi7fmx97gw+JkLo92tqRrvQXg6cGO2CbFX4kTSVMJKCuKb2KNL0GvV4D17XxjfrwcRO9FizfWB9GXpZ1YL4/SfwD8Dd7xo8a7+1WWfhWcFtmRLnUegGOdz4+Pmr347+TF9mQj0flE52u6tCy6GzXGn9ZN/W9Y/yfnD+7h+UF/GdeFLmygMjE2GslGYm1iRaKxxkSRffuq0ZeF8aOZWq2kaeYPSoP4YMjiS0sMp8UuLCsfmwQAAAAAAAAAAACAdYtCmL+fX7qFgRmJoFxpJXZrfgHX5gsYqrU/GPKjcA+y4ptsofPf0cG2XJODIVs62ZHrIsj+P24TXHIEYPAIwOARgMEjAINHAAaPAAwcAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMB/6TcFfjR/YYZKnQAAAABJRU5ErkJggg==
EOL
  
  # SecureW2
  cat > public/images/vendors/securew2-logo.png << EOL
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAALfSURBVHgB7dtNbttGGIfxdyjJcpKmRbOJTlBkFQXZZNVN0SNkU7RH6A16BPcIXfYIAXqFZJU4QNZZ9AjOolJTRxrOkEVdyf6QNZ/5kc8DCKAoi8S8eofUcCgBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgKcqkGWsIzw9faFDHapX9NQrunL/HKlfjFXEn/U9/qHDw1K2sRbAu9++C4vDUPrhYYSqGBZHES6UyosoCv3w4VSjv9/J6x9fySa2AijLMuSKr8fxIH6I0+OXcny0a3OeTKjR6Jec35/E5FNY5O5BrVlLw9WPz2QTEwG4xe9Vv3BwcCDnb97KybNn4j28N+Y4jGmufrx/8Hptz5fJLR0ffSOb2Ajgc/GrPa/3PJE3xbFEr7+W3fBQc7nbU/bHOg1dD7lG9bR6fKiJm/KNbGIhALf4i+LXe+5CyA7c5ejFvoySJK7OQzd9+TztOJfuTtxyLGVPm+JctrEQwOdPfr3n09lMfvv1pxjMxip1NE2Tuqhcst3dXQ3VdLcTl+Pt5FVqaxdA1+J7Rfwx/jLRJF2/Frzqz+KYC6/4Vl65bQNoW/zmRXCHhu/jYdzNtFwG8HXXKXTbAJbFd3uev/tDLi4upB9PxotnWfMy6K6v2bUNYNoUP5tn7srraepmYuEW1QRgWbsA3OLvPPuhJr5fFV9dXck8Ls+F+O/dNnrdCWDb2Q+GtQtgmXnz8bNPjnRe3cEr/hVc1HfzNjm3u+7ctgvA5tNxQADGEYBxBGAcARhHAMYRgHEEYBwBGEcAxu2pYXEcxxPV3YQ0V32/qO3mRu7abtG3r/8QyTa31/W17xvX9wXXf6Zt0y6A0X1RnPOvouvYjJH6p9XDXfWNLzfspm0Ag/hD8x9lG7/q7dV44k7Wno+q5waJ28FBPLdS/ZTftcZV9Z7N9Zju2q9LrfPH+QgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAeMp+B43kc6m3+pLnAAAAAElFTkSuQmCC
EOL
  
  # Ivanti
  cat > public/images/vendors/ivanti-logo.png << EOL
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAKUSURBVHgB7dtLbtRAGIXhKrtDJohYAWy5C+giYM+GYRZsIBNmmWEWwZIiGCWd2OU6wZ2mgy8df+f7JEuJnB7Y71/lOKoKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAOleTt+fOXrtudFO3uSTaKooiiuXBd98G19/LyzcbSJl2AH99/uOvp1NV1TYjD9Jq2bWXT3Miru5cK5Eti9UMxxXdVVcnx8bGs12tfhDCqWknXdhKiKEDX7ZwLlb/CcVxjJRFKIvwWEGG0fglCHCb6/WT5yPdT5GqapnJLZfIvtO+7D/+ckl8e3d9jR66W/WnUBXDOFfcreAnGTtZB0mNx1+1cVZWu6/ZRPFUv9PmvB0OAOW9/H4/x29vXYTh4IQaY9fYnvv2Dhwi9g+7/aW9/0mNlj5X1Dgjwz9ufegmGULPEyu4AvXA0nF+Cvo1Gu/3xcvsTnIyhckbL6gCDUFUoSjz7U9z+0XPlipbNAQbl0vgNLKdFi7J05YmW1QF6i1IUIKPbn6xCQU/Lf0PL7gC9aGF0lK94DZzT4hUpmwP0dMPo6Idf9uV/2tqXC6NIWRygN3kYPfr+LcPlyd3OZPW5y40iFSWLA/TC+2EMo6dCeRF+uq57Hu5uMjLH6BUji2Pg3Sw0CL1X1Ek44qUqQpIj4J35bx5Vn/4ofKpUpkC6Apw+e+JqJv1DVWd/lJuiCCUoWv/v5OTKtVrIjG9/QxH8xz9ZmSKlPAKqTotYx97+sBJFPFIKfnAAwjDaPyJu5BhYyUJOi9oxsI4RsJKbPCvbNXDlm9mNMlkDKwEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAkfwCzLBvF1M0nNUAAAAASUVORK5CYII=
EOL
  
  # Microsoft
  cat > public/images/vendors/microsoft-logo.png << EOL
iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAJtSURBVHgB7dvRbdswFIbRK6UDuKN0g3iBbJIM0AmaTdJN4k3kbqAOIKAb9KEFC0iyrJBH0j3nAYGgNkLQD7QkO1UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACM5CADe3w8vxVxDGJKEfFWxPE4xMOHh89Rkc6QAfz8+enr01OMMY5F/OkQh+IxvlVxuz2WD59/KJNOgofHGAp/KP71cZvU4YP+jz+u2+7uY99uC/3z79fy+fnLnTJpXoD41xb/O+5Kf//j1PVnm9ZnAKFP/3q9Ou/qbQC3pfOCxf+Rtn3d9Z5ufSuWcgHCdLr0fLvrlCmCjuOu7r9O+9Pc4yepV2Ap9wCnaZ2nQ4xS3OOmOO/a1zfxoXzZv91eirTXAK42RX8ug3P0e0w5+nSk7gHC9O/6Oe1PMdYxbdPqDKB0dPunIp+M+nQ87HssY/bB6eXll0xprwGGZGf/pvnWsItzvJ1tGVTqHmBo4j9m03YPMKTTfTBt6XuAIYl/q+YFeF+Af7vbn3i31pZrXIBDMQDxtzX/TeWA7gOgL5sPZbrPALoGf7sNCz+VG9O8AEHRtyXvAUwB9ADVfgEk/pZ0BfgVt9+5dg6/5lzAZuN7+DP1BOgF2JKuAOJvSzsF+A5gzzrG+E5g3xZ9K1j8q3JzZZf2x8DiX5XXAcS/KnOP7/bvS9oD9MTfl+6rwOJfla4A4l+VrgDiX5W2AD0LeD3ib6v9MvD1dgM+iL+p9n8Hjyiuy9/iA3+b7wL2pf0u4OW8uLFpPgDql78AAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgD/6DbUG52wJdjs/AAAAAElFTkSuQmCC
EOL
  
  # Create favicon
  cat > public/favicon.ico << EOL
AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAABILAAASCwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdWcnAHVnJwB1ZycAdWcnAHVnJwB1ZycAdWcnAHVnJwB1ZycAdWcnAAAAAAAAAAAAAAAAAAAAAAAAAAAAdWcnAHVnJ0x1ZyfEdWcn6XVnJ+l1ZyfpdWcn6XVnJ+l1ZyfpdWcnxHVnJ0x1ZycAAAAAAAAAAAAAAAAAcmUlAHNlJUV1Zyf3dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf3c2UlRXJlJQAAAAAAcGMkAHBjJDdzZSXvdWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3NlJe9wYyQ3cGMkAGdcIgBuYSPPc2Ul/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/9zZSX/bmEjz2dcIgBpXSJxbmEj/3NlJf91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/c2Ul/25hI/9pXSJxaV0i1GtfIv9xZCT/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3FkJP9rXyL/aV0i1GldIvRpXSL/bmEj/3RmJv91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3RmJv9uYSP/aV0i/2ldIvRpXSL0aV0i/2ldIv9xZCT/dWcn/3VnJ/91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/9xZCT/aV0i/2ldIv9pXSL0aV0i1GldIv9pXSL/a18i/3NlJf91Zyf/dWcn/3VnJ/91Zyf/dWcn/3VnJ/9zZSX/a18i/2ldIv9pXSL/aV0i1GldInFpXSL/aV0i/2ldIv9uYSP/dGYm/3VnJ/91Zyf/dWcn/3VnJ/90Zib/bmEj/2ldIv9pXSL/aV0i/2ldInFjVyAAaV0iz2ldIv9pXSL/aV0i/3FkJP91Zyf/dWcn/3VnJ/91Zyf/cWQk/2ldIv9pXSL/aV0i/2ldIs9jVyAAAAAAAGFWHzdpXSLvaV0i/2ldIv9rXyL/c2Ul/3VnJ/91Zyf/c2Ul/2tfIv9pXSL/aV0i/2ldIu9hVh83AAAAAAAAAACBeFYAYVYdRWldIvdpXSL/aV0i/2tfIv9xZCT/cWQk/2tfIv9pXSL/aV0i/2ldIvdhVh1FgXhWAAAAAAAAAAAAAAAAACFDmwBhVh4AYVYeTGldIsRpXSLpaV0i6WldIulpXSLpaV0i6WldIsRhVh5MYVYeACFDmwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//8AAP//AAD+fwAA/D8AAPgfAADwDwAA4AcAAMADAADAAwAAwAMAAMADAADgBwAA8A8AAPgfAAD8PwAA//8AAA==
EOL
  
  display_success "Created vendor logos"
}

# Function to build and deploy functions
build_application() {
  display_section "Building Application"
  
  echo "Building NextJS application..."
  
  # Disable telemetry (optional but recommended)
  if [ "$USE_YARN" = true ]; then
    yarn next telemetry disable
  else
    npx next telemetry disable
  fi
  
  # Fix potential template literal issues in JavaScript files
  find components pages -type f -name "*.js" -exec sed -i 's/${/\${/g' {} ;
  
  if [ "$USE_YARN" = true ]; then
    yarn build
    BUILD_RESULT=$?
  else
    npm run build
    BUILD_RESULT=$?
  fi
  
  if [ $BUILD_RESULT -eq 0 ]; then
    display_success "Application built successfully"
  else
    display_error "Failed to build application"
    echo "Try running the fix_nac_calculator.sh script to fix compilation issues"
    exit 1
  fi
}
  display_section "Building Application"
  
  echo "Building NextJS application..."
  
  if [ "$USE_YARN" = true ]; then
    yarn build
  else
    npm run build
  fi
  
  if [ $? -eq 0 ]; then
    display_success "Application built successfully"
  else
    display_error "Failed to build application"
  fi

# Function to deploy to GitHub pages
deploy_to_github_pages() {
  display_section "Deploying to GitHub Pages"
  
  # Configure for GitHub Pages deployment
  echo "Configuring for GitHub Pages deployment..."
  
  # Update next.config.js for GitHub Pages
  cat > next.config.js << EOL
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'export',
  basePath: '/\${REPO_URL##*/}',
  images: {
    unoptimized: true,
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
EOL
  
  echo "Building for GitHub Pages..."
  
  if [ "$USE_YARN" = true ]; then
    yarn build
  else
    npm run build
  fi
  
  if [ $? -ne 0 ]; then
    display_error "Failed to build application for GitHub Pages"
  fi
  
  # Create required GitHub Pages files
  touch out/.nojekyll
  
  # Commit and push changes
  echo "Committing files to repository..."
  
  git add .
  git commit -m "Deploy Enterprise NAC TCO Calculator"
  
  echo "Pushing to GitHub repository: $REPO_URL"
  git push -u origin $REPO_BRANCH
  
  # Deploy using gh-pages
  echo "Deploying to GitHub Pages..."
  
  if [ "$USE_YARN" = true ]; then
    yarn add --dev gh-pages
    yarn gh-pages -d out
  else
    npm install --save-dev gh-pages
    npx gh-pages -d out
  fi
  
  if [ $? -eq 0 ]; then
    display_success "Successfully deployed to GitHub Pages"
    GITHUB_PAGES_URL=$(echo $REPO_URL | sed 's/https:\/\/github.com\//https:\/\/' | sed 's/\.git$//' | sed 's/$/\//')
    echo "Your application is now available at: $GITHUB_PAGES_URL"
  else
    display_error "Failed to deploy to GitHub Pages"
  fi
}

# Function to run development server
run_dev_server() {
  display_section "Starting Development Server"
  
  echo "Starting the development server..."
  echo "You can access the application at http://localhost:3000"
  
  if [ "$USE_YARN" = true ]; then
    yarn dev
  else
    npm run dev
  fi
}

# Function to display help information
show_help() {
  echo -e "\${BLUE}Enterprise NAC TCO & ROI Calculator Deployment Script\${RESET}"
  echo
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  --dev              Run in development mode"
  echo "  --build            Build the application"
  echo "  --deploy           Deploy to GitHub Pages"
  echo "  --repo URL         Specify GitHub repository URL (default: $DEFAULT_REPO_URL)"
  echo "  --branch NAME      Specify GitHub branch name (default: $DEFAULT_REPO_BRANCH)"
  echo "  --user-name NAME   Specify Git user name (default: $DEFAULT_USER_NAME)"
  echo "  --user-email EMAIL Specify Git user email (default: $DEFAULT_USER_EMAIL)"
  echo "  --help             Show this help information"
  echo
  echo "Examples:"
  echo "  $0 --dev                         # Run development server"
  echo "  $0 --build                       # Build the application"
  echo "  $0 --deploy                      # Deploy to GitHub Pages"
  echo "  $0 --repo https://github.com/username/repo.git --deploy  # Deploy to specific repo"
  echo "  $0 --repo https://github.com/username/repo.git --user-name \"Your Name\" --user-email \"your@email.com\" --deploy"
  echo
}

# Main function
main() {
  # Parse command line arguments
  if [ $# -eq 0 ]; then
    show_help
    exit 0
  fi
  
  MODE=""
  
  while [ $# -gt 0 ]; do
    case "$1" in
      --dev)
        MODE="dev"
        shift
        ;;
      --build)
        MODE="build"
        shift
        ;;
      --deploy)
        MODE="deploy"
        shift
        ;;
      --repo)
        if [ -n "$2" ]; then
          REPO_URL="$2"
          shift 2
        else
          display_error "Repository URL not provided"
        fi
        ;;
      --branch)
        if [ -n "$2" ]; then
          REPO_BRANCH="$2"
          shift 2
        else
          display_error "Branch name not provided"
        fi
        ;;
      --user-name)
        if [ -n "$2" ]; then
          GIT_USER_NAME="$2"
          shift 2
        else
          display_error "Git user name not provided"
        fi
        ;;
      --user-email)
        if [ -n "$2" ]; then
          GIT_USER_EMAIL="$2"
          shift 2
        else
          display_error "Git user email not provided"
        fi
        ;;
      --help)
        show_help
        exit 0
        ;;
      *)
        display_error "Unknown option: $1"
        ;;
    esac
  done
  
  # ASCII art banner
  echo -e "\${GREEN}"
  echo '███████╗███╗   ██╗████████╗███████╗██████╗ ██████╗ ██████╗ ██╗███████╗███████╗'
  echo '██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██║██╔════╝██╔════╝'
  echo '█████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝██████╔╝██████╔╝██║███████╗█████╗  '
  echo '██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██╔═══╝ ██╔══██╗██║╚════██║██╔══╝  '
  echo '███████╗██║ ╚████║   ██║   ███████╗██║  ██║██║     ██║  ██║██║███████║███████╗'
  echo '╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝'
  echo '                                                                               '
  echo '███╗   ██╗ █████╗  ██████╗    ████████╗ ██████╗ ██████╗     ██████╗  ██████╗ ██╗'
  echo '████╗  ██║██╔══██╗██╔════╝    ╚══██╔══╝██╔════╝██╔═══██╗    ██╔══██╗██╔═══██╗██║'
  echo '██╔██╗ ██║███████║██║            ██║   ██║     ██║   ██║    ██████╔╝██║   ██║██║'
  echo '██║╚██╗██║██╔══██║██║            ██║   ██║     ██║   ██║    ██╔══██╗██║   ██║██║'
  echo '██║ ╚████║██║  ██║╚██████╗       ██║   ╚██████╗╚██████╔╝    ██║  ██║╚██████╔╝██║'
  echo '╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝       ╚═╝    ╚═════╝ ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝'
  echo -e "\${RESET}"
  
  # Print current configuration
  echo -e "\${BLUE}Deployment Configuration:\${RESET}"
  echo "Repository URL: $REPO_URL"
  echo "Branch: $REPO_BRANCH"
  echo "Git User: $GIT_USER_NAME <$GIT_USER_EMAIL>"
  echo
  
  # Execute the selected workflow
  check_prerequisites
  setup_git_repository
  create_project_structure
  install_dependencies
  create_config_files
  create_styles
  create_data_models
  create_layout_components
  create_vendor_logos
  
  case "$MODE" in
    "dev")
      run_dev_server
      ;;
    "build")
      build_application
      ;;
    "deploy")
      build_application
      deploy_to_github_pages
      ;;
    *)
      display_error "No valid mode specified. Use --help to see available options."
      ;;
  esac
}

# Execute main function
main "$@"
