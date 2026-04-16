import { Play, Pause, X } from 'lucide-react';
import { motion } from 'motion/react';
import { Link } from 'react-router-dom';

export default function NowPlayingWidget() {
  return (
    <motion.div 
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      className="fixed bottom-24 left-6 right-6 z-40"
    >
      <div className="glass-card bg-slate-900/70 rounded-2xl p-4 flex items-center justify-between shadow-2xl">
        <Link to="/player" className="flex items-center gap-4 flex-1">
          <div className="w-12 h-12 rounded-lg overflow-hidden bg-surface-container-highest">
            <img 
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuCYbs7SG-LncHyuq9368ehI7YDErPrSoBCpRt31Z3U2i4koOtLd_gytQc1IR-Tp6Od2aLzEvtNw4n_57zNv8F5ZPoT1bfG_Xk8BkHgmN84zwzuokzljGq5kLVOGjcw3oD_Wtr3aBGka2Z2Rdk9i3TSNeERHTcoxQ6hag7ArJq9bzaEkZEaLY6rI6Pq52aAXYd_ux-kt4UYZXakeBc3ezHweozNeJ9yKxdcVxJMKHmAsUcdS2AC-Nx3TEjQ1AIS3nXJN49a3g_P4lCI" 
              alt="Current Sound"
              className="w-full h-full object-cover"
              referrerPolicy="no-referrer"
            />
          </div>
          <div>
            <h5 className="text-sm font-bold text-on-surface">Rain on Lake</h5>
            <div className="flex items-center gap-1">
              <motion.div 
                animate={{ height: [8, 12, 8] }}
                transition={{ repeat: Infinity, duration: 0.8 }}
                className="w-1 bg-primary"
              />
              <motion.div 
                animate={{ height: [12, 16, 12] }}
                transition={{ repeat: Infinity, duration: 0.8, delay: 0.2 }}
                className="w-1 bg-primary"
              />
              <motion.div 
                animate={{ height: [6, 10, 6] }}
                transition={{ repeat: Infinity, duration: 0.8, delay: 0.4 }}
                className="w-1 bg-primary"
              />
              <span className="text-[10px] text-primary font-bold ml-1 tracking-widest uppercase">Playing</span>
            </div>
          </div>
        </Link>
        <div className="flex items-center gap-4">
          <button className="text-on-surface hover:text-primary transition-colors">
            <Pause className="w-6 h-6 fill-current" />
          </button>
          <button className="text-on-surface-variant hover:text-on-surface transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>
    </motion.div>
  );
}
