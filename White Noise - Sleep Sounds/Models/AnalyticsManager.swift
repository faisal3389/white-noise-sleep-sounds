import Foundation
import os
import FirebaseAnalytics

/// Lightweight analytics service that tracks all user actions.
/// Events are logged locally and can be forwarded to any analytics backend
/// (Firebase, Mixpanel, Amplitude, etc.) by implementing the `send` method.
@Observable
final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WhiteNoise", category: "Analytics")

    private init() {}

    // MARK: - Event Definitions

    enum Event: String {
        // App lifecycle
        case appLaunched = "app_launched"
        case appBecameActive = "app_became_active"
        case appEnteredBackground = "app_entered_background"

        // Onboarding
        case onboardingStarted = "onboarding_started"
        case onboardingPageViewed = "onboarding_page_viewed"
        case onboardingCompleted = "onboarding_completed"
        case onboardingSkipped = "onboarding_skipped"

        // Navigation
        case tabSelected = "tab_selected"
        case screenViewed = "screen_viewed"
        case deepLinkOpened = "deep_link_opened"
        case shortcutUsed = "shortcut_used"

        // Sound playback
        case soundPlayed = "sound_played"
        case soundPaused = "sound_paused"
        case soundResumed = "sound_resumed"
        case soundStopped = "sound_stopped"
        case soundNext = "sound_next"
        case soundPrevious = "sound_previous"
        case volumeChanged = "volume_changed"
        case shuffleToggled = "shuffle_toggled"
        case loopModeChanged = "loop_mode_changed"

        // Mix playback
        case mixPlayed = "mix_played"
        case mixComponentVolumeChanged = "mix_component_volume_changed"
        case mixNextPlayed = "mix_next_played"
        case mixPreviousPlayed = "mix_previous_played"

        // Mix management
        case createMixTapped = "create_mix_tapped"
        case mixCreated = "mix_created"
        case mixEdited = "mix_edited"
        case mixDeleted = "mix_deleted"
        case mixFavorited = "mix_favorited"
        case mixUnfavorited = "mix_unfavorited"
        case mixPreviewed = "mix_preview_started"
        case mixPreviewStopped = "mix_preview_stopped"
        case curatedMixPlayed = "curated_mix_played"
        case curatedMixPreviewEnded = "curated_mix_preview_ended"

        // Mix sharing
        case mixShareTapped = "mix_share_tapped"
        case mixShared = "mix_shared"
        case mixShareCancelled = "mix_share_cancelled"
        case mixImportOpened = "mix_import_opened"
        case mixImportPlayed = "mix_import_played"
        case mixImportSaved = "mix_import_saved"
        case mixImportDismissed = "mix_import_dismissed"

        // Favorites
        case soundFavorited = "sound_favorited"
        case soundUnfavorited = "sound_unfavorited"

        // Discover / Browse
        case searchPerformed = "search_performed"
        case categorySelected = "category_selected"
        case categoryBrowsed = "category_browsed"
        case sceneViewed = "scene_viewed"

        // Now Playing
        case nowPlayingViewed = "now_playing_viewed"
        case miniPlayerTapped = "mini_player_tapped"
        case miniPlayerPlayPause = "mini_player_play_pause"
        case mixerSheetOpened = "mixer_sheet_opened"
        case airplayTapped = "airplay_tapped"

        // Sleep timer
        case timerStartedPreset = "timer_started_preset"
        case timerStartedCustom = "timer_started_custom"
        case timerCancelled = "timer_cancelled"
        case timerCompleted = "timer_completed"
        case fadeOutToggled = "fade_out_toggled"
        case alarmToggled = "alarm_toggled"
        case alarmTimeSet = "alarm_time_set"

        // Sleep clock
        case sleepClockOpened = "sleep_clock_opened"
        case sleepClockClosed = "sleep_clock_closed"

        // Sleep log
        case sleepLogViewed = "sleep_log_viewed"
        case sleepSessionStarted = "sleep_session_started"
        case sleepSessionEnded = "sleep_session_ended"
        case sleepLogEntryDeleted = "sleep_log_entry_deleted"

        // Playlist
        case playlistViewed = "playlist_viewed"
        case playlistStarted = "playlist_started"
        case playlistStopped = "playlist_stopped"
        case playlistCleared = "playlist_cleared"
        case playlistSoundAdded = "playlist_sound_added"
        case playlistSoundRemoved = "playlist_sound_removed"
        case playlistSoundMoved = "playlist_sound_moved"
        case playlistDurationSet = "playlist_duration_set"

        // Import / Custom sounds
        case importSoundTapped = "import_sound_tapped"
        case soundImported = "sound_imported"
        case soundImportFailed = "sound_import_failed"
        case customSoundPlayed = "custom_sound_played"
        case customSoundDeleted = "custom_sound_deleted"

        // Premium / Purchases
        case premiumSheetViewed = "premium_sheet_viewed"
        case paywallDismissed = "paywall_dismissed"
        case premiumPurchaseTapped = "premium_purchase_tapped"
        case premiumPurchaseCompleted = "premium_purchase_completed"
        case premiumPurchaseFailed = "premium_purchase_failed"
        case premiumPurchaseCancelled = "premium_purchase_cancelled"
        case restorePurchasesTapped = "restore_purchases_tapped"
        case restorePurchasesCompleted = "restore_purchases_completed"
        case premiumLockedContentTapped = "premium_locked_content_tapped"

        // Settings
        case appIconChanged = "app_icon_changed"
        case liveActivityToggled = "live_activity_toggled"
        case fadeDurationChanged = "fade_duration_changed"
        case siriSettingsOpened = "siri_settings_opened"
        case bedtimeReminderToggled = "bedtime_reminder_toggled"
        case bedtimeReminderTimeChanged = "bedtime_reminder_time_changed"

        // About / Share
        case rateAppTapped = "rate_app_tapped"
        case shareAppTapped = "share_app_tapped"
        case privacyPolicyTapped = "privacy_policy_tapped"
        case ratePromptShown = "rate_prompt_shown"
        case ratePromptDismissed = "rate_prompt_dismissed"

        // Live Activity
        case liveActivityStarted = "live_activity_started"
        case liveActivityEnded = "live_activity_ended"

        // Widget
        case widgetTapped = "widget_tapped"
        case widgetQuickPlayTapped = "widget_quick_play_tapped"
        case widgetNowPlayingTapped = "widget_now_playing_tapped"
        case widgetToggleTapped = "widget_toggle_tapped"
    }

    // MARK: - Track

    func track(_ event: Event, properties: [String: Any]? = nil) {
        var logMessage = "[\(event.rawValue)]"
        if let properties {
            let desc = properties.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            logMessage += " {\(desc)}"
        }
        logger.info("\(logMessage)")

        // Forward to analytics backend
        send(event: event.rawValue, properties: properties)
    }

    // MARK: - Backend Integration Point

    private func send(event: String, properties: [String: Any]?) {
        Analytics.logEvent(event, parameters: properties)
    }
}
