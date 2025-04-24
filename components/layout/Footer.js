import React from 'react';

const Footer = () => {
  return (
    <footer className="mt-auto py-4 border-t">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row justify-between items-center">
          <div className="text-sm text-gray-500 mb-2 md:mb-0">
            © {new Date().getFullYear()} TCO Calculator. All rights reserved.
          </div>
          <div className="text-sm text-gray-500">
            <a href="#" className="hover:text-blue-600 mr-4">Privacy Policy</a>
            <a href="#" className="hover:text-blue-600">Terms of Service</a>
          </div>
        </div>
      </div>
    </footer>
  );
};

// Make sure to correctly export the component
export { Footer };
export default Footer;
