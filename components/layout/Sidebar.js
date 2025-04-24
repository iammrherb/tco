import React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/router';

const Sidebar = ({ isOpen, onClose }) => {
  const router = useRouter();
  
  const navItems = [
    { id: 'organization', label: 'Organization', path: '/' },
    { id: 'environment', label: 'Environment', path: '/environment' },
    { id: 'requirements', label: 'Requirements', path: '/requirements' },
    { id: 'results', label: 'Results', path: '/results' },
  ];

  return (
    <aside className={`bg-white shadow-md h-full w-64 fixed left-0 top-0 z-30 transition-transform duration-300 transform ${isOpen ? 'translate-x-0' : '-translate-x-full'} md:translate-x-0`}>
      <div className="p-4 border-b">
        <h2 className="text-xl font-bold text-blue-800">NAC TCO Calculator</h2>
      </div>
      
      <nav className="p-4">
        <ul className="space-y-2">
          {navItems.map((item) => (
            <li key={item.id}>
              <Link href={item.path}>
                <a className={`block px-4 py-2 rounded transition-colors ${
                  router.pathname === item.path
                    ? 'bg-blue-100 text-blue-800 font-medium'
                    : 'hover:bg-gray-100'
                }`}>
                  {item.label}
                </a>
              </Link>
            </li>
          ))}
        </ul>
      </nav>
      
      <div className="absolute bottom-0 w-full p-4 border-t">
        <div className="text-sm text-gray-500">
          <p>© {new Date().getFullYear()} TCO Calculator</p>
        </div>
      </div>
    </aside>
  );
};

// Make sure to correctly export the component
export { Sidebar };
export default Sidebar;
