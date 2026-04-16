import { Waves, Search, UserCircle } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function TopAppBar() {
  return (
    <header className="bg-slate-950/60 backdrop-blur-xl fixed top-0 w-full z-50 flex justify-between items-center px-6 h-16 border-b border-white/5">
      <Link to="/" className="flex items-center gap-3 hover:opacity-80 transition-opacity">
        <Waves className="text-primary w-6 h-6" />
        <span className="text-2xl font-headline font-bold tracking-tighter text-primary">Ethereal</span>
      </Link>
      <div className="flex items-center gap-4">
        <button className="text-on-surface-variant hover:text-on-surface transition-colors">
          <Search className="w-5 h-5" />
        </button>
        <button className="text-primary hover:opacity-80 transition-opacity">
          <UserCircle className="w-6 h-6" />
        </button>
      </div>
    </header>
  );
}
