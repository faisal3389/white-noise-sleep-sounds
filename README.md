# White Noise -- Sleep Sounds

A beautiful, offline-first white noise and sleep sounds app built with Swift & SwiftUI. Competes with White Noise Lite by offering the same core functionality with a modern UI inspired by Portal.app's immersive aesthetic.

**Developer:** Zalgo (Faisal Ali)
**Platform:** iOS 17+ (iPhone & iPad)
**Tech Stack:** Swift, SwiftUI, AVAudioEngine, StoreKit 2 (via RevenueCat), AdMob
**Revenue Model:** Free with banner ads -> $0.99 IAP to remove ads + unlock premium sounds

---

## Project Structure

```
White Noise - Sleep Sounds/
  Audio/
    AudioEngine.swift              # AVAudioEngine: single + multi-sound (up to 5 nodes)
  Models/
    Sound.swift                    # Sound struct + SoundCategory enum
    SoundLibrary.swift             # 27 sounds across 7 categories (4 generated noise)
    SoundMix.swift                 # SoundMix + MixComponent structs (Codable)
    MixesManager.swift             # @Observable, UserDefaults persistence, curated mixes
    FavoritesManager.swift         # @Observable, UserDefaults persistence
    StoreManager.swift             # RevenueCat IAP wrapper (conditional import)
    SettingsManager.swift          # App settings persistence
  ViewModels/
    AudioPlayerViewModel.swift     # Playback state for single sounds + mixes
  Views/
    SoundsListView.swift           # Sound list with search + categories
    NowPlayingView.swift           # Full-screen player with mixer sheet
    FavoritesView.swift            # Favorited sounds grid
    MixesView.swift                # Mixes tab: hero card, saved mixes grid, curated section
    MixCardView.swift              # Split-image grid card with play/edit overlay
    CreateMixView.swift            # Sheet: sound grid, volume sliders, preview/save
    SettingsView.swift             # Settings screen
    SoundRowView.swift             # Reusable sound list row
    AirPlayButton.swift            # AVRoutePickerView wrapper
    BannerAdView.swift             # AdMob banner (conditional import)
    PremiumUpgradeView.swift       # IAP purchase sheet
  Utilities/
    Color+Hex.swift                # Color tokens + hex initializer
  ContentView.swift                # 5-tab root layout
  White_Noise___Sleep_SoundsApp.swift  # @main entry point
```

---

## Development Progress

### Phase 1 -- MVP (Sound Playback & Core UI) -- COMPLETE

- [x] Sound data model (Sound struct, SoundCategory enum, SoundLibrary with 27 sounds)
- [x] AVAudioEngine-based audio playback (file-based + procedural noise)
- [x] Procedural noise generation (white, pink, brown, blue noise)
- [x] Sound list with search (SoundsListView)
- [x] Play/pause/skip/previous transport controls
- [x] Volume control (master volume slider)
- [x] Full-screen Now Playing view with background images
- [x] Favorites system with UserDefaults persistence
- [x] Favorites view (FavoritesView)
- [x] Background audio (AVAudioSession .playback category)
- [x] Dark theme with color tokens (Color+Hex.swift)

#### Not yet matching design reference:
- [ ] HomeView (hero section "Morning Sanctuary" + bento grid of SoundCards)
- [ ] DiscoverView (search + category pills + 3-column SoundCard grid)
- [ ] SoundCardView (portrait 4:5 / landscape variants with gradient overlays)
- [ ] MiniPlayerView (floating bar above tab bar with EQ animation)
- [ ] Full glass morphism on tab bar and navigation
- [ ] Design token system matching PRD Section 4.2 (currently simplified)
- [ ] Staggered entrance animations on cards

### Phase 2 -- Monetization & Polish -- COMPLETE

- [x] Banner ads (AdMob via BannerAdView, conditional import)
- [x] IAP integration (RevenueCat StoreManager, conditional import)
- [x] Premium upgrade sheet (PremiumUpgradeView)
- [x] Settings screen (SettingsView: premium, playback, about sections)
- [x] AirPlay support (AVRoutePickerView wrapper)
- [x] Premium sound gating (lock icon on premium sounds, purchase prompt)

### Phase 3 -- Mixes & Customization -- COMPLETE

- [x] SoundMix + MixComponent data models (Codable, Hashable)
- [x] MixesManager with UserDefaults JSON persistence
- [x] AudioEngine multi-sound playback (up to 5 simultaneous AVAudioPlayerNode/AVAudioSourceNode)
- [x] Independent per-component volume control
- [x] AudioPlayerViewModel mix playback support (playMix, adjustComponentVolume, nextMix/previousMix)
- [x] MixesView: "Create New Mix" hero card with gradient + glow
- [x] MixesView: Saved mixes 2-column LazyVGrid
- [x] MixesView: "Curated for You" editorial section (asymmetric layout)
- [x] MixCardView: split-image grid, play/edit overlay, active badge
- [x] CreateMixView: 3-column sound grid, checkmark selection, volume sliders, preview/save
- [x] NowPlayingView: mix-aware display (title, subtitle, background image)
- [x] NowPlayingView: Mixer button opens bottom sheet with per-component volume sliders
- [x] Next/previous navigation cycles through saved mixes
- [x] 3 curated mixes (Rainy Forest, Ocean Breeze, Cozy Cabin)
- [x] Context menu on mix cards (favorite, delete)

### Phase 4 -- Widgets, Timers & Sleep Clock -- NOT STARTED

- [ ] Home Screen widget (medium 2x2): current sound + background image + quick-play buttons
- [ ] Home Screen widget (small 1x1): play/pause icon + thumbnail
- [ ] Lock Screen widget (circular): waveform icon tap-to-open
- [ ] Lock Screen widget (rectangular): sound name + play/stop
- [ ] AppIntents for widget actions (PlaySoundIntent)
- [ ] Sleep timer (15m/30m/45m/1h/2h/4h presets + custom picker)
- [ ] Fade-out option (volume -> 0 over last 30 seconds)
- [ ] Timer countdown display on Now Playing
- [ ] Alarm (UNUserNotificationCenter scheduled notification -> resume playback)
- [ ] Sleep clock / bedside mode (full-screen black, large digital time, OLED-friendly)
- [ ] Auto-dim after 5 seconds of no touch
- [ ] Prevent auto-lock in sleep clock mode
- [ ] No ads in sleep clock mode

### Phase 5 -- Full Feature Parity + Premium -- NOT STARTED

- [ ] Playlist / queue (drag to reorder, auto-advance, per-sound duration)
- [ ] Premium sound pack (12 locked sounds: Singing Bowl, Wind Chimes, Underwater, etc.)
- [ ] Sound categories / scenes view (Portal-inspired full-width scene cards)
- [ ] Onboarding flow (3 screens: welcome, sound picker, notification permission)
- [ ] Sleep log (basic: date, duration, sound played, stored in UserDefaults)
- [ ] Import custom sounds (Files picker -> copy to app sandbox)
- [ ] App Shortcuts / Siri integration (SiriKit AppIntents)
- [ ] Alternate app icons

### Design Polish Backlog (can be done anytime)

- [ ] Update color tokens to match PRD Section 4.2 exactly (#7FE6DB primary, #96A5FF secondary, #0C0E12 background)
- [ ] HomeView with hero section + bento grid (matches HomePage.tsx)
- [ ] DiscoverView with search + category pills + 3-column grid (matches DiscoverPage.tsx)
- [ ] SoundCardView portrait/landscape variants (matches SoundCard.tsx)
- [ ] MiniPlayerView floating bar with EQ animation (matches NowPlayingWidget.tsx)
- [ ] Glass morphism on tab bar (slate-950/70 bg, backdrop-blur, 32pt top corners)
- [ ] Glass morphism on navigation bar (TopAppBar.tsx)
- [ ] NowPlayingView: progress bar gradient (primary -> secondary) with glow
- [ ] NowPlayingView: floating action bar (Audio/Timer/Mixer glass pill)
- [ ] Staggered card entrance animations
- [ ] Card press scale animation (0.98) on all SoundCards

---

## Next Phase Recommendation

**Phase 4 (Widgets, Timers & Sleep Clock)** is the next development phase. Key priorities:

1. **Sleep Timer** -- High user value, relatively simple (Timer + volume fade)
2. **Sleep Clock** -- Bedside mode is a strong differentiator, straightforward implementation
3. **WidgetKit widgets** -- Increases engagement via home/lock screen presence, requires AppIntents

Alternatively, tackle the **Design Polish Backlog** first to bring the existing UI closer to the design reference before adding new features. The HomeView, DiscoverView, SoundCardView, and MiniPlayerView are key missing design-reference views.

---

## Build & Run

1. Open `White Noise - Sleep Sounds.xcodeproj` in Xcode
2. Resolve packages: File > Packages > Resolve Package Versions
3. Select your target device/simulator
4. Build and run (Cmd+R)

**Note:** Sound files (.m4a) should be placed in a `Sounds/` folder in the bundle. Background images should be added to Assets.xcassets with names matching `bg_<sound_id>`.
