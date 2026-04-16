import { useState } from 'react';
import { Search } from 'lucide-react';
import { motion } from 'motion/react';
import { SOUNDS } from '../constants';
import { Category } from '../types';
import SoundCard from '../components/SoundCard';
import { cn } from '../lib/utils';

export default function DiscoverPage() {
  const [activeCategory, setActiveCategory] = useState<Category>('All');
  const categories: Category[] = ['All', 'Nature', 'Rain', 'ASMR', 'Urban', 'Focus'];

  return (
    <div className="pt-24 pb-40 px-6 max-w-7xl mx-auto">
      <section className="mb-10">
        <motion.h1 
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          className="font-headline text-4xl md:text-6xl font-extrabold tracking-tight mb-6"
        >
          Discover Peace
        </motion.h1>
        
        <div className="relative group max-w-2xl">
          <div className="absolute inset-y-0 left-4 flex items-center pointer-events-none">
            <Search className="w-5 h-5 text-outline" />
          </div>
          <input 
            type="text" 
            placeholder="Search sounds, moods, or places..."
            className="w-full bg-surface-container-high border-none rounded-2xl py-4 pl-12 pr-4 text-on-surface placeholder:text-outline focus:ring-2 focus:ring-primary transition-all duration-300 outline-none"
          />
        </div>
      </section>

      <div className="flex gap-3 overflow-x-auto hide-scrollbar mb-10 pb-2">
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setActiveCategory(cat)}
            className={cn(
              "px-6 py-2 rounded-full font-headline text-sm font-semibold flex-shrink-0 transition-all duration-300",
              activeCategory === cat 
                ? "bg-primary text-on-primary" 
                : "bg-surface-container-high text-on-surface hover:bg-surface-container-highest"
            )}
          >
            {cat}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {SOUNDS.map((sound, i) => (
          <motion.div
            key={sound.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
          >
            <SoundCard sound={sound} />
          </motion.div>
        ))}
      </div>
    </div>
  );
}
