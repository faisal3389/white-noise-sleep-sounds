# White Noise — Sleep Sounds
## Complete Product Requirements Document (PRD)
### Your End-to-End Guide to Building, Monetizing & Publishing

---

**Developer:** Zalgo (Faisal Ali)  
**Platform:** iOS 17+ (iPhone & iPad)  
**Tech Stack:** Swift, SwiftUI, AVAudioEngine, WidgetKit, StoreKit 2  
**Architecture:** Offline-first, all sounds bundled in-app  
**Revenue Model:** Freemium — free with core sounds (no ads) → $3.99 IAP to unlock premium sounds  
**App Store Metadata:**
- **Name (30 chars):** `White Noise — Sleep Sounds`
- **Subtitle (30 chars):** `Rain, Fan & Nature Sound Mixer`
- **Keywords (100 chars):** `calm,focus,baby,study,deep,brown,pink,ocean,background,machine,meditation,relax,noises,ambience,aid`

---

# TABLE OF CONTENTS

1. [Product Vision](#1-product-vision)
2. [Competitor Analysis — White Noise Lite Teardown](#2-competitor-analysis)
3. [Portal.app Inspiration](#3-portalapp-inspiration)
4. [Design Reference System (Source of Truth)](#4-design-reference-system)
5. [Feature Matrix by Phase](#5-feature-matrix-by-phase)
6. [Phase 1 — MVP (Week 1-2)](#6-phase-1--mvp)
7. [Phase 2 — Monetization & Polish (Week 3)](#7-phase-2--monetization--polish)
8. [Phase 3 — Mixes & Customization (Week 4)](#8-phase-3--mixes--customization)
9. [Phase 4 — Widgets, Timers & Sleep Clock (Week 5)](#9-phase-4--widgets-timers--sleep-clock)
10. [Phase 5 — Full Feature Parity + Premium (Week 6)](#10-phase-5--full-feature-parity--premium)
11. [External Design Asset List](#11-external-design-asset-list)
12. [Sound Asset List](#12-sound-asset-list)
13. [Payment Integration (StoreKit 2)](#13-payment-integration-storekit-2)
14. [Monetization Strategy — Ad-Free Freemium](#14-monetization-strategy--ad-free-freemium)
15. [App Store Publishing Guide](#15-app-store-publishing-guide)
16. [Vibe Coding Prompts by Phase](#16-vibe-coding-prompts-by-phase)

---

# 1. PRODUCT VISION

Build a beautiful, offline-first white noise and sleep sounds app that competes with White Noise Lite by offering the same core functionality (sound playback, mixing, timers, sleep clock) with a more modern UI inspired by Portal.app's immersive aesthetic. Monetize with a freemium model: the free tier includes 27 core sounds with no ads (ads disrupt the sleep experience), and a single $3.99 IAP unlocks 12 premium sounds. The goal is your first dollar of app revenue.

**Core Differentiators from White Noise Lite:**
- Modern SwiftUI design with full-screen immersive backgrounds (Portal-inspired)
- Completely ad-free experience — no banner ads disrupting sleep/relaxation
- One-time $3.99 purchase instead of subscription pressure
- Cleaner, less cluttered UI
- Same sounds, better experience

**Core Differentiators from Portal.app:**
- Free to use with no ads (Portal charges subscription)
- Focused on sleep/relaxation, not just productivity
- Simpler — no spatial audio or smart lighting, just great sounds with beautiful visuals

---

# 2. COMPETITOR ANALYSIS

## White Noise Lite — Full Feature Teardown (from screenshots)

### Screen 1: Now Playing
- Full-screen background image matching the current sound theme (e.g., fireplace shows flames)
- Transport controls: previous / play-pause / next
- Volume slider
- AirPlay / Cast button
- Heart/favorite button (top right)
- Sound title displayed prominently
- Banner ad at bottom of screen (non-intrusive, sits below controls)

### Screen 2: Sounds List
- Search bar at top
- Scrollable list of sounds with: thumbnail image (circle), sound name, heart icon, info (i) icon
- Categories visible: Air Conditioner, Airplane Interior, Amazon Jungle, Beach Waves Crashing, Birds Singing, Blue Noise, Boat Swaying, Brown Noise, Camp Fire, Cars Driving, Cat Purring, Chimes Chiming, City Streets, Clothes Dryer, etc.
- "Upgrade White Noise" button at bottom (upsell to paid version)
- Banner ad at very bottom

### Screen 3: Mixes
- List of saved sound combinations
- Each mix shows: mix name, component sounds listed below (e.g., "Heavy Rain, Thunder"), heart icon
- "Upgrade White Noise" upsell banner
- Banner ad at bottom

### Screen 4: Playlist
- Queue of sounds to play in sequence
- Edit button for reordering
- Each item shows thumbnail + name

### Screen 5: Sleep Clock
- Full-screen black background
- Large digital time display (bedside clock mode)
- Minimal — designed for nightstand use

### Screen 6: Sidebar Menu
Full navigation menu listing:
- Sounds
- Mixes
- Favorites
- Playlist
- Create Sound
- Download Sounds
- Manage Sounds
- Timers & Alarms
- Sleep Clock
- Upgrade App
- Sleep Log
- Settings
- About / Help / Rate / Share

### Screen 7: Create Actions
- Create Recording (record ambient sounds via microphone)
- Create Mix (combine multiple sounds)
- Download Sounds (get additional sounds from server)

### Screen 8: Ad Placement Detail
- Banner ads appear at screen bottom on all non-playback screens
- Ads are standard AdMob banner size (320x50 or adaptive)
- Not shown during sleep clock mode
- No interstitial ads visible — they keep it non-intrusive

---

# 3. PORTAL.APP INSPIRATION

Portal is a premium Mac/iOS app that transforms your surroundings into immersive nature environments for focus and relaxation. Key design elements to borrow:

**What to Take from Portal:**
- **Full-motion cinematic backgrounds:** Portal uses video of natural landscapes. For our app, we'll use high-quality still images (much simpler to implement, smaller app size) but with subtle animation effects (slow parallax, gentle particle effects like rain drops or firefly dots)
- **Immersive full-screen experience:** The Now Playing screen should feel like a window into another world, not a media player
- **Moody, dark UI:** Portal uses a dark theme with minimal chrome. Our UI should use translucent overlays on top of backgrounds, not opaque panels
- **Category as "portals":** Instead of a flat list, group sounds into themed "scenes" (Forest, Ocean, Rain, Urban, Machine) with each scene having its own visual world
- **Subtle transitions:** Smooth crossfades between sounds and their background visuals
- **100+ destinations concept:** Portal has 100+ scenes. We should aim for 30+ sounds at launch, expanding to 50+ with premium

**What NOT to Take from Portal:**
- Spatial audio (too complex, not needed for white noise)
- Smart lighting integration (scope creep)
- Subscription pricing (we're doing one-time $3.99)
- Video backgrounds (too large, kills app size — use animated stills instead)

---

# 4. DESIGN REFERENCE SYSTEM (SOURCE OF TRUTH)

> **COUPLING RULE:** The React design reference app in `white-noise-designs-google-aistudios/` is the single source of truth for all visual design decisions. When any design file in that folder is updated, the corresponding SwiftUI views and vibe coding prompts in this PRD MUST be updated to match. The React code defines WHAT it looks like; this PRD translates HOW to build it in SwiftUI.

## 4.1 Design Reference File Map

The design reference is a React + Tailwind + Vite app built via Google AI Studio (codename "Ethereal"). Each file maps to a SwiftUI view:

| Design Reference File | → SwiftUI Target | Purpose |
|---|---|---|
| `src/App.tsx` | `ContentView.swift` | Root layout: 5-tab navigation + full-screen player overlay. Player page hides tabs + top bar |
| `src/pages/HomePage.tsx` | `HomeView.swift` | Hero section ("Morning Sanctuary.") + bento grid of SoundCards (1 landscape + 3 portrait + 1 wide horizontal) |
| `src/pages/DiscoverPage.tsx` | `DiscoverView.swift` | Search bar + horizontal category filter pills + 3-column grid of SoundCards |
| `src/pages/MixesPage.tsx` | `MixesView.swift` | "Create New Mix" hero card + saved mix grid + "Curated for You" editorial section |
| `src/pages/FavoritesPage.tsx` | `FavoritesView.swift` | Empty state centered text, or grid of favorited SoundCards |
| `src/pages/SettingsPage.tsx` | `SettingsView.swift` | Stacked rounded cards (Account, Audio Quality, Appearance) on dark background |
| `src/pages/PlayerPage.tsx` | `NowPlayingView.swift` | **THE HERO SCREEN** — full-screen immersive blurred background, transport controls, progress bar, floating action bar (Audio/Timer/Mixer) |
| `src/components/SoundCard.tsx` | `SoundCardView.swift` | Reusable card: portrait (4:5 aspect) or landscape variant. Image background, gradient overlay, category label, title, duration, hover→heart/info buttons |
| `src/components/MixCard.tsx` | `MixCardView.swift` | Split-image grid (2 cols), overlay play button on hover, edit button, title + description below |
| `src/components/NowPlayingWidget.tsx` | `MiniPlayerView.swift` | Floating mini-player bar: album art thumbnail, sound name, animated EQ bars, play/pause + dismiss. Sits above bottom tab bar |
| `src/components/TopAppBar.tsx` | (NavigationBar styling) | Glass-effect fixed header: app logo (Waves icon + "White Noise" text in primary color), search + profile buttons |
| `src/components/BottomNavBar.tsx` | (TabView styling) | Glass-effect bottom nav: 5 tabs (Home/Discover/Mixes/Favorites/Settings), uppercase 10px tracking-widest labels, active = primary color + scale 110% |
| `src/constants.ts` | `SoundLibrary.swift` | 10 curated sounds with titles, categories, descriptions, image URLs, durations, tags + 2 pre-built mixes |
| `src/types.ts` | `Sound.swift`, `Mix.swift` | TypeScript interfaces → Swift structs: Sound (id, title, category, description, imageUrl, duration, tags), Mix (id, title, description, imageUrls, sounds), Category enum |
| `src/index.css` | `Theme.swift` | **COMPLETE COLOR TOKEN SYSTEM** — see Section 4.2 below |

## 4.2 Design Token System (from `src/index.css`)

**ALL SwiftUI views MUST use these exact color tokens. Do NOT invent new colors.**

### Color Palette (Material Design 3 — Dark Theme)

| Token | Hex | SwiftUI Usage |
|---|---|---|
| `primary` | `#7FE6DB` | Accent color, active tab, CTA buttons, category labels, progress bar, heart fills |
| `secondary` | `#96A5FF` | Secondary accents, category subtitle on PlayerPage |
| `tertiary` | `#CCF9FF` | Tertiary highlights |
| `background` | `#0C0E12` | App background (near-black) |
| `surface` | `#0C0E12` | Same as background |
| `surface-container-low` | `#111318` | Card backgrounds (SoundCard default) |
| `surface-container` | `#171A1F` | Mid-elevation surfaces |
| `surface-container-high` | `#1D2025` | Elevated cards (search bar, settings cards, "Create Mix" overlay) |
| `surface-container-highest` | `#23262C` | Highest elevation |
| `on-background` | `#F6F6FC` | Primary text on backgrounds |
| `on-surface` | `#F6F6FC` | Primary text on surfaces |
| `on-surface-variant` | `#AAABB0` | Secondary/muted text (descriptions, subtitles, inactive tabs) |
| `on-primary` | `#00534D` | Text on primary-colored surfaces (e.g., text inside the play button circle) |
| `primary-container` | `#47B0A7` | Gradient endpoint for primary buttons (play button gradient: `primary` → `primary-container`) |
| `secondary-container` | `#2F3F92` | Secondary container fills |
| `outline` | `#74757A` | Search placeholder text, borders |
| `outline-variant` | `#46484D` | Subtle dividers |
| `error` | `#FF716C` | Error states |

### Typography

| Role | Font | Weight | Usage |
|---|---|---|---|
| Headline | **Manrope** (→ iOS: use `.rounded` design or bundle Manrope) | ExtraBold (800) | Page titles, sound names, hero text, tab labels |
| Body | **Inter** (→ iOS: system `.body` font) | Regular (400), Medium (500) | Descriptions, secondary text |

### Key Typography Patterns (from design reference)

| Pattern | CSS Class | SwiftUI Equivalent |
|---|---|---|
| Page title | `text-5xl font-headline font-extrabold tracking-tighter` | `.font(.system(size: 48, weight: .heavy, design: .rounded))` + `.tracking(-1)` |
| Category label | `text-[10px] uppercase tracking-widest font-bold font-headline` | `.font(.system(size: 10, weight: .bold, design: .rounded))` + `.textCase(.uppercase)` + `.tracking(2)` |
| Card title | `text-2xl font-headline font-bold` | `.font(.system(size: 24, weight: .bold, design: .rounded))` |
| Body text | `text-lg text-on-surface-variant` | `.font(.body)` + `.foregroundStyle(Color.onSurfaceVariant)` |
| Tab label | `text-[10px] uppercase tracking-widest font-bold` | `.font(.system(size: 10, weight: .bold))` + `.textCase(.uppercase)` + `.tracking(2)` |

## 4.3 Key Design Patterns to Replicate in SwiftUI

### Glass Morphism (used extensively)
```swift
// Bottom nav bar, top app bar, floating mini-player, player action bar
.background(.ultraThinMaterial)
.background(Color.black.opacity(0.7))
.overlay(RoundedRectangle(cornerRadius: radius).stroke(Color.white.opacity(0.05)))
```

### Card Radius System
| Element | Radius | CSS | SwiftUI |
|---|---|---|---|
| SoundCard (portrait) | 24pt | `rounded-[1.5rem]` | `.clipShape(RoundedRectangle(cornerRadius: 24))` |
| SoundCard (landscape) / wide card | 32pt | `rounded-[2rem]` | `.clipShape(RoundedRectangle(cornerRadius: 32))` |
| Settings card | 16pt | `rounded-2xl` | `.clipShape(RoundedRectangle(cornerRadius: 16))` |
| Mini-player | 16pt | `rounded-2xl` | `.clipShape(RoundedRectangle(cornerRadius: 16))` |
| Search bar | 16pt | `rounded-2xl` | `.clipShape(RoundedRectangle(cornerRadius: 16))` |
| Bottom nav | 32pt top | `rounded-t-[2rem]` | Custom clip shape |
| Category pills | Full | `rounded-full` | `.clipShape(Capsule())` |
| Play button (large) | Full | `rounded-full` | `.clipShape(Circle())` |

### Gradient Overlays on Image Cards
```swift
// From design: bg-gradient-to-t from-slate-950 via-slate-950/20 to-transparent
LinearGradient(
    colors: [Color.black, Color.black.opacity(0.2), Color.clear],
    startPoint: .bottom, endPoint: .top
)
```

### Progress Bar (PlayerPage)
```swift
// Gradient bar with glow shadow
.fill(LinearGradient(colors: [Color.primary, Color.secondary], startPoint: .leading, endPoint: .trailing))
.shadow(color: Color.primary.opacity(0.5), radius: 6, y: 0)
```

### Floating Action Bar (PlayerPage bottom)
```swift
// Three buttons: Audio, Timer, Mixer — centered, glass pill
HStack(spacing: 24) { /* Audio, Timer, Mixer columns */ }
    .padding(.horizontal, 32)
    .padding(.vertical, 16)
    .background(.ultraThinMaterial)
    .background(Color(hex: "0C0E12").opacity(0.7))
    .clipShape(Capsule())
    .shadow(color: .black.opacity(0.3), radius: 16, y: -4)
```

### Animation Patterns
| Animation | Design Reference | SwiftUI |
|---|---|---|
| Page enter | `opacity: 0, y: 10 → 1, 0` | `.transition(.opacity.combined(with: .move(edge: .bottom)))` |
| Card press | `whileTap: { scale: 0.98 }` | `.scaleEffect(isPressed ? 0.98 : 1.0)` with `ButtonStyle` |
| Card hover | `whileHover: { scale: 1.02 }` | N/A on iOS (use press feedback instead) |
| Staggered cards | `delay: 0.3 + i * 0.1` | `.animation(.easeOut.delay(0.3 + Double(i) * 0.1))` |
| EQ bars (mini player) | `animate: { height: [8, 12, 8] }` repeat | Looping height animation on 3 thin rectangles |

## 4.4 Navigation Structure (from `src/App.tsx`)

```
App
├── TabView (5 tabs — hidden when PlayerPage is active)
│   ├── Tab 1: Home (house.fill) → HomeView
│   ├── Tab 2: Discover (magnifyingglass) → DiscoverView
│   ├── Tab 3: Mixes (square.stack.fill) → MixesView
│   ├── Tab 4: Favorites (heart.fill) → FavoritesView
│   └── Tab 5: Settings (gearshape.fill) → SettingsView
│
├── MiniPlayerView (floating above tab bar — visible on all tabs when sound is playing)
│   └── Tap → opens NowPlayingView
│
└── NowPlayingView (full-screen overlay — hides tab bar + top bar)
    ├── Dismiss chevron (top-left)
    ├── Immersive blurred background image
    ├── Transport controls (shuffle, skip-back, play/pause, skip-forward, repeat)
    ├── Progress bar (gradient primary→secondary)
    ├── Volume slider
    └── Floating action bar (Audio / Timer / Mixer)
```

## 4.5 Coupling Protocol

When updating the design reference app:

1. **Update the React file** in `white-noise-designs-google-aistudios/src/`
2. **Update the corresponding row** in Section 4.1 (File Map) if the mapping changed
3. **Update Section 4.2** (Tokens) if colors/typography changed
4. **Update the corresponding Vibe Coding Prompt** in Section 16 to reflect the new design
5. **Re-generate SwiftUI views** using the updated prompt

This ensures the design reference and the iOS implementation stay in sync. The React app is the design spec; the PRD prompts are the translation layer.

---

# 5. FEATURE MATRIX BY PHASE

| Feature | Phase 1 (MVP) | Phase 2 | Phase 3 | Phase 4 | Phase 5 |
|---|---|---|---|---|---|
| Sound playback (single) | X | | | | |
| Background audio | X | | | | |
| Full-screen Now Playing | X | | | | |
| Sound list with search | X | | | | |
| Play/pause/skip controls | X | | | | |
| Volume control | X | | | | |
| Favorites | X | | | | |
| Theme backgrounds per sound | X | | | | |
| IAP — Unlock Premium Sounds ($3.99) | | X | | | |
| Settings screen | | X | | | |
| AirPlay support | | X | | | |
| Sound mixing (2-5 sounds) | | | X | | |
| Individual volume per sound in mix | | | X | | |
| Save/load custom mixes | | | X | | |
| Mix editor UI | | | X | | |
| Home Screen widget | | | | X | |
| Lock Screen widget | | | | X | |
| Sleep timer | | | | X | |
| Alarm | | | | X | |
| Sleep clock (bedside mode) | | | | X | |
| Playlist / queue | | | | | X |
| Premium sounds (locked) | | | | | X |
| Sound categories / scenes | | | | | X |
| Onboarding flow | | | | | X |
| Sleep log (basic) | | | | | X |
| Import custom sounds | | | | | X |
| App Shortcuts (Siri) | | | | | X |

---

# 6. PHASE 1 — MVP (Week 1-2)

**Goal:** A working app that plays white noise sounds with a beautiful UI matching the design reference. No ads, no payments — just core playback.

## 6.1 Architecture

```
WhiteNoiseSleepSounds/
├── App/
│   ├── WhiteNoiseSleepSoundsApp.swift      // @main entry point
│   └── ContentView.swift                    // 5-tab root + MiniPlayer overlay
├── Theme/
│   └── Theme.swift                          // Color tokens from Section 4.2, typography helpers
├── Models/
│   ├── Sound.swift                          // Sound data model (matches src/types.ts)
│   ├── SoundCategory.swift                  // Category enum
│   └── FavoritesManager.swift               // UserDefaults persistence
├── Views/
│   ├── HomeView.swift                       // Hero + bento grid (matches HomePage.tsx)
│   ├── DiscoverView.swift                   // Search + category pills + grid (matches DiscoverPage.tsx)
│   ├── NowPlayingView.swift                 // Full-screen immersive player (matches PlayerPage.tsx)
│   ├── FavoritesView.swift                  // Favorite sounds grid
│   ├── SoundCardView.swift                  // Reusable card: portrait/landscape (matches SoundCard.tsx)
│   ├── MiniPlayerView.swift                 // Floating now-playing bar (matches NowPlayingWidget.tsx)
│   └── PlayerControlsView.swift             // Transport controls within NowPlayingView
├── ViewModels/
│   ├── AudioPlayerViewModel.swift           // AVAudioEngine wrapper
│   └── SoundsViewModel.swift                // Sound list state
├── Audio/
│   ├── AudioEngine.swift                    // AVAudioEngine setup
│   └── NoiseGenerator.swift                 // Procedural white/pink/brown noise
├── Resources/
│   ├── Sounds/                              // Bundled .m4a files
│   └── Backgrounds/                         // Full-screen background images
└── Utilities/
    └── Extensions.swift                     // Color, View extensions
```

## 6.2 Data Model

```swift
struct Sound: Identifiable, Codable, Hashable {
    let id: String                  // e.g., "heavy_rain"
    let name: String                // "Heavy Rain"
    let category: SoundCategory     // .rain, .nature, .machine, etc.
    let fileName: String            // "heavy_rain.m4a"
    let backgroundImage: String     // "bg_heavy_rain"
    let isPremium: Bool             // false for free, true for locked
    let isGenerated: Bool           // true for white/pink/brown noise (procedural)
}

enum SoundCategory: String, Codable, CaseIterable {
    case noise = "Noise"            // White, Pink, Brown, Blue
    case rain = "Rain"              // Heavy Rain, Light Rain, Rain on Tent, etc.
    case nature = "Nature"          // Ocean, Birds, Crickets, Wind, Thunder
    case urban = "Urban"            // City Streets, Café, Train
    case machine = "Machine"        // Fan, Air Conditioner, Dryer, Airplane
    case fire = "Fire"              // Campfire, Fireplace
    case water = "Water"            // Stream, Waterfall, Fountain
}
```

## 6.3 Audio Engine

Use `AVAudioEngine` from the start (not `AVAudioPlayer`) — this makes Phase 3 mixing trivial.

```swift
// Core architecture:
// AVAudioEngine
//   └── AVAudioMixerNode (main mixer)
//        ├── AVAudioPlayerNode (slot 1 — file-based sound)
//        ├── AVAudioPlayerNode (slot 2 — for mixing later)
//        ├── AVAudioPlayerNode (slot 3)
//        ├── AVAudioPlayerNode (slot 4)
//        └── AVAudioSourceNode (procedural noise generator)
```

**Background audio:** Add "Audio, AirPlay, and Picture in Picture" to Capabilities in Xcode.

```swift
// In AudioEngine.swift init:
let session = AVAudioSession.sharedInstance()
try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
try session.setActive(true)
```

## 6.4 Procedural Noise Generation

For White Noise, Pink Noise, Brown Noise — generate audio in real-time instead of bundling files:

```swift
// White noise: random samples
// Pink noise: apply -3dB/octave filter to white noise
// Brown noise: integrate white noise (cumulative sum with decay)

// Use AVAudioSourceNode with a render block that fills the buffer
// with random Float values (-1.0 to 1.0) for white noise
```

## 6.5 UI Design Specs (matches Design Reference — see Section 4)

> **IMPORTANT:** All UI specs below are derived from the React design reference in `white-noise-designs-google-aistudios/`. Refer to Section 4 for the complete token system. When the design reference changes, update these specs accordingly.

**HomeView (matches `HomePage.tsx`):**
- Hero section: "Daily Refresh" pill badge (primary/10 bg, primary text, 10px uppercase tracking-widest) → Large title "Morning Sanctuary." (48pt heavy rounded, tracking -1) with "Sanctuary" in primary color → Subtitle paragraph in on-surface-variant
- Bento grid below: 3-column grid — first card spans 2 columns (landscape SoundCard), 3 portrait SoundCards in remaining cells, 1 full-width horizontal card at bottom (32pt radius, 256pt height, left-aligned text overlay with gradient-to-r)
- Staggered entrance animations (0.3s base + 0.1s per card)

**DiscoverView (matches `DiscoverPage.tsx`):**
- Title: "Discover Peace" (48pt heavy rounded, tracking tight)
- Search bar: surface-container-high background, 16pt radius, magnifying glass icon left, placeholder "Search sounds, moods, or places..."
- Horizontal scrolling category pills: Capsule shape, active = primary bg + on-primary text, inactive = surface-container-high bg + on-surface text. Categories: All, Nature, Rain, ASMR, Urban, Focus
- 3-column grid of portrait SoundCards below

**NowPlayingView / PlayerPage (matches `PlayerPage.tsx`) — THE HERO SCREEN:**
- Full-screen blurred background image (opacity 60%, scale 105%, blur 2px)
- Gradient overlay: bottom→top from background solid → background/40 → transparent
- Header bar: dismiss chevron-down (left), app logo (AudioLines icon + "White Noise" in primary, center), spacer (right)
- Content pinned to bottom: category label ("Atmosphere" — 10px uppercase tracking-widest, secondary color), title (40pt heavy), subtitle (on-surface-variant), heart button (48×48 circle, on-background/10 bg, backdrop blur)
- Progress bar: 6pt height, on-background/20 track, gradient fill (primary→secondary) with glow shadow, time labels (10px uppercase tracking-widest)
- Transport controls: shuffle | skip-back | **PLAY (80×80 circle, gradient primary→primary-container, on-primary icon, large shadow)** | skip-forward | repeat
- Volume slider: Volume2 icon + thin 4pt bar (on-background/10 track, on-background/40 fill)
- Floating action bar (fixed bottom): glass pill with 3 icon+label columns — Audio (primary when active), Timer (muted), Mixer (muted). Glass bg: slate-950/70, backdrop-blur-2xl, capsule shape, border white/5

**SoundCardView (matches `SoundCard.tsx`):**
- Two variants: `portrait` (4:5 aspect, 24pt radius) and `landscape` (320pt height, 32pt radius)
- Full-bleed background image (opacity 80%, → 100% on interaction)
- Bottom gradient: black → black/20 → transparent
- Bottom-left content: category label (10px uppercase primary), title (24pt bold white), duration indicator (thin 48pt primary bar + "Soundscape" label)
- Landscape variant adds: 56×56 circular play button (primary bg, on-primary icon, glow shadow) at bottom-right
- Top-right action buttons (shown on long-press/context menu on iOS): heart, info

**MiniPlayerView (matches `NowPlayingWidget.tsx`):**
- Floating bar positioned above tab bar (bottom: 96pt, horizontal padding: 24pt)
- Glass card: slate-900/70 bg, 16pt radius, backdrop blur, shadow
- Left: 48×48 rounded-lg album art thumbnail
- Center: sound name (14pt bold) + animated EQ bars (3 thin primary rectangles with looping height animation) + "Playing" label (10px uppercase primary)
- Right: pause button + dismiss (X) button
- Tap anywhere (except buttons) → opens NowPlayingView

**Tab Bar (matches `BottomNavBar.tsx`):**
- 5 tabs: Home (house.fill), Discover (magnifyingglass), Mixes (square.stack.fill), Favorites (heart.fill), Settings (gearshape.fill)
- Glass effect: slate-950/70 bg, backdrop-blur, 32pt top corners, shadow, border-top white/5
- Labels: 10px uppercase tracking-widest bold
- Active: primary color + scale 110%. Inactive: on-surface-variant at 60% opacity
- Hidden when NowPlayingView is presented full-screen

**Color Palette (Material Design 3 — Dark Theme — from Section 4.2):**
- Background: `#0C0E12` (near-black)
- Surface-container-low: `#111318` (card bg)
- Surface-container-high: `#1D2025` (elevated card bg)
- Primary: `#7FE6DB` (cyan/turquoise accent)
- Secondary: `#96A5FF` (periwinkle)
- On-background: `#F6F6FC` (primary text)
- On-surface-variant: `#AAABB0` (secondary text)
- On-primary: `#00534D` (text on primary surfaces)

---

# 7. PHASE 2 — MONETIZATION & POLISH (Week 3)

**Goal:** Add the $3.99 premium IAP. Add Settings and AirPlay support. No ads — the app is completely ad-free because ads disrupt the sleep/relaxation experience.

## 7.1 IAP — Unlock Premium Sounds ($3.99)

**Product ID:** `com.zalgo.whitenoisesleepsounds.premium`  
**Type:** Non-consumable  
**Price:** $3.99 (Tier 1)  
**What it unlocks:**
1. Unlocks 12 premium sounds (marked with lock icon)
2. Badge: "Premium" label on user's profile/settings

See [Section 13](#13-payment-integration-storekit-2) for full StoreKit 2 implementation.

## 7.3 Settings Screen

```
Settings
├── Premium
│   ├── Upgrade to Premium ($3.99)
│   └── Restore Purchases
├── Playback
│   ├── Continue playing when app closes (toggle, default: ON)
│   └── Fade duration (0s / 2s / 5s)
├── Appearance
│   └── App icon (default + alternates — Phase 5)
├── About
│   ├── Rate on App Store
│   ├── Share with Friends
│   ├── Privacy Policy
│   ├── Terms of Use
│   └── Version info
└── Feedback
    └── Contact Developer (mailto: link)
```

## 7.4 AirPlay Support

```swift
// AVAudioSession already handles AirPlay routing
// Add an AirPlay picker button using AVRoutePickerView (UIKit wrapper)
// Place it on the Now Playing screen, top-left area
```

---

# 8. PHASE 3 — MIXES & CUSTOMIZATION (Week 4)

**Goal:** Let users combine multiple sounds and save custom mixes.

## 8.1 Mix Engine

Since we built with `AVAudioEngine` from Phase 1, mixing is just activating multiple player nodes:

```swift
// Each mix is 2-5 sounds playing simultaneously
// Each sound has its own AVAudioPlayerNode connected to the main mixer
// Each node has independent volume control
// User adjusts volumes via individual sliders
```

## 8.2 Mix Data Model

```swift
struct SoundMix: Identifiable, Codable {
    let id: UUID
    var name: String                           // "Rainy Campfire"
    var components: [MixComponent]             // 2-5 sounds
    var isFavorite: Bool
    let createdAt: Date
}

struct MixComponent: Identifiable, Codable {
    let id: UUID
    let soundId: String                        // references Sound.id
    var volume: Float                          // 0.0 - 1.0
}
```

## 8.3 Mix Editor UI (matches `MixesPage.tsx`)

**Create Mix Screen:**
- Grid or list of all available sounds (compact, checkable)
- Selected sounds appear as a stack of mini-cards at bottom
- Each mini-card has: sound name + volume slider (horizontal)
- Max 5 sounds per mix
- "Save Mix" button with text field for name
- Preview button to hear the mix before saving

**Mixes List Screen:**
- Similar to Sounds List but shows mix name + component names below
- Tap to play the full mix
- Swipe to delete
- Heart to favorite

**Tab Bar:** Already has 5 tabs from Phase 1 (Home | Discover | Mixes | Favorites | Settings). Mixes tab was placeholder, now fully implemented.

## 8.4 Now Playing Updates for Mixes

When playing a mix:
- Background: Use the background of the "primary" sound (first component or loudest)
- Show mix name instead of single sound name
- Add a small expandable panel showing all component sounds with individual volume sliders
- User can adjust component volumes during playback

---

# 9. PHASE 4 — WIDGETS, TIMERS & SLEEP CLOCK (Week 5)

**Goal:** Add home screen widgets, sleep timer, alarm, and bedside clock mode.

## 9.1 Widgets (WidgetKit)

**Important limitation:** WidgetKit cannot play audio directly. Widgets use deep links or AppIntents to trigger actions in the main app.

### Home Screen Widget (Medium — 2x2)
- Shows: Currently playing sound name + background image
- Tap action: Opens app to Now Playing
- Quick-play buttons for 3 favorite sounds (uses AppIntent)

### Home Screen Widget (Small — 1x1)
- Shows: Play/pause icon + current sound thumbnail
- Tap: Toggles playback via AppIntent

### Lock Screen Widget (Circular)
- Shows: Small waveform icon
- Tap: Opens app to Now Playing

### Lock Screen Widget (Rectangular)
- Shows: Sound name + play/stop icon
- Tap: Opens app

**Implementation approach:**
```swift
// Use AppIntents framework
struct PlaySoundIntent: AppIntent {
    static var title: LocalizedStringResource = "Play Sound"
    @Parameter(title: "Sound") var soundId: String
    
    func perform() async throws -> some IntentResult {
        // Trigger playback in main app via shared UserDefaults (app group)
        // or via background task
    }
}
```

## 9.2 Sleep Timer

**UI:** Sheet/modal accessible from Now Playing screen (moon icon button)

**Options:**
- Preset durations: 15 min, 30 min, 45 min, 1 hour, 2 hours, 4 hours
- Custom: Scroll picker for hours & minutes
- Fade out: Toggle (when ON, volume gradually decreases to 0 over last 30 seconds before stopping)

**Implementation:**
```swift
// Simple Timer that fires at the set duration
// On fire: if fadeOut enabled, animate volume to 0 over 30 seconds, then stop
// If fadeOut disabled, stop immediately
// Show remaining time on Now Playing screen (small countdown label)
```

## 9.3 Alarm

**Simple alarm:** After the sleep timer stops audio, optionally set an alarm to resume playback (or play a specific alarm sound) at a set time.

**Implementation:** Use `UNUserNotificationCenter` to schedule a local notification. When the notification fires and the user taps it, the app opens and resumes playback.

## 9.4 Sleep Clock (Bedside Mode)

**UI:**
- Full-screen pure black background (OLED-friendly — true black saves battery)
- Large digital time in center (monospaced font, dimmed white or amber)
- Date below time (smaller, more dimmed)
- Tap anywhere to briefly show: currently playing sound name, sleep timer countdown
- Double-tap or swipe up to exit sleep clock mode
- Auto-dim: Screen brightness lowers after 5 seconds of no touch
- No ads anywhere in the app (ad-free by design)

**Implementation:**
```swift
// UIApplication.shared.isIdleTimerDisabled = true (prevent auto-lock)
// Use TimelineView for live clock updates
// Override preferredStatusBarStyle to .lightContent
// Set screen brightness with UIScreen.main.brightness
```

---

# 10. PHASE 5 — FULL FEATURE PARITY + PREMIUM (Week 6)

**Goal:** Round out the app with remaining features, premium content, and polish for App Store submission.

## 10.1 Playlist / Queue

- Users can queue sounds to play sequentially
- Drag to reorder
- Auto-advances to next sound when current finishes (for non-looping sounds — but all our sounds loop, so this is mainly for variety)
- Optional: Set each sound to play for X minutes before advancing

## 10.2 Premium Sound Pack

Lock 10+ sounds behind the $3.99 IAP:

**Premium sounds (locked by default):**
1. Tibetan Singing Bowl
2. Wind Chimes (Bamboo)
3. Underwater Bubbles
4. Japanese Garden
5. Northern Lights Ambience (cosmic drone)
6. Cabin in the Rain
7. Midnight Forest
8. Desert Wind
9. Snow Falling (soft crackle)
10. Coffee Shop (busy café)
11. Library Ambience
12. Vinyl Crackle

These sounds have a small lock icon overlay. Tapping shows a purchase prompt.

## 10.3 Sound Categories / Scenes (Portal-inspired)

Instead of a flat alphabetical list, add a "Scenes" view:
- Each scene is a full-width card with a background image
- Scenes: "Rainfall", "Forest", "Ocean & Water", "Urban Night", "Machines & Fans", "Fireside", "Cosmic" (premium)
- Tapping a scene shows all sounds in that category
- This is the Portal-inspired "destinations" concept adapted for a sound app

## 10.4 Onboarding Flow (3 screens)

1. **Welcome:** "Your personal sound sanctuary" — app name, tagline, pretty background
2. **How it works:** "Pick a sound, mix them together, set a sleep timer" — 3 small illustrations
3. **Get started:** "Start free, or unlock everything for $3.99" — CTA buttons

## 10.5 Sleep Log (Basic)

- Track: date, time went to sleep (when sleep timer started or sleep clock activated), sounds used
- Simple list view grouped by week
- Data stored in UserDefaults or SwiftData
- No analytics, no cloud sync — just local tracking

## 10.6 Import Custom Sounds

- "Import Sound" button in Settings or Sounds screen
- Uses `UIDocumentPickerViewController` to import .mp3, .m4a, .wav files
- Imported sounds stored in app's documents directory
- User can name them and assign a category
- Default background: generic waveform image

## 10.7 Siri Shortcuts (App Intents)

```swift
// "Play White Noise" — starts white noise playback
// "Play my Rainy Campfire mix" — plays a specific saved mix
// "Start sleep timer for 30 minutes" — activates timer
// Uses AppIntents framework (same as widgets)
```

## 10.8 Alternate App Icons

Offer 3-4 alternate app icons the user can select in Settings:
1. Default: Moon + waveform on dark gradient
2. Minimal: White waveform on black
3. Nature: Leaf with sound waves on green gradient
4. Ocean: Wave icon on blue gradient

---

# 11. EXTERNAL DESIGN ASSET LIST

Everything you need to create outside of Xcode (in Figma, Sketch, Canva, or similar):

## 11.1 App Icons

| Asset | Size | Notes |
|---|---|---|
| App Icon (default) | 1024x1024px | Moon + waveform, dark purple/blue gradient. Must look good at 60x60 too |
| App Icon (minimal) | 1024x1024px | White waveform on pure black |
| App Icon (nature) | 1024x1024px | Leaf + waves on green gradient |
| App Icon (ocean) | 1024x1024px | Wave icon on deep blue gradient |

Export all at 1024x1024. Xcode auto-generates all required sizes from the single 1024px asset.

## 11.2 Sound Background Images (Now Playing)

Each sound needs a full-screen background. Create in **landscape 2796x1290px** (iPhone 15 Pro Max resolution) — iOS will scale down for smaller devices.

| # | Sound | Background Image Description | Theme Color |
|---|---|---|---|
| 1 | White Noise | Abstract gradient — soft gray waves | #2C2C3A |
| 2 | Pink Noise | Soft pink/magenta abstract waves | #3A2040 |
| 3 | Brown Noise | Warm brown abstract texture, wood grain feel | #2E1F14 |
| 4 | Blue Noise | Cool blue static/digital pattern | #142040 |
| 5 | Heavy Rain | Dark window with rain streaks, city lights blurred | #1A2030 |
| 6 | Light Rain | Foggy forest with gentle drizzle | #1E2A1E |
| 7 | Rain on Tent | Inside of a tent, rain on fabric, warm lantern light | #2A2015 |
| 8 | Rain on Window | Close-up window with rain drops, warm interior | #25201A |
| 9 | Thunderstorm | Dark dramatic sky with lightning in distance | #15182A |
| 10 | Ocean Waves | Beach at dusk, deep blue tones, white foam | #0D1A2E |
| 11 | Beach Waves | Tropical beach, sunset, warm golds and oranges | #2E2010 |
| 12 | River / Stream | Forest stream over mossy rocks, dappled sunlight | #152515 |
| 13 | Waterfall | Tall waterfall in tropical setting, mist | #1A2A2A |
| 14 | Fountain | Stone fountain in garden courtyard | #1A1A25 |
| 15 | Birds Singing | Sunrise through trees, warm golden light | #2A2510 |
| 16 | Crickets | Night meadow, moonlight, fireflies | #101A15 |
| 17 | Wind | Open plains/hilltop, dramatic sky, grass blowing | #1A2020 |
| 18 | Forest | Deep green forest, tall trees, filtered light | #0A1A0A |
| 19 | Campfire | Close-up campfire with glowing embers | #2E1A0A |
| 20 | Fireplace | Cozy interior, stone fireplace, warm amber light | #2A1A0E |
| 21 | Fan / Air Conditioner | Clean modern bedroom, soft blue-white tone | #1A1E2A |
| 22 | Clothes Dryer | Cozy laundry room, warm tones | #25201A |
| 23 | Airplane Interior | Window seat view, clouds, blue sky | #1A2540 |
| 24 | Train | Night train window, passing lights, rain | #15152A |
| 25 | City Streets | Urban night, neon reflections on wet pavement | #1A1025 |
| 26 | Café / Coffee Shop* | Warm coffee shop interior, bokeh lights | #251A10 |
| 27 | Cat Purring | Sleeping cat on soft blanket, warm tones | #2A2015 |
| 28 | Wind Chimes* | Porch with bamboo chimes, sunset garden | #2A2510 |
| 29 | Singing Bowl* | Tibetan temple interior, candlelight | #1A1520 |
| 30 | Underwater* | Deep blue underwater scene, light rays from surface | #0A1530 |

*Items marked with * are premium sounds (locked behind $3.99 IAP)

**Tips for creating backgrounds:**
- Use Unsplash, Pexels, or Midjourney/AI generation for base images
- Apply a dark overlay/vignette so white text is always readable
- Keep the visual center-of-interest in the upper half (controls occupy bottom)
- All images should feel moody, cinematic, slightly desaturated — the Portal aesthetic
- Export as JPEG at ~80% quality to keep app size manageable (~200KB each)

## 11.3 Sound Thumbnails (List View)

For the Sounds List rows, each sound needs a small thumbnail.

| Asset | Size | Format |
|---|---|---|
| Sound thumbnail (per sound) | 120x120px | PNG, rounded corners (apply in code) |

**Approach:** Crop/zoom the background image to a 1:1 square and resize to 120x120. This keeps the visual language consistent between the list and Now Playing screens.

Total: 30 thumbnails (one per sound).

## 11.4 Scene Cards (Phase 5)

For the Scenes/Categories view, each category needs a wide card image.

| Asset | Size | Format |
|---|---|---|
| Scene card | 1200x600px | JPEG, with text overlay zone |

Categories to create scene cards for: Noise (7 variants), Rain, Nature, Urban, Machine, Fire, Water, Premium/Cosmic

Total: 8 scene cards.

## 11.5 Widget Assets

| Asset | Size | Notes |
|---|---|---|
| Widget background (medium) | 640x300px | Dark, blurred ambient image |
| Widget play icon | 48x48px | SF Symbol is fine, or custom |
| Widget sound thumbnails | 80x80px | Reuse sound thumbnails, cropped |

## 11.6 Onboarding Illustrations

| Screen | Asset | Size |
|---|---|---|
| Welcome | App logo + tagline over background | 1290x800px |
| How it works | 3 small icons (pick sound / mix / timer) | 200x200px each |
| Get started | Background + CTA overlay | 1290x800px |

## 11.7 App Store Screenshots

**Required:** 6.7" (iPhone 15 Pro Max) — 1290x2796px, minimum 3 screenshots (aim for 5-6)

| # | Screenshot Content | Caption |
|---|---|---|
| 1 | Now Playing — full-screen immersive (rain theme) | "Fall asleep to beautiful sounds" |
| 2 | Sounds list showing variety | "40+ free sounds — rain, nature, noise & more" |
| 3 | Mix editor with multiple sounds | "Create your perfect sound mix" |
| 4 | Sleep timer + sleep clock | "Set it and forget it — sleep timer & bedside clock" |
| 5 | Widget on home screen | "One tap to relax — home screen widgets" |
| 6 | Settings showing $3.99 premium | "No subscriptions — just $3.99 for everything" |

**Also needed:**
- 6.1" (iPhone SE) — 1170x2532px (can scale from 6.7")
- 12.9" iPad Pro — 2048x2732px (if supporting iPad)

## 11.8 App Store Promotional Art

| Asset | Size | Purpose |
|---|---|---|
| App Preview poster | 1290x2796px | If you make a video preview |
| Feature graphic | 1024x500px | For promotional features |

## 11.9 Misc

| Asset | Purpose |
|---|---|
| Privacy Policy page | Host on a simple webpage (GitHub Pages works) |
| Terms of Use page | Same hosting |
| Support email | Use your existing email |

---

# 12. SOUND ASSET LIST

## 12.1 Where to Get Sounds

**Free, royalty-free sound sources:**
1. **Freesound.org** — Largest free sound library (Creative Commons). Search for "rain loop", "white noise", "campfire ambience", etc.
2. **Pixabay Audio** — Free for commercial use, no attribution required
3. **Zapsplat.com** — Free tier with attribution, paid tier without
4. **BBC Sound Effects** — Some free for non-commercial (check license)
5. **Record yourself** — Fan, dryer, air conditioner are easy to record with iPhone

**For procedurally generated sounds (no files needed):**
- White Noise, Pink Noise, Brown Noise, Blue Noise — generate in code using `AVAudioSourceNode`

## 12.2 Sound File Specifications

| Property | Value |
|---|---|
| Format | AAC (.m4a) — best compression-to-quality ratio on iOS |
| Sample Rate | 44100 Hz |
| Channels | Stereo (2ch) preferred, Mono acceptable |
| Bit Rate | 128 kbps (good quality, small size) |
| Loop Length | 30-60 seconds (will loop seamlessly) |
| Seamless Loop | CRITICAL — the end must crossfade into the beginning with no audible click |

**Making seamless loops:**
1. Open in Audacity (free)
2. Select last 2 seconds and first 2 seconds
3. Apply crossfade
4. Test loop playback
5. Export as .m4a (AAC)

## 12.3 Full Sound Inventory

### Free Sounds (available from launch)

| # | Sound Name | Category | Source Type | Est. File Size |
|---|---|---|---|---|
| 1 | White Noise | Noise | Procedural | 0 KB |
| 2 | Pink Noise | Noise | Procedural | 0 KB |
| 3 | Brown Noise | Noise | Procedural | 0 KB |
| 4 | Blue Noise | Noise | Procedural | 0 KB |
| 5 | Heavy Rain | Rain | File | ~500 KB |
| 6 | Light Rain | Rain | File | ~500 KB |
| 7 | Rain on Tent | Rain | File | ~500 KB |
| 8 | Rain on Window | Rain | File | ~500 KB |
| 9 | Thunderstorm | Rain | File | ~600 KB |
| 10 | Ocean Waves | Nature | File | ~500 KB |
| 11 | Beach Waves | Nature | File | ~500 KB |
| 12 | River / Stream | Water | File | ~500 KB |
| 13 | Waterfall | Water | File | ~500 KB |
| 14 | Fountain | Water | File | ~400 KB |
| 15 | Birds Singing | Nature | File | ~500 KB |
| 16 | Crickets | Nature | File | ~400 KB |
| 17 | Wind | Nature | File | ~400 KB |
| 18 | Forest Ambience | Nature | File | ~500 KB |
| 19 | Campfire | Fire | File | ~400 KB |
| 20 | Fireplace | Fire | File | ~400 KB |
| 21 | Fan | Machine | File | ~400 KB |
| 22 | Air Conditioner | Machine | File | ~400 KB |
| 23 | Clothes Dryer | Machine | File | ~400 KB |
| 24 | Airplane Interior | Machine | File | ~500 KB |
| 25 | Train | Urban | File | ~500 KB |
| 26 | City Streets | Urban | File | ~500 KB |
| 27 | Cat Purring | Nature | File | ~400 KB |

**Total free sounds:** 27 (4 procedural + 23 file-based)  
**Estimated bundle size for sounds:** ~11 MB

### Premium Sounds (unlocked with $3.99 IAP)

| # | Sound Name | Category | Source Type | Est. File Size |
|---|---|---|---|---|
| 28 | Wind Chimes (Bamboo) | Nature | File | ~400 KB |
| 29 | Tibetan Singing Bowl | Premium | File | ~500 KB |
| 30 | Underwater Bubbles | Water | File | ~400 KB |
| 31 | Japanese Garden | Premium | File | ~500 KB |
| 32 | Northern Lights Drone | Premium | File | ~500 KB |
| 33 | Cabin in the Rain | Rain | File | ~500 KB |
| 34 | Midnight Forest | Nature | File | ~500 KB |
| 35 | Desert Wind | Nature | File | ~400 KB |
| 36 | Snow Falling | Nature | File | ~400 KB |
| 37 | Coffee Shop | Urban | File | ~500 KB |
| 38 | Library Ambience | Urban | File | ~400 KB |
| 39 | Vinyl Crackle | Premium | File | ~300 KB |

**Total premium sounds:** 12  
**Estimated bundle size for premium:** ~5.3 MB  
**Total app sound size:** ~16.3 MB

**Total estimated app size with images:** ~25-30 MB (well under the 200MB cellular download limit)

---

# 13. PAYMENT INTEGRATION (STOREKIT 2)

## 13.1 App Store Connect Setup

1. Go to App Store Connect → Your App → In-App Purchases
2. Create new IAP:
   - **Type:** Non-Consumable
   - **Reference Name:** Premium Sounds
   - **Product ID:** `com.zalgo.whitenoisesleepsounds.premium`
   - **Price:** Tier 1 ($3.99)
   - **Display Name:** "Premium Sounds"
   - **Description:** "Unlock 12 exclusive premium sounds including Coffee Shop, Singing Bowl, Underwater, and more."

## 13.2 StoreKit 2 Implementation

```swift
// StoreManager.swift — handles all IAP logic

import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var product: Product?
    
    private let productId = "com.zalgo.whitenoisesleepsounds.premium"
    
    init() {
        // Check existing entitlements on launch
        Task { await checkEntitlements() }
        // Listen for transaction updates (e.g., Ask to Buy approvals)
        listenForTransactions()
    }
    
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productId])
            self.product = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase() async throws {
        guard let product else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            self.isPremium = true
        case .userCancelled:
            break
        case .pending:
            break // Ask to Buy — will resolve via listener
        @unknown default:
            break
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }
    
    private func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == productId {
                self.isPremium = true
                return
            }
        }
        self.isPremium = false
    }
    
    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await MainActor.run {
                        self.isPremium = true
                    }
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified: throw StoreError.verificationFailed
        }
    }
    
    enum StoreError: Error {
        case verificationFailed
    }
}
```

## 13.3 Purchase UI

**Premium upgrade prompt (shown when tapping a locked sound or "Upgrade" in Settings):**

```
┌──────────────────────────────────┐
│         ⭐ Go Premium            │
│                                  │
│   Unlock 12 exclusive sounds     │
│   Premium sound categories       │
│   Support indie development      │
│                                  │
│   ┌──────────────────────────┐   │
│   │   Just $3.99 — One Time  │   │
│   └──────────────────────────┘   │
│                                  │
│   Restore Purchases              │
│                                  │
│   No subscriptions. Ever.        │
└──────────────────────────────────┘
```

This should be a SwiftUI sheet presented modally. Keep it simple and friendly. The "No subscriptions. Ever." line is a key differentiator from competitors.

## 13.4 Testing

- Use StoreKit Configuration File in Xcode for local testing
- Create a `StoreKitConfig.storekit` file with your product
- Test: purchase flow, restore, pending (Ask to Buy), cancellation
- In sandbox, purchases are free and reset-able

---

# 14. MONETIZATION STRATEGY — AD-FREE FREEMIUM

**Decision:** No ads in the app. Ads disrupt the sleep/relaxation experience — users are trying to fall asleep, and banner ads or tracking prompts undermine that. Competitor reviews consistently cite ads as the #1 frustration.

**Revenue model:** Freemium with a single $3.99 one-time IAP to unlock 12 premium sounds.

**Why no ads:**
- White noise apps are used at the most vulnerable moment (falling asleep) — ads break immersion
- Ad revenue for niche utility apps is low (~$0.005-$0.02 per user/day)
- A clean, ad-free free tier earns better reviews and word-of-mouth, driving more downloads
- Even a 5-10% conversion rate on the $3.99 IAP outperforms banner ad revenue significantly
- No need for AdMob SDK, ATT prompts, or IDFA tracking — simpler app, faster review

**Competitive positioning:** Most competitors (White Noise Lite, Atmosphere) use ads in their free tier. Our ad-free free tier is a clear differentiator that we can highlight in App Store metadata and marketing.

---

# 15. APP STORE PUBLISHING GUIDE

## 15.1 Pre-Submission Checklist

- [ ] App runs without crashes on iPhone and iPad (if universal)
- [ ] All sounds play correctly, loop seamlessly
- [ ] Background audio works (app continues playing when minimized)
- [ ] IAP purchase and restore work in sandbox
- [ ] App is completely ad-free (no ad SDKs or tracking)
- [ ] Privacy Policy URL is live (host on GitHub Pages or your website)
- [ ] App icon follows Apple Human Interface Guidelines (no alpha/transparency)
- [ ] All screenshots are the correct resolution
- [ ] Sleep timer works correctly (stops audio, optional fade)
- [ ] No copyrighted sounds or images

## 15.2 App Store Connect Configuration

**App Information:**
- Name: `White Noise — Sleep Sounds`
- Subtitle: `Rain, Fan & Nature Sound Mixer`
- Category: Primary — Health & Fitness, Secondary — Lifestyle
- Content Rights: "This app does not contain, show, or access third-party content"
- Age Rating: 4+ (no objectionable content)

**Pricing:**
- Price: Free
- In-App Purchases: Yes (list your $3.99 IAP)
- Territories: All (worldwide)

**Privacy:**
- Privacy Policy URL: `https://yourusername.github.io/whitenoise-privacy`
- Data Collection: None (no ads, no tracking, no analytics)
- App Tracking Transparency: Not required (no ad SDK or IDFA usage)

**Keywords (100 chars):**
```
calm,focus,baby,study,deep,brown,pink,ocean,background,machine,meditation,relax,noises,ambience,aid
```

## 15.3 App Review Notes

Write this in the "Notes for Reviewer" field:

> "This app provides white noise and nature sounds for sleep, relaxation, and focus. The free version includes 27 sounds with no ads. The $3.99 in-app purchase unlocks 12 additional premium sounds. Test account not needed — all features work without login."

## 15.4 Common Rejection Reasons to Avoid

1. **Guideline 2.1 — App Completeness:** Make sure all features work. No placeholder screens, no "coming soon" labels.
2. **Guideline 3.1.1 — IAP:** All digital content must use IAP, not external payment. Our $3.99 IAP is correctly using StoreKit 2.
3. **Guideline 5.1.2 — Data Use:** No ad SDK means minimal data collection. Declare "Data Not Collected" in App Privacy if no analytics are used.
4. **Guideline 4.0 — Design:** App must not be a thin wrapper or low-quality clone. Our modern UI, mix feature, and Portal-inspired visuals ensure this isn't an issue.
5. **Metadata Rejection:** Don't use competitor names in metadata. Our keywords are all generic terms.

## 15.5 Privacy Advantage — No ATT Required

Since the app is completely ad-free with no tracking SDKs, there is no need for an App Tracking Transparency (ATT) prompt. This means:
- No annoying "Allow tracking?" popup on first launch
- Cleaner first-run experience
- "Data Not Collected" label in App Store privacy section — a trust signal for users
- Simpler App Review process with fewer privacy-related rejection risks

## 15.6 Post-Launch

1. **Monitor crashes** via Xcode Organizer
2. **Respond to reviews** — even negative ones (shows active development)
3. **ASO iteration** — check keyword rankings weekly in Astro, swap underperforming keywords
4. **Submit updates** every 2-3 weeks with new sounds or fixes (the algorithm favors active apps)

---

# 16. VIBE CODING PROMPTS BY PHASE

> **COUPLING NOTE:** These prompts are derived from the design reference in `white-noise-designs-google-aistudios/`. When the design reference files change, regenerate these prompts to match. Each prompt explicitly references design files so the AI coding assistant produces views that match the design reference pixel-for-pixel.

These are ready-to-paste prompts for your AI coding assistant in Xcode. Each prompt assumes the previous phase is complete.

---

## PHASE 1 PROMPT — MVP Core Playback

```
Build an iOS app called "White Noise — Sleep Sounds" using SwiftUI targeting iOS 17+.

IMPORTANT — DESIGN REFERENCE:
This app has a React design reference in `white-noise-designs-google-aistudios/`. You MUST match the visual design from those files exactly. Key files to reference:
- src/index.css → color tokens and typography
- src/App.tsx → navigation structure (5 tabs + full-screen player)
- src/pages/HomePage.tsx → home screen layout
- src/pages/DiscoverPage.tsx → search + category filter + grid
- src/pages/PlayerPage.tsx → full-screen immersive player (THE HERO SCREEN)
- src/components/SoundCard.tsx → reusable card component (portrait/landscape variants)
- src/components/NowPlayingWidget.tsx → floating mini-player bar
- src/components/BottomNavBar.tsx → glass-effect bottom tab bar
- src/components/TopAppBar.tsx → glass-effect top app bar
- src/constants.ts → sound data model
- src/types.ts → TypeScript interfaces (translate to Swift structs)

PROJECT STRUCTURE:
Create a clean MVVM architecture with these groups: App, Theme, Models, Views, ViewModels, Audio, Resources, Utilities.

THEME (from design reference src/index.css — MANDATORY):
Create a Theme.swift file with Color extensions using these EXACT hex values:
- Color.primary = #7FE6DB (cyan/turquoise — ALL interactive elements, active states, accents)
- Color.secondary = #96A5FF (periwinkle — secondary accents, category labels on player)
- Color.tertiary = #CCF9FF (light cyan highlights)
- Color.background = #0C0E12 (near-black app background)
- Color.surfaceContainerLow = #111318 (card backgrounds)
- Color.surfaceContainer = #171A1F (mid-elevation surfaces)
- Color.surfaceContainerHigh = #1D2025 (elevated cards, search bar, settings)
- Color.onBackground = #F6F6FC (primary text)
- Color.onSurface = #F6F6FC (primary text on surfaces)
- Color.onSurfaceVariant = #AAABB0 (secondary/muted text)
- Color.onPrimary = #00534D (text on primary-colored buttons)
- Color.primaryContainer = #47B0A7 (gradient endpoint for play button)
- Color.outline = #74757A (placeholder text, borders)
Typography helpers:
- .headline style: .system(size:weight:.heavy, design:.rounded) with negative tracking (matches Manrope ExtraBold)
- .categoryLabel style: 10pt, bold, rounded, uppercase, tracking +2 (matches the design's uppercase tracking-widest labels)

DATA MODEL (matches src/types.ts):
- Sound struct with: id (String), title (String), category (String), description (String), imageName (String), duration (String?), tags ([String]), fileName (String), isPremium (Bool), isGenerated (Bool)
- SoundCategory enum with cases: noise, rain, nature, urban, machine, fire, water
- FavoritesManager class using @Observable that persists favorite sound IDs to UserDefaults
- Create a static SoundLibrary with all 27 free sounds hardcoded (4 noise types as generated, 23 file-based)

AUDIO ENGINE:
- Create an AudioEngine class using AVAudioEngine (NOT AVAudioPlayer)
- Set up AVAudioSession with .playback category and .mixWithOthers option
- Enable background audio (I'll add the capability in Xcode manually)
- Support file-based playback using AVAudioPlayerNode connected to the main mixer
- Support procedural noise generation using AVAudioSourceNode for white, pink, brown, and blue noise
- White noise: random Float samples between -1.0 and 1.0
- Pink noise: apply a Voss-McCartney algorithm or simple -3dB/octave filtering
- Brown noise: integrate white noise with cumulative sum and decay factor
- Blue noise: differentiate white noise (high-pass emphasis)
- Implement play, pause, stop, next, previous, setVolume, and seamless looping
- Use AVAudioPlayerNode.scheduleBuffer with .loops option for seamless looping

AUDIO VIEW MODEL:
- AudioPlayerViewModel as @Observable class
- Properties: currentSound (Sound?), isPlaying (Bool), volume (Float 0-1), currentIndex (Int)
- Methods: play(sound:), pause(), resume(), stop(), next(), previous(), setVolume()
- Keep a reference to the full sound list for next/previous navigation

VIEWS (match design reference files exactly):

1. ContentView (matches src/App.tsx):
   - TabView with 5 tabs (matches BottomNavBar.tsx):
     Tab 1: Home (house.fill) → HomeView
     Tab 2: Discover (magnifyingglass) → DiscoverView
     Tab 3: Mixes (square.stack.fill) → placeholder for now
     Tab 4: Favorites (heart.fill) → FavoritesView
     Tab 5: Settings (gearshape.fill) → placeholder for now
   - Tab bar styling (matches BottomNavBar.tsx): glass morphism background (ultraThinMaterial + black opacity 0.7), 32pt top corner radius, border-top white/5, labels are 10px uppercase tracking-widest bold, active tab = primary color + scale 1.1, inactive = onSurfaceVariant at 60% opacity
   - MiniPlayerView overlay floating above tab bar (only visible when sound is playing)
   - Full-screen NowPlayingView presented as a sheet/fullScreenCover when MiniPlayerView is tapped
   - Tab bar + MiniPlayer + TopAppBar hidden when NowPlayingView is active

2. HomeView (matches src/pages/HomePage.tsx):
   - Scrollable, padded content on background color
   - Hero section at top:
     - "Daily Refresh" pill badge: primary.opacity(0.1) background, primary text, 10px uppercase tracking-widest font, capsule shape
     - Large title: "Morning" on line 1, "Sanctuary." on line 2 in primary color. Font: 48pt heavy rounded, tracking -1
     - Subtitle paragraph: onSurfaceVariant color, 18pt body font
   - Bento grid section:
     - Use LazyVGrid with flexible columns
     - Row 1: 1 landscape SoundCard (spans 2 cols) + 1 portrait SoundCard
     - Row 2: 2 portrait SoundCards
     - Row 3: 1 full-width horizontal card (32pt radius, 256pt height, background image, gradient-to-trailing overlay, left-aligned title + description + "Play Journey" glass button)
   - Staggered entrance animations: each card appears with opacity 0→1 and y offset, delayed by 0.1s per card

3. DiscoverView (matches src/pages/DiscoverPage.tsx):
   - Title: "Discover Peace" (48pt heavy rounded, tracking tight)
   - Search bar: surfaceContainerHigh bg, 16pt radius, magnifying glass icon left, placeholder text in outline color
   - Horizontal scrolling category pills (ScrollView .horizontal): Capsule shapes, active = primary bg + onPrimary text, inactive = surfaceContainerHigh bg + onSurface text
   - 3-column LazyVGrid of portrait SoundCards
   - Staggered entrance animations

4. SoundCardView (matches src/components/SoundCard.tsx):
   - Two variants via enum: .portrait (4:5 aspect ratio, 24pt corner radius) and .landscape (320pt height, 32pt corner radius)
   - ZStack: background image (fills frame, opacity 0.8) → gradient overlay (black bottom→transparent top) → content overlay
   - Content at bottom-left: category label (10px uppercase tracking-widest, primary color), title (24pt bold white), duration bar (thin 48pt wide rectangle in primary + "Soundscape" label in onSurfaceVariant)
   - Landscape variant: adds 56×56 circular play button at bottom-right (primary bg, onPrimary icon color, glow shadow: primary at 30% opacity, radius 10)
   - Tap animation: scale to 0.98 on press, 1.0 on release
   - Context menu: heart/favorite, info

5. NowPlayingView (matches src/pages/PlayerPage.tsx — THE HERO SCREEN):
   - Full-screen ZStack ignoring safe areas
   - Background layer: full-bleed image of current sound (opacity 0.6, scaleEffect 1.05, blur radius 2)
   - Gradient overlay: LinearGradient bottom→top (background solid → background.opacity(0.4) → clear)
   - Header (top, in safe area): dismiss button (chevron.down, 32pt) left, app logo center (AudioLines SF Symbol + "White Noise" text in primary, bold rounded), spacer right
   - Main content pinned to bottom of screen, max width 500pt:
     - Category label: 10px uppercase tracking-widest, secondary color
     - Title: 40pt heavy rounded, onBackground color
     - Subtitle: body font, onSurfaceVariant
     - Heart button: 48×48 circle, onBackground.opacity(0.1) bg + ultraThinMaterial, heart.fill icon in primary
   - Progress section:
     - Track: 6pt height rounded bar, onBackground.opacity(0.2) fill
     - Fill: gradient (primary→secondary) with shadow (primary at 50%, radius 6)
     - Time labels: 10px uppercase tracking-widest, onSurfaceVariant
   - Transport controls HStack:
     - Shuffle (24pt, onBackground.opacity(0.6))
     - Skip back (32pt, onBackground, fill)
     - PLAY/PAUSE (80×80 circle, gradient primary→primaryContainer, onPrimary icon 40pt, shadow: primary-ish color at 40%, radius 20, y: 6)
     - Skip forward (32pt, onBackground, fill)
     - Repeat (24pt, onBackground.opacity(0.6))
   - Volume: Volume2 icon (onSurfaceVariant) + thin custom slider bar (onBackground.opacity(0.1) track, onBackground.opacity(0.4) fill)
   - Floating action bar (fixed near bottom): HStack inside Capsule — 3 vertical stacks (icon + label):
     - "Audio" (AudioLines icon, primary when active)
     - "Timer" (timer icon, onSurfaceVariant.opacity(0.6))
     - "Mixer" (wind icon, onSurfaceVariant.opacity(0.6))
     - Background: black.opacity(0.7) + ultraThinMaterial, capsule, border white.opacity(0.05), shadow

6. MiniPlayerView (matches src/components/NowPlayingWidget.tsx):
   - Floating above tab bar (padding bottom ~96pt from screen bottom, horizontal padding 24pt)
   - Glass card: black.opacity(0.7) bg + ultraThinMaterial, 16pt radius, shadow
   - HStack: 48×48 rounded-lg album art → VStack (sound name 14pt bold, HStack of 3 animated EQ bars in primary + "Playing" 10px uppercase) → pause button + X dismiss button
   - Tap (except buttons) opens NowPlayingView fullScreenCover
   - Enter animation: slide up from bottom with opacity

7. FavoritesView (matches src/pages/FavoritesPage.tsx):
   - Title: "Your Favorites" (40pt heavy rounded, tracking tight), centered
   - Subtitle: onSurfaceVariant, centered, max width
   - When populated: grid of portrait SoundCards
   - Empty state: centered text "You haven't added any sounds to your favorites yet. Start exploring to find your peace."

SOUNDS:
- For now, create placeholder sound entries in SoundLibrary
- I will add the actual .m4a files to Resources/Sounds/ later
- The procedural noise sounds should work immediately with no files needed
- If a sound file is missing, the AudioEngine should gracefully handle it (don't crash)

Make sure the app compiles, runs, and I can:
1. See the Home screen with hero section and bento grid of sound cards
2. Browse the Discover screen with search and category filters
3. Tap a sound card to play it and see the MiniPlayer appear
4. Tap the MiniPlayer to open the full-screen NowPlayingView
5. Use transport controls (play/pause/skip) on the NowPlayingView
6. Favorite sounds and see them in the Favorites tab
7. Audio continues when app goes to background
8. The entire app uses the cyan/turquoise (#7FE6DB) color scheme from the design reference, NOT purple
9. Glass morphism effects on tab bar, mini player, and player action bar
```

---

## PHASE 2 PROMPT — IAP & Settings

```
I have a working White Noise — Sleep Sounds app with SwiftUI matching the design reference (cyan/turquoise theme, 5-tab navigation, HomeView with bento grid, DiscoverView with search + category pills, full-screen NowPlayingView, MiniPlayerView, SoundCardView, FavoritesView). Now add monetization (IAP only, NO ads) and the Settings screen.

DESIGN REFERENCE FOR THIS PHASE:
- src/pages/SettingsPage.tsx → SettingsView layout (stacked rounded cards on dark bg)
- Use the existing color token system from Theme.swift (primary #7FE6DB, etc.)

IMPORTANT — NO ADS:
- This app is completely ad-free by design. Do NOT add any ad SDK, banner ads, or tracking.
- No AdMob, no ATT prompt, no NSUserTrackingUsageDescription.
- Revenue comes solely from the $3.99 premium IAP.
- Reason: ads disrupt the sleep/relaxation experience — our ad-free approach is a key differentiator.

STOREKIT 2 IN-APP PURCHASE:
- Create StoreManager as @Observable class
- Product ID: "com.zalgo.whitenoisesleepsounds.premium"
- Type: Non-consumable ($3.99)
- On init: check Transaction.currentEntitlements for existing purchase, listen to Transaction.updates
- Methods: loadProduct(), purchase(), restorePurchases()
- Published property: isPremium (Bool)
- Create a StoreKit Configuration file for local testing with the product defined
- Inject StoreManager into the environment at the App level

PREMIUM PURCHASE SHEET:
- Create PremiumUpgradeView as a sheet/modal
- Design: dark background, centered content
- Title: "Go Premium" with a star icon
- Three benefit lines: "Unlock 12 exclusive sounds", "Premium sound categories", "Support indie development"
- Large CTA button: "Just $3.99 — One Time" in accent color
- Below: "Restore Purchases" as a text button
- Bottom text: "No subscriptions. Ever." in muted color
- Show this sheet when: user taps a premium/locked sound, or taps "Upgrade" in settings

PREMIUM SOUND GATING:
- In DiscoverView, premium sounds (isPremium == true) show a lock icon overlay on SoundCardView
- Tapping a premium sound when NOT premium presents the PremiumUpgradeView sheet
- After purchase, lock icons disappear and sounds become playable

SETTINGS SCREEN (matches src/pages/SettingsPage.tsx):
- The Settings tab (5th tab, gearshape.fill) was already added in Phase 1 as a placeholder. Now implement SettingsView.
- Title: "Settings" (40pt heavy rounded, tracking tight)
- Layout: stacked cards, each with surfaceContainerHigh background, 16pt radius, border white.opacity(0.05), padding 24pt
- Card 1 — Premium: title "Premium" (bold, 18pt), "Upgrade to Premium" row (shows price, or "Active ✓" in primary if already premium), "Restore Purchases" row
- Card 2 — Playback: title "Playback", "Fade Duration" picker (0s, 2s, 5s) stored in UserDefaults
- Card 3 — About: title "About", "Rate on App Store" (link), "Share with Friends" (ShareLink), "Privacy Policy" (link), app version in onSurfaceVariant
- Store settings in UserDefaults via a Settings @Observable class
- All text uses the design token colors (onSurface for titles, onSurfaceVariant for descriptions)

AIRPLAY:
- Add an AVRoutePickerView wrapped in UIViewRepresentable
- Place it on NowPlayingView top-left area (small icon)
- Style it to match the dark theme (tintColor white)

Make sure:
1. NO ads anywhere in the app — completely ad-free
2. Tapping a locked sound shows the purchase sheet styled with the design token colors
3. After purchasing, locked sounds unlock
4. Restore purchases works
5. Settings screen matches SettingsPage.tsx layout (stacked rounded cards)
6. AirPlay picker appears on NowPlayingView
7. All new UI uses the cyan/turquoise (#7FE6DB) color scheme, glass morphism, and rounded card patterns from Phase 1
```

---

## PHASE 3 PROMPT — Sound Mixing

```
My White Noise — Sleep Sounds app now has the full design-reference UI (HomeView, DiscoverView, NowPlayingView with glass morphism, MiniPlayerView, SoundCardView, SettingsView, IAP). The app is completely ad-free. Now add sound mixing — the Mixes tab (Tab 3) was a placeholder; now implement it fully.

DESIGN REFERENCE FOR THIS PHASE:
- src/pages/MixesPage.tsx → MixesView layout ("Create New Mix" hero card + saved mix grid + "Curated for You" section)
- src/components/MixCard.tsx → MixCardView (split-image grid, overlay play button, edit button)
- src/types.ts → Mix interface (id, title, description, imageUrls, sounds)
- Use existing Theme.swift color tokens throughout

MIX DATA MODEL (matches src/types.ts Mix interface):
- SoundMix struct: id (UUID), name (String), description (String), components ([MixComponent]), isFavorite (Bool), createdAt (Date)
- MixComponent struct: id (UUID), soundId (String, references Sound.id), volume (Float, 0.0-1.0)
- MixesManager @Observable class that persists saved mixes to UserDefaults (JSON encoded)
- Methods: saveMix(), deleteMix(), toggleFavorite(), loadMixes()

AUDIO ENGINE UPDATES:
- AudioEngine already uses AVAudioEngine with a mixer node
- Add support for multiple simultaneous AVAudioPlayerNode instances (up to 5)
- Each node connects to the main mixer with independent volume
- For procedural noise: can have multiple AVAudioSourceNode instances
- New methods: playMix(components:), updateComponentVolume(soundId:, volume:), stopAllSounds()
- When playing a mix, all component sounds loop simultaneously
- Crossfade between states: fade out old sound over 0.5s

AUDIO VIEW MODEL UPDATES:
- Add: currentMix (SoundMix?), isMixPlaying (Bool), activeComponents ([MixComponent])
- When playing a mix, currentSound should be nil (mutually exclusive)
- Method: playMix(mix:), adjustComponentVolume(soundId:, volume:)

MIXES VIEW (matches src/pages/MixesPage.tsx):
- Title: "Mixes" (40pt heavy rounded, tracking tight)
- Subtitle: "Your personal soundscapes, crafted for deep focus and tranquility." in onSurfaceVariant
- "Create New Mix" hero card (matches MixesPage.tsx):
  - Full-width, 192pt height, 16pt radius, overflow hidden
  - Background: gradient overlay (primaryContainer.opacity(0.4) → secondaryContainer.opacity(0.2)) over a blurred background image
  - Center content: 64x64 circle (primary bg, plus icon, glow shadow primary at 40%) + "Create New Mix" label (20pt bold rounded)
  - Tap animation: scale 0.98 on press
- Saved mixes grid: 2-column LazyVGrid of MixCardViews
- "Curated for You" section below:
  - Title: "Curated for You" (24pt bold rounded)
  - Asymmetric grid: 1 large card (spanning full width, 400pt) + 2 stacked smaller cards
  - Each card: background image, dark overlay, title + description at bottom

MIX CARD VIEW (matches src/components/MixCard.tsx):
- Aspect ratio 16:9, 16pt radius, surfaceContainerHigh bg
- Image area: 2-column grid of component sound images (2px gap between them)
- Overlay on tap: dark overlay + 56x56 circular play button (primary.opacity(0.9) bg, backdrop blur, onPrimary icon)
- Edit button: top-right, 40x40 circle (black.opacity(0.4) bg, backdrop blur, pencil icon)
- Below image: title (18pt bold onSurface), description (14pt onSurfaceVariant)
- Active badge: "Active" pill (10px uppercase tracking-widest, primary text, primary.opacity(0.1) bg, capsule)

CREATE MIX VIEW:
- Sheet presented from the "Create New Mix" card
- Grid of all sounds (compact SoundCardViews), each with checkmark overlay when selected
- Selected sounds in bottom panel: sound name + horizontal volume slider + remove (X) button
- Max 5 sounds per mix
- "Preview" button (outline style, primary border) and "Save" button (primary bg, onPrimary text)
- Save prompts for mix name via text field

NOW PLAYING UPDATES FOR MIXES:
- When a mix is playing:
  - Background image: first component's background image (blurred per existing PlayerPage style)
  - Title: mix name, Subtitle: component names joined with " + "
  - "Mixer" button in floating action bar becomes active (primary color)
  - Tapping "Mixer" reveals bottom sheet with per-component volume sliders
  - Transport controls: play/pause for entire mix, next/previous cycle through saved mixes

Make sure:
1. I can create a mix of 2-5 sounds from the "Create New Mix" card
2. Each sound in the mix has independent volume
3. Mixes are saved and appear with MixCardView layout
4. "Curated for You" editorial section appears below saved mixes
5. Playing a mix updates NowPlayingView and MiniPlayerView
6. Mixer button in floating action bar opens component volume controls
7. Single sound playback still works as before
8. All new UI follows the design reference color tokens and glass morphism patterns
```

---

## PHASE 4 PROMPT — Widgets, Timers & Sleep Clock

```
My White Noise — Sleep Sounds app has the full design-reference UI (HomeView bento grid, DiscoverView with search/filters, NowPlayingView with glass morphism transport + floating action bar, MiniPlayerView, MixesView with MixCardView, SettingsView, IAP, sound mixing). The app is completely ad-free and uses the cyan/turquoise (#7FE6DB) Material Design 3 dark theme throughout. Now add widgets, sleep timer, alarm, and sleep clock.

DESIGN CONTINUITY:
- All new UI must use the existing Theme.swift color tokens (primary #7FE6DB, background #0C0E12, etc.)
- The sleep timer and sleep clock should use the same glass morphism patterns (ultraThinMaterial + dark opacity backgrounds)
- The "Timer" button in the NowPlayingView floating action bar should become functional in this phase

WIDGET TARGET:
- Create a new WidgetKit extension target: "WhiteNoiseSleepSoundsWidget"
- Set up an App Group (e.g., "group.com.zalgo.whitenoisesleepsounds") shared between main app and widget
- Use the shared App Group's UserDefaults to pass current playback state from main app to widget

WIDGETS:
1. Medium Home Screen Widget (systemMedium):
   - Shows: currently playing sound name (or "Not Playing"), background image
   - 3 quick-play buttons for the user's top 3 most-played or favorited sounds
   - Each button uses an AppIntent to trigger playback
   - Design: dark background, rounded corners, sound name in white, small thumbnail icons for quick-play buttons

2. Small Home Screen Widget (systemSmall):
   - Shows: play/pause-style icon + current sound thumbnail as background
   - Tap opens the app to Now Playing
   - Simple, visual, at-a-glance

3. Lock Screen Widget (accessoryCircular):
   - Small waveform SF Symbol icon
   - Tap opens app

4. Lock Screen Widget (accessoryRectangular):
   - Sound name text + small play icon
   - Tap opens app

APP INTENTS:
- PlaySoundIntent: takes a soundId parameter, triggers playback of that sound
- TogglePlaybackIntent: play/pause current sound
- Use AppIntents framework and make them available to both widgets and Siri Shortcuts
- Main app should check shared UserDefaults on launch for pending intents

SHARED STATE:
- When main app plays/pauses/changes sound, write to shared UserDefaults:
  - "currentSoundId", "currentSoundName", "isPlaying"
- Widget reads this to display current state
- Widget timeline: use .atEnd policy, refresh every 15 minutes (WidgetKit minimum)
- Call WidgetCenter.shared.reloadAllTimelines() whenever playback state changes in main app

SLEEP TIMER:
- The "Timer" button in the NowPlayingView floating action bar (already added in Phase 1) now becomes functional
- Tapping "Timer" in the floating action bar opens a SleepTimerView sheet
- When a timer is active, the Timer button shows in primary color (instead of muted onSurfaceVariant)
- Options: preset buttons for 15, 30, 45, 60, 120 minutes + custom Picker for hours & minutes
- "Fade out" toggle (default ON): if on, volume linearly decreases to 0 over the last 30 seconds
- "Start Timer" button starts the countdown
- While active: show remaining time on Now Playing screen as a small label below the sound name (e.g., "Sleep timer: 28:42")
- When timer fires: stop all audio, optionally trigger alarm (see below)
- "Cancel Timer" button to stop early
- Store active timer state in a TimerManager @Observable class

SLEEP TIMER IMPLEMENTATION:
- Use a Foundation Timer that fires every 1 second to update the countdown display
- When remaining time reaches 30 seconds and fadeOut is enabled, start decreasing volume linearly
- When remaining time reaches 0, call audioEngine.stop()
- Don't use DispatchQueue.asyncAfter for long timers — use Timer + target date comparison

ALARM (SIMPLE):
- Optional: after sleep timer completes, set an alarm to wake up
- In SleepTimerView, add a section: "Wake Alarm" with a time picker
- Implementation: schedule a UNNotificationRequest with a UNCalendarNotificationTrigger
- Notification sound: use a bundled alarm tone (gentle chime, 10 seconds)
- When user taps the notification, app opens and can optionally resume playback
- Request notification permission if not already granted

SLEEP CLOCK (BEDSIDE MODE):
- New view: SleepClockView
- Access from: Now Playing screen (clock icon button) or tab bar long-press
- Full-screen TRUE BLACK background (#000000) for OLED
- Large digital clock: current time in HH:mm format, using a monospaced/digital-style font
- Date below: "Sunday, April 12" in smaller muted text
- Use TimelineView(.periodic(from: .now, by: 1.0)) for live updates
- Tap anywhere: briefly show sound name + sleep timer remaining (fade in/out over 2 seconds)
- Double-tap or swipe down: dismiss sleep clock
- Disable idle timer: UIApplication.shared.isIdleTimerDisabled = true (re-enable on dismiss)
- Auto-dim: reduce UIScreen.main.brightness to 0.1 after 5 seconds of no touch, restore on touch
- App is ad-free throughout (no ad gating needed)
- Audio continues playing underneath

Make sure:
1. Widget extension compiles and shows on home screen
2. Tapping widget quick-play buttons starts the sound in the main app
3. Sleep timer counts down and stops audio (with optional fade)
4. Sleep clock shows a clean bedside clock on black background
5. Alarm notification fires at the set time
6. All new features integrate with the existing premium gating (locked sounds require IAP)
```

---

## PHASE 5 PROMPT — Full Parity & Polish

```
My White Noise — Sleep Sounds app has the full design-reference UI (HomeView bento grid, DiscoverView, NowPlayingView with glass morphism + floating action bar, MiniPlayerView, MixesView with MixCardView + "Curated for You", SettingsView, IAP, sound mixing, widgets, sleep timer, alarm, sleep clock). The app is completely ad-free and uses the cyan/turquoise (#7FE6DB) Material Design 3 dark theme from the design reference. Now add the final features for full parity and a polished App Store release.

DESIGN CONTINUITY:
- All new UI must use Theme.swift color tokens (primary #7FE6DB, surfaceContainerHigh #1D2025, etc.)
- Onboarding screens should use the same immersive, dark aesthetic with primary color accents
- Scenes/category cards should follow the SoundCard visual language (image bg, gradient overlay, rounded corners)
- The "Audio" button in the NowPlayingView floating action bar should connect to audio quality/EQ settings if relevant

PLAYLIST / QUEUE:
- PlaylistManager @Observable class with an ordered array of Sound items
- Methods: addToPlaylist(sound:), removeFromPlaylist(at:), moveSound(from:to:), clearPlaylist()
- Persist to UserDefaults
- PlaylistView: NavigationStack with EditButton for drag-to-reorder and swipe-to-delete
- Each row: thumbnail + sound name + duration indicator
- Playback: when current sound reaches a set duration (default: loop forever, but user can set per-sound play time), advance to next
- Add "Add to Playlist" option: long-press context menu on any SoundCardView in DiscoverView or HomeView

SOUND CATEGORIES / SCENES (DESIGN-REFERENCE INSPIRED):
- New view: ScenesView — a visual, card-based way to browse sounds
- Add as a segmented control toggle on the DiscoverView: "Sounds" (grid view, current) / "Scenes" (category cards)
- Each scene is a full-width card (~160pt tall, 24pt radius) following the SoundCard visual language:
  - Background image (fills frame, opacity 0.8)
  - Gradient overlay (black bottom → transparent top)
  - Category name in large white bold text (24pt heavy rounded) with shadow
  - Sound count label (e.g., "8 sounds") in onSurfaceVariant, 10px uppercase tracking-widest
  - Category badge pill in primary color at top-left
- Tapping a scene card navigates to a filtered grid for that category
- Scenes: Noise, Rain, Nature, Urban, Machine, Fire & Warmth, Water, Premium (locked, shows lock overlay with primary-tinted glass if not premium)
- Use the same staggered entrance animations as the DiscoverView grid

ONBOARDING (3 SCREENS):
- Show on first launch only (track with UserDefaults key "hasSeenOnboarding")
- Screen 1: Full-screen background image, app name "White Noise — Sleep Sounds" in large text, tagline "Your personal sound sanctuary"
- Screen 2: "How it works" — three rows with SF Symbol icons: speaker.wave.3.fill "Pick a sound or mix your own", moon.zzz.fill "Set a sleep timer", sparkles "Fall asleep peacefully"
- Screen 3: "Get started" — two buttons: "Start Free" in secondary style, "Go Premium — $3.99" in primary accent style
- Page dots at bottom, swipe between screens
- "Skip" button top-right

PREMIUM SOUNDS:
- Mark sounds 28-39 from the sound library as isPremium = true
- These are already gated in Phase 2 — just make sure all 12 premium sounds are in the SoundLibrary
- When premium user plays a premium sound, it works normally
- Premium scene card should show as partially locked with a "12 sounds — Premium" label

SLEEP LOG (BASIC):
- SleepLogEntry struct: id (UUID), date (Date), soundsUsed ([String] — sound names), duration (TimeInterval), startTime (Date)
- SleepLogManager @Observable class, persists to UserDefaults
- Automatically log an entry when: sleep timer completes, or sleep clock is dismissed after >5 minutes
- SleepLogView: list grouped by week, each row shows date, sounds used, duration
- Access from Settings
- Simple and lightweight — no charts or analytics, just a log

IMPORT CUSTOM SOUNDS:
- "Import Sound" button in Settings → Sounds section
- Uses UIDocumentPickerViewController (UIViewControllerRepresentable) for .mp3, .m4a, .wav
- Imported file copied to app's Documents/CustomSounds/ directory
- Prompt for: sound name (text field), category (picker)
- Custom sounds appear in the Sounds list with a generic waveform background
- Custom sounds are always free (no premium gating)

SIRI SHORTCUTS (APP INTENTS):
- Extend existing AppIntents from Phase 4:
  - PlaySoundIntent: "Play [sound name]" — add to Shortcuts app
  - PlayMixIntent: "Play [mix name]"
  - StartSleepTimerIntent: "Start sleep timer for [duration]"
  - OpenSleepClockIntent: "Open sleep clock"
- Add AppShortcutsProvider with suggested shortcuts

ALTERNATE APP ICONS:
- Add 3 alternate icons to the asset catalog:
  - "AppIcon-Minimal" — white waveform on black
  - "AppIcon-Nature" — leaf + waves on green
  - "AppIcon-Ocean" — wave on blue
- In Settings → Appearance: icon picker using UIApplication.shared.setAlternateIconName()
- Show small previews of each icon option

FINAL POLISH:
- Add haptic feedback (UIImpactFeedbackGenerator) on: play/pause, favorite toggle, timer start
- Add smooth animations: .animation(.easeInOut) on Now Playing transitions
- Crossfade audio when switching between sounds (0.5s fade out old, fade in new)
- Handle interruptions: AVAudioSession.interruptionNotification — pause on call, resume after
- Handle route changes: AVAudioSession.routeChangeNotification — pause when headphones disconnected
- Memory management: stop audio engine when app enters background and no sound is playing

Make sure:
1. Playlist queue works with drag-to-reorder
2. Scenes view shows beautiful cards for each category
3. Onboarding shows on first launch only
4. All 12 premium sounds are present and gated
5. Sleep log records entries automatically
6. Import custom sounds works for .m4a and .mp3
7. Siri Shortcuts appear in the Shortcuts app
8. Alternate app icons can be selected in Settings
9. App feels polished and ready for App Store submission
```

---

# APPENDIX A: QUICK REFERENCE CARD

| Item | Value |
|---|---|
| App Name | White Noise — Sleep Sounds |
| Bundle ID | com.zalgo.whitenoisesleepsounds |
| IAP Product ID | com.zalgo.whitenoisesleepsounds.premium |
| IAP Price | $3.99 (Tier 1) |
| App Group | group.com.zalgo.whitenoisesleepsounds |
| Category | Health & Fitness |
| Secondary Category | Lifestyle |
| Minimum iOS | 17.0 |
| Architecture | MVVM |
| Audio | AVAudioEngine + AVAudioPlayerNode + AVAudioSourceNode |
| UI | SwiftUI (no UIKit except wrappers for AirPlay, DocumentPicker) |
| Ads | None — completely ad-free |
| IAP | StoreKit 2 — Non-consumable |
| Widgets | WidgetKit — Small, Medium, Lock Screen |
| Persistence | UserDefaults + App Groups (shared with widget) |
| Sound Format | AAC .m4a, 128kbps, 44100Hz, 30-60s loops |
| Total Sounds | 39 (27 free + 12 premium, 4 procedural) |
| Est. App Size | 25-30 MB |

---

# APPENDIX B: XCODE PROJECT SETUP CHECKLIST

1. Create new Xcode project: iOS App, SwiftUI, Swift
2. Set deployment target: iOS 17.0
3. Add Capabilities:
   - Background Modes → Audio, AirPlay, and Picture in Picture
   - App Groups → group.com.zalgo.whitenoisesleepsounds
4. No ad SDK needed — app is completely ad-free
5. Create StoreKit Configuration file for testing IAP
6. Create Widget Extension target
7. Add sound files to Resources/Sounds/ (add to target)
8. Add background images to Assets.xcassets
9. Set app icon in Assets.xcassets (1024x1024)

---

*Document created: April 12, 2026*  
*For: Zalgo (Faisal Ali)*  
*Project: White Noise — Sleep Sounds*
