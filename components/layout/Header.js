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
