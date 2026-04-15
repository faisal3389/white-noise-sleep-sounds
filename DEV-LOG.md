# Development Log

## Phase 4 -- Widgets, Timers & Sleep Clock

### Session: 2026-04-14

#### Features Added
- **TimerManager** (`Models/TimerManager.swift`) -- @Observable class managing sleep timer countdown, fade-out, and alarm scheduling via UNUserNotificationCenter
- **SleepTimerView** (`Views/SleepTimerView.swift`) -- Sheet with 6 preset durations (15/30/45/60/120/240 min), custom hour/minute picker, fade-out toggle, and optional wake alarm with time picker
- **SleepClockView** (`Views/SleepClockView.swift`) -- Full-screen OLED-black bedside clock with auto-dim (0.1 brightness after 5s), idle timer disabled, tap-to-show-info, swipe-down-to-dismiss
- **SharedPlaybackState** (`Models/SharedPlaybackState.swift`) -- UserDefaults-based shared state for future WidgetKit integration, synced on every play/pause/stop
- **NowPlayingView updates** -- Added moon icon (sleep timer), clock icon (sleep clock), timer countdown label below title
- **ContentView** -- TimerManager wired up with onTimerComplete (stops audio) and onFadeOut (volume ramp)

#### Crashes & Fixes
- **ATT Crash (CRITICAL):** App crashed on launch with `"This app has crashed because it attempted to access privacy-sensitive data without a usage description"`. Root cause: `AppTrackingTransparency` framework is importable on simulator (so `#if canImport` passes), but the Info.plist `NSUserTrackingUsageDescription` key wasn't linked to the target properly. Fix: Removed ATT/GoogleMobileAds code from `White_Noise___Sleep_SoundsApp.swift` since neither SDK is actually integrated yet. Will re-add when AdMob is properly set up.

#### Interaction Bugs & Fixes
- **Tab API touch issue:** Original code used `Tab("...", systemImage:, value:)` API (iOS 18+). On iOS 26 simulator, tabs were visible but unresponsive to taps. Fix: Switched to classic `.tabItem { Label(...) }` + `.tag()` pattern.
- **onTapGesture swallowing touches:** `SoundsListView` and `FavoritesView` used `.onTapGesture` on list rows, which intercepted all touch events and blocked both row taps and nested button taps (favorites heart). Fix: Replaced with `Button { } label: { SoundRowView(...) }.buttonStyle(.plain)`.
- **MixesView hero card gesture conflict:** `onLongPressGesture(minimumDuration: 0, pressing:)` on the "Create New Mix" hero card conflicted with the `Button` action. Fix: Removed the long press gesture.

#### Decisions
- Widget extension target requires manual Xcode setup (File > New > Target > Widget Extension). All shared infrastructure is in place.
- Used `UITabBarAppearance` in `.onAppear` instead of `.toolbarBackground` modifier for tab bar styling -- more reliable across iOS versions.
- Timer uses `Date` target comparison (not decrementing counter) to stay accurate across app backgrounding.

### Session: 2026-04-14 (Widgets)

#### Features Added
- **WhiteNoiseWidgets Extension** -- WidgetKit extension target with 4 widgets
- **NowPlayingSmallWidget** (systemSmall) -- Play/pause icon + current sound name, tap toggles playback or opens app
- **NowPlayingMediumWidget** (systemMedium) -- Current sound with background image, EQ bars indicator, 3 quick-play capsule buttons for favorite sounds
- **LockScreenCircularWidget** (accessoryCircular) -- Waveform icon, tap opens Now Playing
- **LockScreenRectangularWidget** (accessoryRectangular) -- Sound name + play/pause status indicator
- **SharedPlaybackState** upgraded to App Group (`group.com.zalgo.whitenoise`) UserDefaults for cross-process widget communication. Added `backgroundImage` and `favoriteSoundIds` fields
- **Deep link URL scheme** (`whitenoise://`) registered in Info.plist. Handles `whitenoise://nowplaying`, `whitenoise://toggle`, `whitenoise://play/{soundId}`
- **RootView** handles `onOpenURL` deep links and passes actions to ContentView
- **ContentView** processes deep link actions (navigate to Now Playing, toggle playback, play specific sound) and syncs favorites to widget shared state

#### Bug Fixes
- **Widget white padding:** `.containerBackground(.clear, for: .widget)` left system default white background showing. Fix: moved background image/gradient into `.containerBackground(for: .widget) { ... }` closure so it fills edge-to-edge

#### Decisions
- Used deep link URLs instead of AppIntents for widget actions -- simpler, no shared framework target needed, widgets can't play audio directly anyway
- Widget timeline refreshes every 15 minutes + on every playback state change via `WidgetCenter.shared.reloadAllTimelines()`
- Quick-play buttons default to White Noise, Heavy Rain, Ocean Waves; update to user's top 3 favorites when available

---

## Phase 5 -- Full Feature Parity + Premium

### Session: 2026-04-14

#### Features Added
- **OnboardingView** (`Views/OnboardingView.swift`) -- 3-screen paged onboarding: welcome with app branding, feature highlights (pick/mix/sleep), get started with premium pitch. Skip button, page indicators, AppStorage-persisted `has_seen_onboarding` flag
- **PlaylistManager** (`Models/PlaylistManager.swift`) -- @Observable queue system with drag-to-reorder, per-item optional duration (auto-advance after N minutes), start/stop/advance/previous, UserDefaults JSON persistence
- **PlaylistView** (`Views/PlaylistView.swift`) -- Full playlist UI with numbered rows, playing indicator, duration menu per item, edit mode for reorder/delete, "Add to Playlist" sheet with full sound library
- **SleepLogManager** (`Models/SleepLogManager.swift`) -- @Observable sleep session tracker. Auto-logs sessions >1 minute on timer complete or playback stop. Weekly grouping, total/average stats, UserDefaults persistence
- **SleepLogView** (`Views/SleepLogView.swift`) -- Stats header (this week total, average duration, session count), weekly-grouped entry list with context menu delete
- **ScenesView** (`Views/ScenesView.swift`) -- Portal-inspired full-width category cards with background images, gradient overlays, sound count badges. Taps into SceneDetailView showing hero header + sound list for that category
- **CustomSoundsManager** (`Models/CustomSoundsManager.swift`) -- Import sounds from Files app (MP3/M4A/WAV/AIFF) via UIDocumentPickerViewController. Copies to app sandbox Documents/CustomSounds/, UserDefaults metadata persistence
- **ImportSoundView** (`Views/ImportSoundView.swift`) -- Dashed import button, file picker, naming sheet with category picker, imported sounds list with play/delete
- **MoreView** (`Views/MoreView.swift`) -- Consolidated "More" tab replacing separate Favorites and Settings tabs. NavigationLinks to: Favorites, Playlist, Sleep Log, My Sounds (import), plus inline Premium, Playback, and About sections

#### Architecture Changes
- **Tab restructure:** 5 tabs now: Sounds (0), Scenes (1), Now Playing (2), Mixes (3), More (4). Previous: Sounds/NowPlaying/Mixes/Favorites/Settings
- **RootView:** Extracted from App struct to handle onboarding/content switching (avoids `some Scene` type issues with if/else in App body)
- **AudioEngine:** Extended `playFile()` to support absolute file paths for custom imported sounds (detects leading `/`)
- **Sleep log auto-tracking:** ContentView watches `player.isPlaying` changes to start/end sleep log sessions. Timer completion also triggers session end
- **Playlist wiring:** ContentView sets `playlistManager.onPlaySound` and `onPlaylistFinished` callbacks
- **FavoritesView:** Removed NavigationStack wrapper (now pushed inside MoreView's NavigationStack)
- **Tab indices updated:** All `selectedTab = 1` references updated to `selectedTab = 2` across Sounds, Favorites, Scenes, Playlist, Import views

#### Bug Fixes
- **`Scene` name collision:** Named the scenes data model `Scene` which shadowed SwiftUI's `Scene` protocol, breaking `some Scene` in App struct. Renamed to `SoundScene`
- **PlaylistManager missing import:** `remove(atOffsets:)` and `move(fromOffsets:toOffset:)` require SwiftUI import for IndexSet extensions

---

## Known Bugs

| # | Screen | Description | Status |
|---|--------|-------------|--------|
| 1 | Favorites | Empty state background only covers a strip in the center, not the full screen. Fix: added `.frame(maxWidth: .infinity, maxHeight: .infinity)` to emptyState VStack | FIXED |
