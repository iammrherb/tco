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
    impactLevel: 'medium',
    impactFactorMin: 1.05,
    impactFactorMax: 1.25,
    defaultValue: 1,
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
