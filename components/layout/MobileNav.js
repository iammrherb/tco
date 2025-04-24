import React from 'react';
import { useRouter } from 'next/router';

const MobileNav = ({ onOpenSidebar }) => {
  const router = useRouter();
  
  const getPageTitle = () => {
    const path = router.pathname;
    if (path === '/') return 'Organization';
    if (path === '/environment') return 'Environment';
    if (path === '/requirements') return 'Requirements';
    if (path === '/results') return 'Results';
    return 'NAC TCO Calculator';
  };
  
  return (
    <div className="md:hidden bg-white shadow-md p-4 flex items-center justify-between">
      <button
        onClick={onOpenSidebar}
        className="text-gray-600 focus:outline-none"
        aria-label="Open navigation menu"
      >
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16"></path>
        </svg>
      </button>
      <h1 className="text-xl font-bold text-blue-800">{getPageTitle()}</h1>
      <div className="w-6"></div>
    </div>
  );
};

// Make sure to correctly export the component
export { MobileNav };
export default MobileNav;
