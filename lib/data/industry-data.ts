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
