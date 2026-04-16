# TODO: Now Playing Lock Screen Controls & Live Activities

> **Priority:** Phase 4 add-on (post-widgets/timers)
> **Goal:** Give users an immersive, Portal-style experience on the lock screen — category-themed artwork in Now Playing controls + a persistent Live Activity showing playback state and sleep timer.

---

## Feature 1: Now Playing Lock Screen Controls (MPNowPlayingInfoCenter)

### What It Does
When audio is playing, the lock screen and Control Center show album-art-style artwork, the sound/mix name, and play/pause/skip controls — all themed to the current sound category.

### Implementation Steps

#### 1. Add MediaPlayer Framework
- Import `MediaPlayer` in `AudioEngine.swift` (or create a dedicated `NowPlayingManager.swift`)
- No additional entitlements needed — this works with the existing background audio mode

#### 2. Set Now Playing Info
Every time playback starts or the sound changes, update `MPNowPlayingInfoCenter.default().nowPlayingInfo`:

```swift
import MediaPlayer

func updateNowPlayingInfo(sound: Sound, isPlaying: Bool) {
    var info = [String: Any]()
    info[MPMediaItemPropertyTitle] = sound.name
    info[MPMediaItemPropertyArtist] = "White Noise"  // App name as artist
    info[MPMediaItemPropertyAlbumTitle] = sound.category.rawValue  // e.g. "Rain", "Nature"
    
    // Category-themed artwork (see artwork section below)
    if let image = UIImage(named: sound.nowPlayingArtwork) {
        let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        info[MPMediaItemPropertyArtwork] = artwork
    }
    
    // Playback rate for play/pause icon state
    info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
}
```

#### 3. Handle Remote Commands
Register for play/pause/stop commands so the lock screen buttons actually work:

```swift
func setupRemoteCommandCenter() {
    let commandCenter = MPRemoteCommandCenter.shared()
    
    commandCenter.playCommand.addTarget { [weak self] _ in
        self?.resume()
        return .success
    }
    
    commandCenter.pauseCommand.addTarget { [weak self] _ in
        self?.pause()
        return .success
    }
    
    commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
        self?.togglePlayPause()
        return .success
    }
    
    // Optional: next/previous to cycle through sounds in the same category
    commandCenter.nextTrackCommand.addTarget { [weak self] _ in
        self?.playNextSound()
        return .success
    }
    
    commandCenter.previousTrackCommand.addTarget { [weak self] _ in
        self?.playPreviousSound()
        return .success
    }
}
```

Call `setupRemoteCommandCenter()` once at app launch (in `AudioEngine.init()` or `ContentView.onAppear`).

#### 4. Category-Themed Artwork
Each category needs a beautiful, mood-appropriate Now Playing image. These show as the big artwork on the lock screen.

**Artwork mapping by category:**

| Category   | Mood/Vibe              | Suggested Artwork                        | Asset Name              |
|------------|------------------------|------------------------------------------|--------------------------|
| `.noise`   | Minimal, abstract      | Dark gradient with subtle wave pattern   | `np_noise`              |
| `.rain`    | Cozy, moody            | Rain on a window, blurred city lights    | `np_rain`               |
| `.nature`  | Serene, earthy         | Misty forest, soft greens                | `np_nature`             |
| `.urban`   | Warm, ambient          | Soft-lit cafe or city at dusk            | `np_urban`              |
| `.machine` | Clean, neutral         | Abstract mechanical texture, cool tones  | `np_machine`            |
| `.fire`    | Warm, intimate         | Glowing campfire or fireplace close-up   | `np_fire`               |
| `.water`   | Calm, flowing          | Ocean horizon, soft blues                | `np_water`              |
| `.premium` | Luxe, special          | Dark with gold/purple accent, starfield  | `np_premium`            |

**Alternatively**, reuse the existing `backgroundImage` from each `Sound` — every sound already has a `bg_xxx` image. The simplest approach is to just use `sound.backgroundImage` as the artwork. Category-level fallbacks can be added later.

**Recommended approach:** Start with `sound.backgroundImage` as artwork (already exists), then optionally add dedicated square `np_xxx` artwork later for a more polished lock screen look.

#### 5. Mix Support
For mixes (multiple sounds playing), show:
- **Title:** Mix name (e.g., "Rainy Cafe")
- **Artist:** "White Noise"
- **Album:** "Custom Mix" or the dominant category
- **Artwork:** Use the mix's first sound's background image, or create a dedicated mix artwork

#### 6. Where to Call Updates
- `AudioEngine.playSound()` → call `updateNowPlayingInfo()`
- `AudioEngine.playMix()` → call `updateNowPlayingInfo()` with mix info
- `AudioEngine.pause()` → update playback rate to 0
- `AudioEngine.resume()` → update playback rate to 1
- `AudioEngine.stop()` → set `nowPlayingInfo = nil`

---

## Feature 2: Live Activities (ActivityKit)

### What It Does
Shows a persistent, glanceable banner on the lock screen and in the Dynamic Island (iPhone 14 Pro+) with the current sound name, category icon, and optional sleep timer countdown.

### Requirements
- iOS 16.1+ (Lock Screen Live Activities)
- iOS 16.1+ with iPhone 14 Pro/Pro Max+ (Dynamic Island)
- New Widget Extension target (or extend existing `WhiteNoiseWidgets` target)

### Implementation Steps

#### 1. Create the Activity Attributes
In a shared file accessible to both the main app and widget extension:

```swift
import ActivityKit

struct WhiteNoiseActivityAttributes: ActivityAttributes {
    // Static data that doesn't change during the activity
    struct ContentState: Codable, Hashable {
        var soundName: String
        var categoryIcon: String       // SF Symbol name
        var categoryName: String
        var isPlaying: Bool
        var timerEndDate: Date?        // nil if no sleep timer
        var mixSoundCount: Int?        // nil if single sound, count if mix
    }
}
```

#### 2. Lock Screen Live Activity View
Create the expanded lock screen banner:

```swift
import WidgetKit
import SwiftUI
import ActivityKit

struct WhiteNoiseLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WhiteNoiseActivityAttributes.self) { context in
            // Lock Screen banner
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: context.state.categoryIcon)
                    .font(.title2)
                    .foregroundStyle(.cyan)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.soundName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Text(context.state.categoryName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Sleep timer countdown (if active)
                if let endDate = context.state.timerEndDate {
                    Text(endDate, style: .timer)
                        .font(.title3.monospacedDigit())
                        .foregroundStyle(.cyan)
                }
                
                // Play/pause indicator
                Image(systemName: context.state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.cyan)
            }
            .padding()
            .background(Color(red: 0.05, green: 0.06, blue: 0.1)) // #0D0F1A app bg
            
        } dynamicIsland: { context in
            // Dynamic Island (iPhone 14 Pro+)
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.categoryIcon)
                        .foregroundStyle(.cyan)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.soundName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let endDate = context.state.timerEndDate {
                        Text(endDate, style: .timer)
                            .monospacedDigit()
                            .foregroundStyle(.cyan)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.categoryIcon)
                    .foregroundStyle(.cyan)
            } compactTrailing: {
                if context.state.isPlaying {
                    Image(systemName: "waveform")
                        .foregroundStyle(.cyan)
                }
            } minimal: {
                Image(systemName: context.state.categoryIcon)
                    .foregroundStyle(.cyan)
            }
        }
    }
}
```

#### 3. Start/Update/End Activities from Main App
Create a `LiveActivityManager.swift`:

```swift
import ActivityKit

@Observable
class LiveActivityManager {
    private var currentActivity: Activity<WhiteNoiseActivityAttributes>?
    
    func startActivity(sound: Sound, isPlaying: Bool, timerEndDate: Date?) {
        // Check if Live Activities are enabled in settings
        guard UserDefaults.standard.bool(forKey: "liveActivitiesEnabled") else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let state = WhiteNoiseActivityAttributes.ContentState(
            soundName: sound.name,
            categoryIcon: sound.category.iconName,
            categoryName: sound.category.rawValue,
            isPlaying: isPlaying,
            timerEndDate: timerEndDate,
            mixSoundCount: nil
        )
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: WhiteNoiseActivityAttributes(),
                content: content,
                pushType: nil  // local updates only
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateActivity(isPlaying: Bool, timerEndDate: Date?) {
        guard let activity = currentActivity else { return }
        
        var updatedState = activity.content.state
        updatedState.isPlaying = isPlaying
        updatedState.timerEndDate = timerEndDate
        
        let content = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(content)
        }
    }
    
    func endActivity() {
        Task {
            await currentActivity?.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
```

#### 4. Wire It Into AudioEngine / ContentView
- On `playSound()` → `liveActivityManager.startActivity(...)`
- On `pause()` / `resume()` → `liveActivityManager.updateActivity(...)`
- On `stop()` → `liveActivityManager.endActivity()`
- On timer start/cancel → `liveActivityManager.updateActivity(timerEndDate:)`

#### 5. Info.plist
Add to main app's Info.plist:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

---

## Feature 3: Settings Toggle for Live Activities

### Where
In `SettingsView.swift` (or `MoreView.swift` — whichever is the active settings screen), add a new section.

### Implementation

Add to `SettingsManager`:
```swift
@AppStorage("liveActivitiesEnabled") var liveActivitiesEnabled: Bool = true
```

Add a new section in SettingsView, between "Playback" and "About":

```swift
Section("Lock Screen") {
    Toggle(isOn: $settings.liveActivitiesEnabled) {
        Label("Live Activity", systemImage: "rectangle.badge.person.crop")
            .foregroundStyle(.white)
    }
    .tint(.cyan)
    .listRowBackground(Color.appSurface)
    
    // Explanatory text
    Text("Shows the current sound and sleep timer on your Lock Screen and Dynamic Island.")
        .font(.caption)
        .foregroundStyle(.white.opacity(0.4))
        .listRowBackground(Color.appSurface)
}
```

### Behavior
- **Default:** ON (`true`)
- **When toggled OFF:** `LiveActivityManager.startActivity()` checks this flag and returns early. Also immediately ends any active Live Activity.
- **When toggled ON:** Next playback session will show the Live Activity.

Add an observer in `LiveActivityManager` or wire it from ContentView:
```swift
// When user disables Live Activities mid-playback, end it immediately
func onSettingsChanged(enabled: Bool) {
    if !enabled {
        endActivity()
    }
}
```

---

## Files to Create / Modify

| Action   | File                                        | Purpose                                    |
|----------|---------------------------------------------|--------------------------------------------|
| Create   | `Models/LiveActivityManager.swift`          | Start/update/end Live Activities           |
| Create   | `Models/WhiteNoiseActivityAttributes.swift` | Shared ActivityKit attributes (both targets)|
| Create   | `Widgets/WhiteNoiseLiveActivity.swift`      | Lock screen + Dynamic Island UI            |
| Modify   | `AudioEngine.swift`                         | Add MPNowPlayingInfoCenter + remote commands|
| Modify   | `SettingsManager.swift`                     | Add `liveActivitiesEnabled` property       |
| Modify   | `SettingsView.swift` / `MoreView.swift`     | Add "Lock Screen" toggle section           |
| Modify   | `ContentView.swift`                         | Wire LiveActivityManager into playback flow|
| Modify   | `Info.plist`                                | Add `NSSupportsLiveActivities = YES`       |
| Add      | Asset Catalog                               | Now Playing artwork images (optional)      |

---

## Notes & Gotchas

- **Live Activities have an 8-hour max lifespan** — after 8 hours iOS will end them. For overnight sleep sounds, the activity will disappear but audio continues. Consider restarting the activity if playback is still going.
- **Live Activities require the Widget Extension target.** The existing `WhiteNoiseWidgets` target should work — just add the `WhiteNoiseLiveActivity` widget to the bundle. The `WhiteNoiseActivityAttributes` struct must be compiled into BOTH the main app target and the widget extension target (add to both target memberships).
- **Now Playing controls work without any widget extension** — they only need the MediaPlayer framework in the main app. These can be implemented independently and first.
- **Test on a real device** — Live Activities and Dynamic Island don't work well in the simulator.
- **The `backgroundImage` assets already exist for every sound** — reuse them for Now Playing artwork initially. Square-cropped variants can be added later.
