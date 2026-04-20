# TODO: Analytics Fixes & Dynamic Island Controls

> **Source:** GA4 analysis for Mar 20 – Apr 16, 2026 (22 users, 1,969 events)
> **Priority:** High — blocks meaningful user-behavior analysis and a live UX bug

---

## Priority 1: Dynamic Island — add a real way to end a session

### The Problem
When audio starts, the Live Activity persists on the Dynamic Island / Lock Screen. Users can pause from the Dynamic Island, but:
- There is **no way to fully close / end the session** from outside the app
- After minimizing or going to the home screen, the Dynamic Island element stays "stuck"
- Users have to reopen the app just to kill playback

Reference apps that do this well: **SquareFlow**, **Portal**, **Dark Noise** — they all have a clear stop button on the Live Activity.

### What To Build
A **Stop / End Session button** on both the Dynamic Island expanded view and the Lock Screen banner that:
1. Calls `AudioEngine.shared.stop()`
2. Triggers `LiveActivityManager.endActivity()`
3. Finalizes the sleep session so `sleep_session_ended` fires with duration
4. Dismisses the Dynamic Island / Lock Screen activity immediately

### Implementation (iOS 17+)
Use an `AppIntent` wired to a `Button(intent:)` inside the Live Activity view. AppIntents can execute while the app is backgrounded.

```swift
// New file: AppIntents/StopPlaybackIntent.swift
import AppIntents

struct StopPlaybackIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Playback"

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AudioEngine.shared.stop()  // cascades to LiveActivityManager.endActivity()
        }
        return .result()
    }
}

struct TogglePlaybackIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Toggle Playback"

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AudioEngine.shared.togglePlayPause()
        }
        return .result()
    }
}
```

Then in `WhiteNoiseLiveActivity.swift`, add the buttons to the expanded region:

```swift
DynamicIslandExpandedRegion(.bottom) {
    HStack(spacing: 24) {
        Button(intent: TogglePlaybackIntent()) {
            Image(systemName: context.state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.title)
                .foregroundStyle(.cyan)
        }
        .buttonStyle(.plain)

        Button(intent: StopPlaybackIntent()) {
            Image(systemName: "stop.circle.fill")
                .font(.title)
                .foregroundStyle(.white.opacity(0.8))
        }
        .buttonStyle(.plain)
    }
    .padding(.top, 4)
}
```

And the same two buttons on the Lock Screen banner so people can end a session without even unlocking.

### Acceptance Criteria
- [ ] Tapping Stop on Dynamic Island ends audio AND removes the activity within ~1s
- [ ] `sleep_session_ended` fires with the accurate duration
- [ ] Works with the screen locked (no Face ID unlock required)
- [ ] Tested on iPhone 14 Pro+ (real device — simulator is unreliable for Live Activities)
- [ ] Works when app is fully backgrounded (not just minimized)

---

## Priority 2: Fix `sleep_session_ended` reliability

### The Problem
GA shows **62 `sleep_session_started`** events but `sleep_session_ended` isn't even in the top 28 events. Most sessions are starting but never cleanly ending in the data.

### Root Causes
Looking at `SleepLogManager.swift`:

1. **Sub-1-minute sessions drop silently** — `finalize()` returns early if `duration < 1`
   ```swift
   let duration = Int(endDate.timeIntervalSince(session.startDate) / 60)
   guard duration >= 1 else { return }
   ```

2. **Overnight app kills aren't handled gracefully** — if iOS kills the app at 3am and the user doesn't reopen until the next night, the heartbeat is stale and the recovered session may or may not be finalized depending on `finalizePendingSession()` timing.

3. **No distinction between "user stopped" vs "app was killed" vs "timer expired"** — all end the same way analytically.

### Fix
Add an `end_reason` property to distinguish end paths, and don't silently drop short sessions:

```swift
enum SleepSessionEndReason: String {
    case userStopped = "user_stopped"         // stop button, Dynamic Island, etc.
    case timerExpired = "timer_expired"       // sleep timer hit 0
    case relaunchRecovered = "relaunch_recovered"  // finalizePendingSession on next launch
    case abandoned = "abandoned"              // heartbeat stale, no recovery possible
}

private func finalize(session: ActiveSession, endDate: Date, reason: SleepSessionEndReason) {
    let duration = Int(endDate.timeIntervalSince(session.startDate) / 60)

    // Always fire the event — even for short sessions — but tag them
    AnalyticsManager.shared.track(.sleepSessionEnded, properties: [
        "sound_name": session.soundName,
        "duration_minutes": duration,
        "is_mix": session.mixName != nil,
        "end_reason": reason.rawValue,
        "was_short_session": duration < 1
    ])

    // Only add to sleep log if it's meaningful (keep the 1-min floor here, not at tracking)
    guard duration >= 1 else { return }
    let entry = SleepLogEntry(...)
    entries.insert(entry, at: 0)
    save()
}
```

Call sites to update:
- `AudioEngine.stop()` → `finalize(..., reason: .userStopped)`
- Sleep timer expiration → `finalize(..., reason: .timerExpired)`
- `finalizePendingSession()` → `finalize(..., reason: .relaunchRecovered)`
- Add a periodic check: if heartbeat > 30 min stale and no active session, fire `.abandoned`

### Enrich the event
Once firing reliably, also capture:
- `had_sleep_timer: Bool`
- `timer_duration_minutes: Int?`
- `time_of_day` bucket: `early_bedtime` (20:00–23:00), `late_bedtime` (23:00–02:00), `overnight` (02:00–06:00), `nap` (any other)
- `looped_count: Int` — how many times the sound looped

This turns `sleep_session_ended` into the single richest event for understanding usage patterns — essential for a sleep app.

---

## Priority 3: Analytics instrumentation cleanup

### 3a. `premium_purchase_completed` is missing
GA tracks `premium_purchase_tapped` (53 events, 5 users) but there's no completion event. Can't measure real conversion. Add:

```swift
case premiumPurchaseCompleted = "premium_purchase_completed"
case premiumPurchaseFailed = "premium_purchase_failed"
```

Fire from the StoreKit transaction listener. Properties: `product_id`, `price_tier`, `trial_used: Bool`, and for failures: `error_code`.

### 3b. `share_app_tapped` / `rate_app_tapped` fire too often
28 share events from 2 users = 14 per user. 27 rate events from 2 users = 13.5 per user. These should be 1 per user intent, max. Almost certainly firing on `.onAppear` of a settings/menu view instead of inside the button action. **Audit firing sites** — move to the tap closure.

### 3c. `onboarding_page_viewed` is under-instrumented
20 users start onboarding, only 8 trigger `onboarding_page_viewed`. Drop-off analysis is impossible. Add an `.onAppear` fire on every onboarding page with `page_index: Int` and `page_name: String` so you can build a funnel.

### 3d. Debounce `volume_changed`
407 events from 4 users = 102 per user. Slider is firing on every delta. Change to fire on slider release only (`onEditingChanged` = false) or debounce with a trailing 500ms delay. Rename to `volume_final` for clarity. This noise is drowning out other signal.

---

## Suggested Order of Work

1. **Dynamic Island stop button** — user-facing bug, highest priority
2. **Sleep session end reliability + end_reason** — unlocks all sleep-app analysis
3. **Purchase completion event** — can't optimize revenue without it
4. **Onboarding + share/rate cleanup** — quick wins
5. **Volume debounce** — lowest priority but reduces GA noise

---

## Files Likely to Touch

| File | Change |
|------|--------|
| `AppIntents/StopPlaybackIntent.swift` | **New** — LiveActivityIntent for stop/toggle |
| `Widgets/WhiteNoiseLiveActivity.swift` | Add Button(intent:) for stop + pause |
| `Models/AudioEngine.swift` | Ensure `stop()` cascades to session finalize + live activity end |
| `Models/SleepLogManager.swift` | Add `end_reason`, don't drop short sessions from tracking |
| `Models/AnalyticsManager.swift` | Add `premiumPurchaseCompleted`, `premiumPurchaseFailed` events |
| `Views/OnboardingView.swift` | Fire `onboarding_page_viewed` on every page's `.onAppear` |
| `Views/SettingsView.swift` (or MoreView) | Move share/rate events out of `.onAppear` into button actions |
| `Views/Components/VolumeSlider.swift` (or wherever the slider lives) | Debounce `volume_changed` |
