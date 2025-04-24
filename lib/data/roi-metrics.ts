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
