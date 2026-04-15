# White Noise -- Sleep Sounds

A beautiful, offline-first white noise and sleep sounds app built with Swift & SwiftUI. Competes with White Noise Lite by offering the same core functionality with a modern UI inspired by Portal.app's immersive aesthetic.

**Developer:** Zalgo (Faisal Ali)
**Platform:** iOS 17+ (iPhone & iPad)
**Tech Stack:** Swift, SwiftUI, AVAudioEngine, StoreKit 2 (via RevenueCat), AdMob
**Revenue Model:** Free with banner ads -> $3.99 IAP to remove ads + unlock premium sounds

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
    TimerManager.swift             # @Observable sleep timer + alarm scheduling
    SharedPlaybackState.swift      # Widget ↔ app shared state via UserDefaults
    PlaylistManager.swift          # @Observable playlist/queue with drag-to-reorder
    SleepLogManager.swift          # @Observable sleep session tracking + weekly stats
    CustomSoundsManager.swift      # Import custom sounds from Files (MP3/M4A/WAV/AIFF)
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
    SleepTimerView.swift           # Sleep timer sheet (presets, custom, fade, alarm)
    SleepClockView.swift           # Bedside clock mode (OLED black, auto-dim)
    OnboardingView.swift           # 3-screen onboarding (welcome, features, get started)
    PlaylistView.swift             # Playlist queue with drag-to-reorder + duration control
    SleepLogView.swift             # Sleep history with weekly grouping + stats
    ScenesView.swift               # Portal-inspired full-width category scene cards
    ImportSoundView.swift          # Custom sound import from Files app
    MoreView.swift                 # Consolidated tab: Favorites, Playlist, Sleep Log, Import, Settings
  Utilities/
    Color+Hex.swift                # Color tokens + hex initializer
  ContentView.swift                # 5-tab root: Sounds, Scenes, Now Playing, Mixes, More
  White_Noise___Sleep_SoundsApp.swift  # @main entry point + RootView (deep link handling)
WhiteNoiseWidgets/
  White_Noise_Widgets.swift            # 4 widgets: small, medium, lock circular, lock rectangular
  White_Noise_WidgetsBundle.swift       # @main widget bundle entry point
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

### Phase 4 -- Widgets, Timers & Sleep Clock -- COMPLETE

- [x] Home Screen widget (medium 2x2): current sound + background image + quick-play buttons
- [x] Home Screen widget (small 1x1): play/pause icon + thumbnail
- [x] Lock Screen widget (circular): waveform icon tap-to-open
- [x] Lock Screen widget (rectangular): sound name + play/stop
- [x] Deep link URL scheme (whitenoise://) for widget actions (play, toggle, nowplaying)
- [x] Sleep timer (15m/30m/45m/1h/2h/4h presets + custom picker)
- [x] Fade-out option (volume -> 0 over last 30 seconds)
- [x] Timer countdown display on Now Playing
- [x] Alarm (UNUserNotificationCenter scheduled notification -> resume playback)
- [x] Sleep clock / bedside mode (full-screen black, large digital time, OLED-friendly)
- [x] Auto-dim after 5 seconds of no touch
- [x] Prevent auto-lock in sleep clock mode
- [x] No ads in sleep clock mode
- [x] SharedPlaybackState for widget communication (App Group UserDefaults + WidgetCenter sync)

### Phase 5 -- Full Feature Parity + Premium -- IN PROGRESS

- [x] Onboarding flow (3 screens: welcome, how it works, get started)
- [x] Playlist / queue (drag to reorder, auto-advance, per-sound duration)
- [x] Sound categories / scenes view (Portal-inspired full-width scene cards)
- [x] Sleep log (date, duration, sound played, weekly stats, stored in UserDefaults)
- [x] Import custom sounds (Files picker -> copy to app sandbox, MP3/M4A/WAV/AIFF)
- [x] "More" tab consolidating Favorites, Playlist, Sleep Log, Import, Settings
- [ ] Premium sound pack (12 locked sounds: Singing Bowl, Wind Chimes, Underwater, etc.)
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

**Phase 5 remaining items** are the next priorities:

1. **Premium sound pack** -- Add 12 locked premium sounds to the library
2. **Siri Shortcuts / AppIntents** -- "Play White Noise", "Start sleep timer" voice commands
3. **Alternate app icons** -- 3-4 alternate icons selectable from Settings

Alternatively, tackle the **Design Polish Backlog** to bring the existing UI closer to the design reference. The HomeView, DiscoverView, SoundCardView, and MiniPlayerView are key missing design-reference views.

---

## Required Assets Checklist

Everything below is needed before the app is fully functional. Generated noises (white, pink, brown, blue) work without any files -- all other sounds need audio + images.

### App Icon
- [ ] `AppIcon` -- 1024x1024 app icon in Assets.xcassets (single size, iOS auto-generates all variants)

### Launch Screen
- [ ] Launch screen / splash -- either a `LaunchScreen.storyboard` or SwiftUI launch screen configured in Info.plist (app name + logo on dark background)

### Sound Files (23 `.m4a` files)
Place in a `Sounds/` folder added to the target bundle. Ideal: 30-60 second seamless loops, AAC format, 44.1kHz.

**Rain (4 files)**
- [ ] `light_rain.m4a`
- [ ] `heavy_rain.m4a`
- [ ] `rain_on_roof.m4a` (premium)
- [ ] `thunderstorm.m4a` (premium)

**Nature (5 files)**
- [ ] `forest.m4a`
- [ ] `birds.m4a`
- [ ] `crickets.m4a` (premium)
- [ ] `wind.m4a` (premium)
- [ ] `leaves.m4a` (premium)

**Urban (3 files)**
- [ ] `city_traffic.m4a`
- [ ] `cafe.m4a`
- [ ] `train.m4a` (premium)

**Machine (4 files)**
- [ ] `fan.m4a`
- [ ] `ac.m4a`
- [ ] `dryer.m4a` (premium)
- [ ] `washing_machine.m4a` (premium)

**Fire (3 files)**
- [ ] `campfire.m4a`
- [ ] `fireplace.m4a`
- [ ] `candle.m4a` (premium)

**Water (4 files)**
- [ ] `ocean_waves.m4a`
- [ ] `river.m4a`
- [ ] `waterfall.m4a` (premium)
- [ ] `underwater.m4a` (premium)

### Background Images (27 images in Assets.xcassets)
Used on the Now Playing screen and mix cards. Ideal: landscape 1920x1080 or similar, dark/moody aesthetic.

**Noise**
- [ ] `bg_white_noise`
- [ ] `bg_pink_noise`
- [ ] `bg_brown_noise`
- [ ] `bg_blue_noise`

**Rain**
- [ ] `bg_light_rain`
- [ ] `bg_heavy_rain`
- [ ] `bg_rain_on_roof`
- [ ] `bg_thunderstorm`

**Nature**
- [ ] `bg_forest`
- [ ] `bg_birds`
- [ ] `bg_crickets`
- [ ] `bg_wind`
- [ ] `bg_leaves`

**Urban**
- [ ] `bg_city_traffic`
- [ ] `bg_cafe`
- [ ] `bg_train`

**Machine**
- [ ] `bg_fan`
- [ ] `bg_ac`
- [ ] `bg_dryer`
- [ ] `bg_washing_machine`

**Fire**
- [ ] `bg_campfire`
- [ ] `bg_fireplace`
- [ ] `bg_candle`

**Water**
- [ ] `bg_ocean_waves`
- [ ] `bg_river`
- [ ] `bg_waterfall`
- [ ] `bg_underwater`

### Asset Sources (Royalty-Free Suggestions)
- **Sound files:** freesound.org (CC0 license), Pixabay audio, Zapsplat (free tier)
- **Background images:** Unsplash (free), Pexels (free), Pixabay (free)
- **App icon:** Design in Figma/Canva or commission -- waveform + moon motif recommended

---

## Build & Run

1. Open `White Noise - Sleep Sounds.xcodeproj` in Xcode
2. Resolve packages: File > Packages > Resolve Package Versions
3. Select your target device/simulator
4. Build and run (Cmd+R)

**Note:** Sound files (.m4a) should be placed in a `Sounds/` folder in the bundle. Background images should be added to Assets.xcassets with names matching `bg_<sound_id>`.
