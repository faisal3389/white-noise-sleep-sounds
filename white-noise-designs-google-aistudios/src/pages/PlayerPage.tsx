import { ChevronDown, Heart, Shuffle, SkipBack, Play, SkipForward, Repeat, Volume2, Timer, Wind, AudioLines } from 'lucide-react';
import { motion } from 'motion/react';
import { useNavigate } from 'react-router-dom';

export default function PlayerPage() {
  const navigate = useNavigate();

  return (
    <div className="relative h-screen w-full overflow-hidden bg-background">
      {/* Background Immersive Image */}
      <div className="absolute inset-0">
        <img 
          src="https://lh3.googleusercontent.com/aida-public/AB6AXuDohJK7dYpRo-zZdTVqIz9C7851T9PRDipmB9E3osyiXXrNmjA7zG0c1SXnpgco8mx3xdZhJL7zmXrwJQhBiPi8tJQb-gOqozfoTQmkwlMJLP7cfKSuqZEfYKANnvd13oXteVLH1fsvqwpM5ZXv6i6coutijfaPRZTwZ9DzIyWJ9ukIczCNY_QWC3M_ErFCvtdaZ-J66xBbDUN5go5cgd2DrKYuO4UzAo6dFywILzJmlVTMZi5mb4Y-iAZAHwfq89-IZytkhageEok" 
          alt="Ancient Forest" 
          className="w-full h-full object-cover opacity-60 scale-105 blur-[2px]"
          referrerPolicy="no-referrer"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-background via-background/40 to-transparent" />
      </div>

      {/* Header */}
      <header className="relative z-10 flex justify-between items-center px-6 h-16">
        <button 
          onClick={() => navigate(-1)}
          className="text-on-surface-variant hover:text-on-surface transition-colors"
        >
          <ChevronDown className="w-8 h-8" />
        </button>
        <div className="flex items-center gap-2">
          <AudioLines className="text-primary w-5 h-5" />
          <span className="text-xl font-headline font-bold tracking-tighter text-primary">Ethereal</span>
        </div>
        <div className="w-8" /> {/* Spacer */}
      </header>

      {/* Content */}
      <main className="relative z-10 flex flex-col justify-end h-[calc(100vh-64px)] px-8 pb-32 max-w-2xl mx-auto">
        <div className="mb-12 space-y-2">
          <div className="flex items-center justify-between">
            <div>
              <span className="font-headline text-xs uppercase tracking-[0.2em] text-secondary font-bold opacity-80 mb-2 block">
                Atmosphere
              </span>
              <h1 className="font-headline text-4xl md:text-5xl font-extrabold tracking-tight text-on-background">
                Midnight River Run
              </h1>
              <p className="font-sans text-lg text-on-surface-variant mt-1">
                Deep Forest Stream • 432Hz
              </p>
            </div>
            <button className="h-12 w-12 flex items-center justify-center rounded-full bg-on-background/10 backdrop-blur-md hover:bg-on-background/20 transition-all active:scale-90">
              <Heart className="w-6 h-6 text-primary fill-current" />
            </button>
          </div>
        </div>

        <div className="space-y-10">
          {/* Progress */}
          <div className="space-y-3">
            <div className="relative h-1.5 w-full bg-on-background/20 rounded-full overflow-hidden backdrop-blur-sm">
              <motion.div 
                initial={{ width: 0 }}
                animate={{ width: '45%' }}
                className="absolute top-0 left-0 h-full bg-gradient-to-r from-primary to-secondary rounded-full shadow-[0_0_12px_rgba(127,230,219,0.5)]"
              />
            </div>
            <div className="flex justify-between font-headline text-[10px] uppercase tracking-widest text-on-surface-variant font-bold">
              <span>12:45</span>
              <span>28:00</span>
            </div>
          </div>

          {/* Transport */}
          <div className="flex items-center justify-between px-4">
            <button className="text-on-background/60 hover:text-on-background transition-colors active:scale-90">
              <Shuffle className="w-6 h-6" />
            </button>
            <div className="flex items-center gap-8 md:gap-12">
              <button className="text-on-background hover:text-primary transition-colors active:scale-90">
                <SkipBack className="w-8 h-8 fill-current" />
              </button>
              <button className="h-20 w-20 flex items-center justify-center rounded-full bg-gradient-to-br from-primary to-primary-container text-on-primary shadow-[0_12px_40px_rgba(71,176,167,0.4)] active:scale-95 transition-transform">
                <Play className="w-10 h-10 fill-current" />
              </button>
              <button className="text-on-background hover:text-primary transition-colors active:scale-90">
                <SkipForward className="w-8 h-8 fill-current" />
              </button>
            </div>
            <button className="text-on-background/60 hover:text-on-background transition-colors active:scale-90">
              <Repeat className="w-6 h-6" />
            </button>
          </div>

          {/* Volume */}
          <div className="flex items-center gap-6 pt-4">
            <Volume2 className="text-on-surface-variant w-5 h-5" />
            <div className="relative flex-1 h-1 bg-on-background/10 rounded-full overflow-hidden">
              <div className="absolute top-0 left-0 h-full w-[70%] bg-on-background/40 rounded-full" />
            </div>
          </div>
        </div>
      </main>

      {/* Floating Action Bar */}
      <div className="fixed bottom-8 left-1/2 -translate-x-1/2 w-auto flex items-center gap-6 px-8 py-4 bg-slate-950/70 backdrop-blur-2xl rounded-full shadow-[0_-8px_32px_rgba(0,0,0,0.3)] z-40 border border-on-background/5">
        <button className="flex flex-col items-center justify-center text-primary transition-transform">
          <AudioLines className="w-6 h-6" />
          <span className="font-headline text-[10px] uppercase tracking-widest font-bold mt-1">Audio</span>
        </button>
        <button className="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-colors">
          <Timer className="w-6 h-6" />
          <span className="font-headline text-[10px] uppercase tracking-widest font-bold mt-1">Timer</span>
        </button>
        <button className="flex flex-col items-center justify-center text-on-surface-variant opacity-60 hover:text-primary transition-colors">
          <Wind className="w-6 h-6" />
          <span className="font-headline text-[10px] uppercase tracking-widest font-bold mt-1">Mixer</span>
        </button>
      </div>
    </div>
  );
}
