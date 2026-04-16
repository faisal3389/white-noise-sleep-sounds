/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { BrowserRouter as Router, Routes, Route, useLocation } from 'react-router-dom';
import { AnimatePresence, motion } from 'motion/react';
import TopAppBar from './components/TopAppBar';
import BottomNavBar from './components/BottomNavBar';
import NowPlayingWidget from './components/NowPlayingWidget';
import HomePage from './pages/HomePage';
import DiscoverPage from './pages/DiscoverPage';
import MixesPage from './pages/MixesPage';
import FavoritesPage from './pages/FavoritesPage';
import SettingsPage from './pages/SettingsPage';
import PlayerPage from './pages/PlayerPage';

function AppContent() {
  const location = useLocation();
  const isPlayerPage = location.pathname === '/player';

  return (
    <div className="min-h-screen bg-background text-on-background">
      {!isPlayerPage && <TopAppBar />}
      
      <main className="ios-scrollbar">
        <AnimatePresence mode="wait">
          <motion.div
            key={location.pathname}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.3 }}
          >
            <Routes location={location}>
              <Route path="/" element={<HomePage />} />
              <Route path="/discover" element={<DiscoverPage />} />
              <Route path="/mixes" element={<MixesPage />} />
              <Route path="/favorites" element={<FavoritesPage />} />
              <Route path="/settings" element={<SettingsPage />} />
              <Route path="/player" element={<PlayerPage />} />
            </Routes>
          </motion.div>
        </AnimatePresence>
      </main>

      {!isPlayerPage && (
        <>
          <NowPlayingWidget />
          <BottomNavBar />
        </>
      )}
    </div>
  );
}

export default function App() {
  return (
    <Router>
      <AppContent />
    </Router>
  );
}

