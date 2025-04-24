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
  return `${value.toFixed(1)}%`;
};

// Format time periods
export const formatTimePeriod = (days: number): string => {
  if (days < 30) {
    return `${days} days`;
  } else if (days < 365) {
    const months = Math.round(days / 30);
    return `${months} ${months === 1 ? 'month' : 'months'}`;
  } else {
    const years = (days / 365).toFixed(1);
    return `${years} ${parseFloat(years) === 1 ? 'year' : 'years'}`;
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
      year: year === 0 ? 'Initial' : `Year ${year}`,
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
