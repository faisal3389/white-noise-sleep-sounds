# Analytics Tracking - Functional Document

**App:** White Noise - Sleep Sounds
**Last Updated:** 2026-04-15
**Version:** 1.1
**Status:** Active

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Event Naming Convention](#event-naming-convention)
4. [Event Catalog](#event-catalog)
5. [Implementation Status](#implementation-status)
6. [Backend Integration Guide](#backend-integration-guide)
7. [Future Tracking Wishlist](#future-tracking-wishlist)

---

## 1. Overview

This document is the single source of truth for all analytics events tracked in the White Noise - Sleep Sounds app. It should be updated whenever new events are added or existing events change.

**Purpose:**
- Catalog every trackable user action
- Define event names, properties, and types
- Track implementation status (implemented vs. planned)
- Serve as a migration guide when integrating analytics backends (Firebase, Mixpanel, Amplitude, PostHog, DataDog, etc.)

**Current Backend:** Local logging via `os.Logger` (no remote backend yet)
**Manager:** `AnalyticsManager.swift` (singleton, `@Observable`)

---

## 2. Architecture

```
User Action → View / ViewModel / Manager
                  ↓
         AnalyticsManager.shared.track(.eventName, properties: [...])
                  ↓
         os.Logger (local debug logging)
                  ↓
         send(event:properties:)  ← Backend integration point
                  ↓
         Firebase / Mixpanel / Amplitude / PostHog / etc.
```

**Key Design Decisions:**
- All events flow through a single `track()` method
- Properties are passed as `[String: Any]?` dictionaries
- Event names are defined as a Swift enum (`AnalyticsManager.Event`) for type safety
- The `send()` method is the sole integration point for any analytics backend

---

## 3. Event Naming Convention

| Rule | Example |
|------|---------|
| Snake_case for event names | `sound_played`, `mix_created` |
| Verb in past tense | `sound_played` not `play_sound` |
| Prefix with feature area | `playlist_sound_added`, `timer_started_preset` |
| Boolean properties use `is_` prefix | `is_enabled`, `is_premium` |
| IDs use `_id` suffix | `sound_id`, `mix_id` |
| Counts use `_count` suffix | `component_count`, `results_count` |

---

## 4. Event Catalog

### 4.1 App Lifecycle

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| App Launched | `app_launched` | — | Implemented |
| App Became Active | `app_became_active` | — | Implemented |
| App Entered Background | `app_entered_background` | — | Implemented |

**File:** `White_Noise___Sleep_SoundsApp.swift`

---

### 4.2 Onboarding

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Onboarding Started | `onboarding_started` | — | Implemented |
| Onboarding Page Viewed | `onboarding_page_viewed` | `page: Int` | Implemented |
| Onboarding Completed | `onboarding_completed` | — | Implemented |
| Onboarding Skipped | `onboarding_skipped` | `skipped_at_page: Int` | Implemented |

**File:** `OnboardingView.swift`

---

### 4.3 Navigation

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Tab Selected | `tab_selected` | `tab_name: String` | Implemented |
| Screen Viewed | `screen_viewed` | `screen_name: String` | Implemented |
| Deep Link Opened | `deep_link_opened` | `url: String`, `action: String` | Defined |
| Shortcut Used | `shortcut_used` | `shortcut: String`, `sound: String?` | Implemented |

**Files:** `ContentView.swift`, `HomeView.swift`, `AppShortcuts.swift`

---

### 4.4 Sound Playback

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Sound Played | `sound_played` | `sound_id: String`, `sound_name: String`, `category: String`, `is_premium: Bool`, `is_generated: Bool` | Implemented |
| Sound Paused | `sound_paused` | `sound_name: String`, `is_mix: Bool` | Implemented |
| Sound Resumed | `sound_resumed` | `sound_name: String`, `is_mix: Bool` | Implemented |
| Sound Stopped | `sound_stopped` | `sound_name: String`, `is_mix: Bool` | Implemented |
| Sound Next | `sound_next` | `shuffle: Bool`, `loop_mode: String` | Implemented |
| Sound Previous | `sound_previous` | `shuffle: Bool`, `loop_mode: String` | Implemented |
| Volume Changed | `volume_changed` | `volume: Float` | Implemented |
| Shuffle Toggled | `shuffle_toggled` | `enabled: Bool` | Implemented |
| Loop Mode Changed | `loop_mode_changed` | `mode: String` (off/all/one) | Implemented |

**File:** `AudioPlayerViewModel.swift`

---

### 4.5 Mix Playback

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Mix Played | `mix_played` | `mix_name: String`, `component_count: Int` | Implemented |
| Mix Component Volume Changed | `mix_component_volume_changed` | `sound_id: String`, `volume: Float` | Implemented |
| Mix Next Played | `mix_next_played` | `mix_name: String` | Implemented |
| Mix Previous Played | `mix_previous_played` | `mix_name: String` | Implemented |

**Files:** `AudioPlayerViewModel.swift`, `MixesView.swift`

---

### 4.6 Mix Management

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Mix Created | `mix_created` | `mix_name: String`, `component_count: Int`, `sound_ids: [String]` | Implemented |
| Mix Edited | `mix_edited` | `mix_id: String`, `mix_name: String` | Defined |
| Mix Deleted | `mix_deleted` | `mix_id: String`, `mix_name: String` | Implemented |
| Mix Favorited | `mix_favorited` | `mix_id: String`, `mix_name: String` | Implemented |
| Mix Unfavorited | `mix_unfavorited` | `mix_id: String`, `mix_name: String` | Defined |
| Mix Preview Started | `mix_preview_started` | `component_count: Int` | Implemented |
| Mix Preview Stopped | `mix_preview_stopped` | — | Defined |
| Curated Mix Played | `curated_mix_played` | `mix_name: String` | Defined |

**Files:** `CreateMixView.swift`, `MixesView.swift`, `MixesManager.swift`

---

### 4.7 Favorites

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Sound Favorited | `sound_favorited` | `sound_id: String`, `sound_name: String`, `source: String` | Implemented |
| Sound Unfavorited | `sound_unfavorited` | `sound_id: String`, `sound_name: String`, `source: String` | Implemented |

**Files:** `NowPlayingView.swift`, `FavoritesView.swift`

---

### 4.8 Discover & Browse

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Search Performed | `search_performed` | `query: String`, `results_count: Int` | Implemented |
| Category Selected | `category_selected` | `category_name: String` | Implemented |
| Category Browsed | `category_browsed` | `category_name: String` | Implemented |
| Scene Viewed | `scene_viewed` | `scene_name: String` | Implemented |

**Files:** `DiscoverView.swift`, `ScenesView.swift`, `SoundsListView.swift`

---

### 4.9 Now Playing & Mini Player

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Now Playing Viewed | `now_playing_viewed` | `has_content: Bool`, `is_mix: Bool` | Implemented |
| Mini Player Tapped | `mini_player_tapped` | — | Implemented |
| Mini Player Play/Pause | `mini_player_play_pause` | `action: String` (play/pause) | Implemented |
| Mixer Sheet Opened | `mixer_sheet_opened` | `mix_name: String` | Implemented |
| AirPlay Tapped | `airplay_tapped` | — | Defined |

**Files:** `NowPlayingView.swift`, `MiniPlayerView.swift`
**Note:** `airplay_tapped` cannot be tracked directly as AirPlay uses a system-provided route picker.

---

### 4.10 Sleep Timer

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Timer Started (Preset) | `timer_started_preset` | `duration_minutes: Int` | Implemented |
| Timer Started (Custom) | `timer_started_custom` | `hours: Int`, `minutes: Int` | Implemented |
| Timer Cancelled | `timer_cancelled` | `remaining_minutes: Int` | Implemented |
| Timer Completed | `timer_completed` | `duration_minutes: Int` | Implemented |
| Fade Out Toggled | `fade_out_toggled` | `is_enabled: Bool` | Implemented |
| Alarm Toggled | `alarm_toggled` | `is_enabled: Bool` | Defined |
| Alarm Time Set | `alarm_time_set` | `time: String` | Defined |

**Files:** `SleepTimerView.swift`, `TimerManager.swift`

---

### 4.11 Sleep Clock

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Sleep Clock Opened | `sleep_clock_opened` | — | Implemented |
| Sleep Clock Closed | `sleep_clock_closed` | — | Implemented |

**File:** `SleepClockView.swift`

---

### 4.12 Sleep Log

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Sleep Log Viewed | `sleep_log_viewed` | — | Implemented |
| Sleep Session Started | `sleep_session_started` | `sound_name: String`, `sound_id: String`, `is_mix: Bool` | Implemented |
| Sleep Session Ended | `sleep_session_ended` | `sound_name: String`, `duration_minutes: Int`, `is_mix: Bool` | Implemented |
| Sleep Log Entry Deleted | `sleep_log_entry_deleted` | `sound_name: String` | Implemented |

**Files:** `SleepLogView.swift`, `SleepLogManager.swift`

---

### 4.13 Playlist

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Playlist Viewed | `playlist_viewed` | — | Implemented |
| Playlist Started | `playlist_started` | `item_count: Int` | Implemented |
| Playlist Stopped | `playlist_stopped` | — | Implemented |
| Playlist Cleared | `playlist_cleared` | `item_count: Int` | Implemented |
| Playlist Sound Added | `playlist_sound_added` | `sound_id: String`, `sound_name: String` | Implemented |
| Playlist Sound Removed | `playlist_sound_removed` | — | Implemented |
| Playlist Sound Moved | `playlist_sound_moved` | — | Implemented |
| Playlist Duration Set | `playlist_duration_set` | `sound_id: String`, `duration_minutes: Int/String` | Implemented |

**Files:** `PlaylistView.swift`, `AddToPlaylistSheet`

---

### 4.14 Import / Custom Sounds

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Import Sound Tapped | `import_sound_tapped` | — | Implemented |
| Sound Imported | `sound_imported` | `sound_name: String`, `category: String`, `file_type: String` | Implemented |
| Sound Import Failed | `sound_import_failed` | `error: String` | Implemented |
| Custom Sound Played | `custom_sound_played` | `sound_name: String`, `category: String` | Implemented |
| Custom Sound Deleted | `custom_sound_deleted` | `sound_name: String` | Implemented |

**File:** `ImportSoundView.swift`

---

### 4.15 Premium / Purchases

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Premium Sheet Viewed | `premium_sheet_viewed` | `source: String` (which screen triggered it) | Implemented |
| Premium Purchase Tapped | `premium_purchase_tapped` | — | Implemented |
| Premium Purchase Completed | `premium_purchase_completed` | — | Implemented |
| Premium Purchase Failed | `premium_purchase_failed` | `error: String` | Implemented |
| Premium Purchase Cancelled | `premium_purchase_cancelled` | — | Defined |
| Restore Purchases Tapped | `restore_purchases_tapped` | — | Implemented |
| Restore Purchases Completed | `restore_purchases_completed` | `is_premium: Bool` | Defined |
| Premium Locked Content Tapped | `premium_locked_content_tapped` | `content_id: String`, `content_type: String` | Defined |

**Files:** `PremiumUpgradeView.swift`, `StoreManager.swift`, `MoreView.swift`

---

### 4.16 Settings

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| App Icon Changed | `app_icon_changed` | `icon_name: String` | Implemented |
| Live Activity Toggled | `live_activity_toggled` | `enabled: Bool` | Implemented |
| Fade Duration Changed | `fade_duration_changed` | `duration: Double` | Implemented |

**Files:** `AppIconPicker.swift`, `MoreView.swift`

---

### 4.17 About / Share

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Rate App Tapped | `rate_app_tapped` | — | Implemented |
| Share App Tapped | `share_app_tapped` | — | Implemented |
| Privacy Policy Tapped | `privacy_policy_tapped` | — | Implemented |

**File:** `MoreView.swift`

---

### 4.18 Live Activity

| Event | Key | Properties | Status |
|-------|-----|------------|--------|
| Live Activity Started | `live_activity_started` | `content_type: String` (sound/mix), `sound_name/mix_name: String` | Implemented |
| Live Activity Ended | `live_activity_ended` | — | Implemented |

**File:** `LiveActivityManager.swift`

---

## 5. Implementation Status Summary

| Category | Total Events | Implemented | Defined Only | Coverage |
|----------|-------------|-------------|--------------|----------|
| App Lifecycle | 3 | 3 | 0 | 100% |
| Onboarding | 4 | 4 | 0 | 100% |
| Navigation | 4 | 3 | 1 | 75% |
| Sound Playback | 9 | 9 | 0 | 100% |
| Mix Playback | 4 | 4 | 0 | 100% |
| Mix Management | 8 | 4 | 4 | 50% |
| Favorites | 2 | 2 | 0 | 100% |
| Discover & Browse | 4 | 4 | 0 | 100% |
| Now Playing | 5 | 4 | 1 | 80% |
| Sleep Timer | 7 | 5 | 2 | 71% |
| Sleep Clock | 2 | 2 | 0 | 100% |
| Sleep Log | 4 | 4 | 0 | 100% |
| Playlist | 8 | 8 | 0 | 100% |
| Import / Custom | 5 | 5 | 0 | 100% |
| Premium / Purchases | 8 | 6 | 2 | 75% |
| Settings | 3 | 3 | 0 | 100% |
| About / Share | 3 | 3 | 0 | 100% |
| Live Activity | 2 | 2 | 0 | 100% |
| **TOTAL** | **85** | **75** | **10** | **88%** |

### Remaining Defined-Only Events (Not Yet Wired)

These events are defined in the `AnalyticsManager.Event` enum but don't have `.track()` calls yet. They are either edge cases, system-controlled, or require future feature work:

| Event | Reason |
|-------|--------|
| `deep_link_opened` | Deep link handling not yet implemented |
| `airplay_tapped` | System-provided AirPlay route picker, no tap hook available |
| `alarm_toggled` | Alarm feature in sleep timer not fully wired |
| `alarm_time_set` | Alarm feature in sleep timer not fully wired |
| `mix_edited` | Mix editing flow not yet implemented |
| `mix_unfavorited` | Mix unfavorite action not yet surfaced in UI |
| `mix_preview_stopped` | Preview auto-stops, no explicit user action |
| `curated_mix_played` | Curated mixes played via `mix_played` with name |
| `premium_purchase_cancelled` | StoreKit doesn't expose cancel as a distinct event |
| `restore_purchases_completed` | Restore result inferred from `isPremium` state change |

---

## 6. Backend Integration Guide

The `AnalyticsManager.send(event:properties:)` method is the sole integration point. When adding a backend, modify only this method.

### Firebase Analytics

```swift
import FirebaseAnalytics

private func send(event: String, properties: [String: Any]?) {
    Analytics.logEvent(event, parameters: properties as? [String: NSObject])
}
```

### Mixpanel

```swift
import Mixpanel

private func send(event: String, properties: [String: Any]?) {
    Mixpanel.mainInstance().track(event: event, properties: properties as? Properties)
}
```

### Amplitude

```swift
import AmplitudeSwift

private func send(event: String, properties: [String: Any]?) {
    Amplitude.instance().track(eventType: event, eventProperties: properties)
}
```

### PostHog

```swift
import PostHog

private func send(event: String, properties: [String: Any]?) {
    PostHogSDK.shared.capture(event, properties: properties)
}
```

### Multiple Backends (Fan-out)

```swift
private func send(event: String, properties: [String: Any]?) {
    // Firebase for crash/event correlation
    Analytics.logEvent(event, parameters: properties as? [String: NSObject])
    // Mixpanel for funnel analysis
    Mixpanel.mainInstance().track(event: event, properties: properties as? Properties)
}
```

---

## 7. Future Tracking Wishlist

Events not yet defined in the enum but worth considering for future releases.

### User Engagement Metrics

| Event | Key | Properties | Priority |
|-------|-----|------------|----------|
| Session Duration | `session_duration` | `duration_seconds: Int`, `sounds_played: Int` | High |
| Daily Active Use | `daily_active` | `day_streak: Int` | High |
| First Sound Played | `first_sound_played` | `sound_id: String`, `time_since_install: Int` | Medium |
| Return After Lapse | `user_returned` | `days_since_last_use: Int` | Medium |

### Content Impressions

| Event | Key | Properties | Priority |
|-------|-----|------------|----------|
| Sound Card Impression | `sound_card_impression` | `sound_id: String`, `position: Int`, `screen: String` | High |
| Scene Card Impression | `scene_card_impression` | `scene_name: String`, `position: Int` | Medium |
| Bento Grid Loaded | `bento_grid_loaded` | `card_count: Int` | Low |
| Featured Section Viewed | `featured_section_viewed` | `section_name: String` | Medium |

### Audio Output

| Event | Key | Properties | Priority |
|-------|-----|------------|----------|
| Audio Route Changed | `audio_route_changed` | `route_type: String` (speaker/headphones/bluetooth/airplay) | Medium |
| AirPlay Device Selected | `airplay_device_selected` | `device_name: String` | Low |

### Error & Performance

| Event | Key | Properties | Priority |
|-------|-----|------------|----------|
| Audio Engine Error | `audio_engine_error` | `error: String`, `sound_id: String` | High |
| Audio File Load Failed | `audio_file_load_failed` | `file_name: String`, `error: String` | High |
| Live Activity Failed | `live_activity_failed` | `error: String` | Medium |
| App Crash Recovery | `app_crash_recovery` | `last_event: String` | Medium |

### Funnel Analysis

| Event | Key | Properties | Priority |
|-------|-----|------------|----------|
| Premium Paywall Shown | `premium_paywall_shown` | `trigger: String`, `screen: String` | High |
| Premium Paywall Dismissed | `premium_paywall_dismissed` | `trigger: String`, `time_viewed_seconds: Int` | High |
| Onboarding Drop-off | `onboarding_dropoff` | `last_page: Int` | High |
| Mix Creation Abandoned | `mix_creation_abandoned` | `step: String`, `component_count: Int` | Medium |

### A/B Testing Support

| Event | Key | Properties | Priority |
|-------|-----|------------|----------|
| Experiment Exposed | `experiment_exposed` | `experiment_id: String`, `variant: String` | High |
| Experiment Converted | `experiment_converted` | `experiment_id: String`, `variant: String` | High |

### User Properties (Set Once / Incrementally)

These are not events but user-level properties to set on analytics profiles.

| Property | Key | Type | When to Set |
|----------|-----|------|-------------|
| Is Premium | `is_premium` | Bool | On purchase/restore |
| Total Sounds Played | `total_sounds_played` | Int | Increment on each play |
| Total Mixes Created | `total_mixes_created` | Int | Increment on mix creation |
| Favorite Count | `favorite_count` | Int | On favorite/unfavorite |
| App Version | `app_version` | String | On launch |
| Install Date | `install_date` | Date | First launch |
| Days Since Install | `days_since_install` | Int | On each session |
| Preferred Category | `preferred_category` | String | Calculated from plays |
| Custom Sounds Count | `custom_sounds_count` | Int | On import/delete |
| Onboarding Completed | `onboarding_completed` | Bool | After onboarding |

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-04-15 | Initial FD created with 85 events defined, 75 implemented (88% coverage) | — |
| 2026-04-15 | Wired up missing tracking: onboarding, now playing, playlist duration, sleep sessions, live activity, app shortcuts | — |
