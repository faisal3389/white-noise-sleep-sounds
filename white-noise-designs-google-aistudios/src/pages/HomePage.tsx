import { Play } from 'lucide-react';
import { motion } from 'motion/react';
import { SOUNDS } from '../constants';
import SoundCard from '../components/SoundCard';

export default function HomePage() {
  const featuredSound = SOUNDS[0]; // Rain on Lake

  return (
    <div className="pt-24 pb-40 px-6 max-w-7xl mx-auto">
      {/* Hero Section */}
      <section className="mb-12">
        <div className="max-w-4xl">
          <motion.span 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="inline-block px-3 py-1 bg-primary/10 text-primary text-[10px] font-bold tracking-widest uppercase rounded-full mb-4"
          >
            Daily Refresh
          </motion.span>
          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-5xl md:text-7xl font-headline font-extrabold tracking-tighter mb-6 text-on-background"
          >
            Morning <br/><span className="text-primary">Sanctuary.</span>
          </motion.h1>
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="text-on-surface-variant text-lg max-w-xl leading-relaxed"
          >
            Escape into a curated selection of natural rhythms designed to ground your focus and ease your transition into the day.
          </motion.p>
        </div>
      </section>

      {/* Bento Grid */}
      <section className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-6xl">
        {/* Large Card */}
        <div className="md:col-span-2">
          <SoundCard sound={featuredSound} variant="landscape" />
        </div>
        
        {/* Small Cards */}
        {SOUNDS.slice(1, 4).map((sound, i) => (
          <motion.div
            key={sound.id}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 + i * 0.1 }}
          >
            <SoundCard sound={sound} />
          </motion.div>
        ))}

        {/* Horizontal Medium Card */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="md:col-span-3 group relative h-64 rounded-[2rem] overflow-hidden bg-surface-container-high transition-transform duration-500 active:scale-[0.98]"
        >
          <img 
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuA5QvNjozg6GGTaNIozIOVwAdOfZ8UgitgyiD7o_RNTJ5DjFtPjV3uj0fSRlGAsez964Y0Nznzy5h2zbYQICYG5lPsDbCtqxYDB2lxfcHHeBYwK5nFQzWqPc1EBhEclkHUxkQ5hdXA7ZQ8QLT8S6R8lEMdcMy85PJRpymAzvFZL5RpmY4M60EeaGn2ymELDo55iFkMneA999DGZ-qyC-1rx-wHwhpHx_Hu-mFiYckm9Nm5MTie-C8zSaxOh1evrtjr7-B6LAISMvPk" 
            alt="Tidal Calm" 
            className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
            referrerPolicy="no-referrer"
          />
          <div className="absolute inset-0 bg-gradient-to-r from-slate-950/80 via-slate-950/30 to-transparent" />
          <div className="absolute inset-0 p-10 flex flex-col justify-center max-w-md">
            <h3 className="text-3xl font-headline font-bold text-white mb-2">Tidal Calm</h3>
            <p className="text-slate-300 text-base mb-6">Experience the hypnotic pull of the ocean tide on a secluded shoreline.</p>
            <button className="w-fit px-8 py-3 bg-white/10 hover:bg-white/20 backdrop-blur-md rounded-full text-white text-sm font-bold transition-all">
              Play Journey
            </button>
          </div>
        </motion.div>
      </section>
    </div>
  );
}
