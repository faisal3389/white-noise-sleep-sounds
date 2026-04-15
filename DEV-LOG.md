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

---

## Known Bugs

| # | Screen | Description | Status |
|---|--------|-------------|--------|
| 1 | Favorites | Empty state background only covers a strip in the center, not the full screen. Fix: added `.frame(maxWidth: .infinity, maxHeight: .infinity)` to emptyState VStack | FIXED |
