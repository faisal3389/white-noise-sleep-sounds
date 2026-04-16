import { Home, Search, Library, Heart, Settings } from 'lucide-react';
import { NavLink } from 'react-router-dom';
import { cn } from '../lib/utils';

export default function BottomNavBar() {
  const navItems = [
    { icon: Home, label: 'Home', path: '/' },
    { icon: Search, label: 'Discover', path: '/discover' },
    { icon: Library, label: 'Mixes', path: '/mixes' },
    { icon: Heart, label: 'Favorites', path: '/favorites' },
    { icon: Settings, label: 'Settings', path: '/settings' },
  ];

  return (
    <nav className="fixed bottom-0 left-0 w-full flex justify-around items-center px-4 pt-3 pb-8 bg-slate-950/70 backdrop-blur-2xl z-50 rounded-t-[2rem] shadow-[0_-8px_32px_rgba(0,0,0,0.3)] border-t border-white/5">
      {navItems.map((item) => (
        <NavLink
          key={item.path}
          to={item.path}
          className={({ isActive }) =>
            cn(
              "flex flex-col items-center justify-center transition-all duration-300",
              isActive ? "text-primary scale-110" : "text-on-surface-variant opacity-60 hover:text-primary hover:opacity-100"
            )
          }
        >
          <item.icon className="w-6 h-6 mb-1" />
          <span className="font-headline text-[10px] uppercase tracking-widest font-bold">{item.label}</span>
        </NavLink>
      ))}
    </nav>
  );
}
