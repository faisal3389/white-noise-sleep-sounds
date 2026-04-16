import { Play, Edit2 } from 'lucide-react';
import { motion } from 'motion/react';
import { Mix } from '../types';
import { cn } from '../lib/utils';

interface MixCardProps {
  mix: Mix;
}

export default function MixCard({ mix }: MixCardProps) {
  return (
    <div className="group cursor-pointer">
      <motion.div 
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        className="relative aspect-video rounded-xl overflow-hidden mb-4 bg-surface-container-high"
      >
        <div className="grid grid-cols-2 h-full gap-[2px]">
          {mix.imageUrls.map((url, i) => (
            <img 
              key={i}
              src={url} 
              alt="" 
              className="w-full h-full object-cover"
              referrerPolicy="no-referrer"
            />
          ))}
        </div>
        
        <div className="absolute inset-0 bg-black/20 group-hover:bg-black/40 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100 duration-300">
          <div className="w-14 h-14 rounded-full bg-primary/90 backdrop-blur-md text-on-primary flex items-center justify-center active:scale-90 transition-transform">
            <Play className="w-8 h-8 fill-current" />
          </div>
        </div>
        
        <button className="absolute top-4 right-4 w-10 h-10 rounded-full bg-slate-900/40 backdrop-blur-md flex items-center justify-center text-on-surface hover:text-primary transition-colors">
          <Edit2 className="w-5 h-5" />
        </button>
      </motion.div>
      
      <div className="flex justify-between items-start">
        <div>
          <h3 className="font-headline font-bold text-lg text-on-surface">{mix.title}</h3>
          <p className="text-sm text-on-surface-variant">{mix.description}</p>
        </div>
        {mix.isActive && (
          <span className="text-[10px] font-bold tracking-widest text-primary bg-primary/10 px-2 py-1 rounded-full uppercase">
            Active
          </span>
        )}
      </div>
    </div>
  );
}
