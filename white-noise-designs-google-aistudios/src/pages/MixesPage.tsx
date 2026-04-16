import { Plus } from 'lucide-react';
import { motion } from 'motion/react';
import { MIXES } from '../constants';
import MixCard from '../components/MixCard';

export default function MixesPage() {
  return (
    <div className="pt-24 pb-40 px-6 max-w-5xl mx-auto">
      <section className="mb-12">
        <h2 className="font-headline text-4xl font-extrabold tracking-tight mb-2">Mixes</h2>
        <p className="text-on-surface-variant">Your personal soundscapes, crafted for deep focus and tranquility.</p>
      </section>

      <motion.button 
        whileHover={{ scale: 1.01 }}
        whileTap={{ scale: 0.98 }}
        className="w-full mb-10 group relative h-48 rounded-xl overflow-hidden transition-all duration-300"
      >
        <div className="absolute inset-0 bg-gradient-to-br from-primary-container/40 to-secondary-container/20 z-10 group-hover:from-primary-container/50 transition-colors" />
        <img 
          src="https://lh3.googleusercontent.com/aida-public/AB6AXuDl5duIRcvQVoZhyBcpjmlqeflpIoyX0BXHs7AQO5tFfzeP9cWG855Yf7ovudtfCJ-VQeExcvFQS1Fm7rl3nCe4Bd4kY521HSqnJ4N-ihFoeToU_8_RaU1fCGBHpzJ2LoPzj4bWmQHjcdkBOzF1ypbQJ4_M-iRjlK2G2jner-2klbNQQPtePJD8OiyQQVBqmYPBdWbRLdxf7oqyarhF-FN7Y_-6hF4PZyadU9s8rQIzvyNgu8a2sLYVhnCk11adXFDoxr35HUJAOEo" 
          alt="" 
          className="absolute inset-0 w-full h-full object-cover opacity-40 group-hover:scale-105 transition-transform duration-700"
          referrerPolicy="no-referrer"
        />
        <div className="absolute inset-0 flex flex-col items-center justify-center z-20">
          <div className="w-16 h-16 rounded-full bg-primary text-on-primary flex items-center justify-center mb-4 shadow-[0_0_24px_rgba(127,230,219,0.4)]">
            <Plus className="w-8 h-8" />
          </div>
          <span className="font-headline font-bold text-xl tracking-tight">Create New Mix</span>
        </div>
      </motion.button>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {MIXES.map((mix) => (
          <div key={mix.id}>
            <MixCard mix={mix} />
          </div>
        ))}
      </div>

      <section className="mt-20">
        <h2 className="font-headline text-2xl font-bold mb-8">Curated for You</h2>
        <div className="grid grid-cols-1 md:grid-cols-6 gap-4 h-auto md:h-[400px]">
          <div className="md:col-span-4 relative rounded-xl overflow-hidden group h-64 md:h-full">
            <img 
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuBjQF_GFecHFpKqjeCe7AjSvMFvLNKqQtqUHEhZQCVKKVDxh37EKtOAhZ6JX7AMvDkqpu1hRDBhKCy3zOCz-Q0_47oarLxueWZRN532LYfL_REGDHDCjMvM8VHlniTHT-Kq7YxXR5LSKLLMYG6sd9Eb_M0oiND21ZLAbSuuaSHdyDESNdfk90BQxbxc3nRsYsfa-yd-M4RshS05nMyHs62fI3PKdUeqD2lQXF-Kmil0GfHFVGq-cbCw4-YNw9zYWY1tQ3pjH2cZvkU" 
              alt="Nebula" 
              className="w-full h-full object-cover"
              referrerPolicy="no-referrer"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent p-6 flex flex-col justify-end">
              <span className="text-[10px] font-bold tracking-widest text-primary-fixed-dim uppercase mb-2">Editor's Choice</span>
              <h4 className="font-headline text-2xl font-bold">Deep Space Vacuum</h4>
              <p className="text-sm text-slate-300">Pure immersive silence with low-frequency hums.</p>
            </div>
          </div>
          <div className="md:col-span-2 flex flex-col gap-4">
            <div className="flex-1 relative rounded-xl overflow-hidden h-40 md:h-auto">
              <img 
                src="https://lh3.googleusercontent.com/aida-public/AB6AXuBia363qTr07V53VLTtKF83j-oA7Qu6Rpm2cy49fnEZGjpx3XSw1-sC5Ae0LPIBaAv5pqSJQffBk3fVcrMXHc5i06X0_1Thzf49TuUdfF2J7UjsEliwrZo_F9PluOmBzR4XYFnkNUZsvQ2TfYXThQs_7Zw_mGJsQxjrnEV7xgWq9c3DT_sAfwp8qoyKr-s5b9ZmhwpRpUZv3Wq80v9OX4jyHNASNUMHa-65PsXiwSYSbcHZhpaAwYnsMQwON4W6dqdPmzlNuuQNdRE" 
                alt="Blue Hour" 
                className="w-full h-full object-cover"
                referrerPolicy="no-referrer"
              />
              <div className="absolute inset-0 bg-black/40 flex items-center justify-center p-4">
                <h4 className="font-headline font-bold text-center leading-tight">Blue Hour</h4>
              </div>
            </div>
            <div className="flex-1 relative rounded-xl overflow-hidden h-40 md:h-auto">
              <img 
                src="https://lh3.googleusercontent.com/aida-public/AB6AXuD9sNtSukWRqDGBgjpub5SP-12GlcmrrHrBZroAIEISb961ouamairIbjFyx6LHGIUj578M7bE1_c7YkTzbNmgmLjyAY_ozc_bRK0JmMRwxKJRnMa23xmMslPJuIKswz9zL-b_VpEUNfqD7bOWvJg2Cp8Vc_WQZq-B_GK1Wh75hGDRBMYeIxyL5i1QkBtpejWC1ZhG4gJ5lG5BoJ0RphWsBjMf9mQqTHGFsit4vjwUXYLCUHEuRt45dcY77Fd6ZtSWnLF2quvCtKLc" 
                alt="Mist Peaks" 
                className="w-full h-full object-cover"
                referrerPolicy="no-referrer"
              />
              <div className="absolute inset-0 bg-black/40 flex items-center justify-center p-4">
                <h4 className="font-headline font-bold text-center leading-tight">Mist Peaks</h4>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
