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
