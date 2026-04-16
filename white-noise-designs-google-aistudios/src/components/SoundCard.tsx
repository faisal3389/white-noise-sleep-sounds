import { Play, Heart, Info } from 'lucide-react';
import { motion } from 'motion/react';
import { Sound } from '../types';
import { cn } from '../lib/utils';

interface SoundCardProps {
  sound: Sound;
  variant?: 'portrait' | 'landscape';
}

export default function SoundCard({ sound, variant = 'portrait' }: SoundCardProps) {
  return (
    <motion.div 
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      className={cn(
        "group relative overflow-hidden bg-surface-container-low transition-all duration-500",
        variant === 'portrait' ? "aspect-[4/5] rounded-[1.5rem]" : "h-80 rounded-[2rem]"
      )}
    >
      <img 
        src={sound.imageUrl} 
        alt={sound.title}
        className="absolute inset-0 w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity duration-700 group-hover:scale-110"
        referrerPolicy="no-referrer"
      />
      <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/20 to-transparent" />
      
      <div className="absolute top-4 right-4 flex flex-col gap-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
        <button className="w-10 h-10 rounded-full bg-slate-950/40 backdrop-blur-md flex items-center justify-center text-on-surface hover:text-primary transition-colors">
          <Heart className="w-5 h-5" />
        </button>
        <button className="w-10 h-10 rounded-full bg-slate-950/40 backdrop-blur-md flex items-center justify-center text-on-surface hover:text-primary transition-colors">
          <Info className="w-5 h-5" />
        </button>
      </div>

      <div className="absolute bottom-6 left-6 right-6 flex justify-between items-end">
        <div className="flex-1">
          <span className="font-headline text-[10px] uppercase tracking-widest text-primary font-bold mb-1 block">
            {sound.category}
          </span>
          <h3 className="font-headline text-2xl font-bold text-white mb-2">{sound.title}</h3>
          <div className="flex items-center gap-2">
            <div className="h-1 w-12 bg-primary rounded-full" />
            <span className="text-xs text-on-surface-variant font-medium">{sound.duration} Soundscape</span>
          </div>
        </div>
        
        {variant === 'landscape' && (
          <button className="w-14 h-14 flex items-center justify-center bg-primary rounded-full text-on-primary shadow-[0_0_20px_rgba(127,230,219,0.3)] hover:scale-105 transition-transform">
            <Play className="w-8 h-8 fill-current" />
          </button>
        )}
      </div>
    </motion.div>
  );
}
