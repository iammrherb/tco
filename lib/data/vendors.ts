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

export type VendorCosts = {
  [size in OrganizationSize]: CostFactors;
}

export type VendorImplementation = {
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
