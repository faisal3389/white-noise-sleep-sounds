import AppIntents
import Foundation

// MARK: - Sound Name Enum for Siri

enum SoundNameAppEnum: String, AppEnum {
    case whiteNoise = "white_noise"
    case pinkNoise = "pink_noise"
    case brownNoise = "brown_noise"
    case blueNoise = "blue_noise"
    case lightRain = "light_rain"
    case heavyRain = "heavy_rain"
    case forest = "forest"
    case birds = "birds"
    case ocean = "ocean_waves"
    case river = "river"
    case fan = "fan"
    case ac = "ac"
    case campfire = "campfire"
    case fireplace = "fireplace"
    case cityTraffic = "city_traffic"
    case cafe = "cafe"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Sound"

    static var caseDisplayRepresentations: [SoundNameAppEnum: DisplayRepresentation] = [
        .whiteNoise: "White Noise",
        .pinkNoise: "Pink Noise",
        .brownNoise: "Brown Noise",
        .blueNoise: "Blue Noise",
        .lightRain: "Light Rain",
        .heavyRain: "Heavy Rain",
        .forest: "Forest",
        .birds: "Birds Singing",
        .ocean: "Ocean Waves",
        .river: "River Stream",
        .fan: "Fan",
        .ac: "Air Conditioner",
        .campfire: "Campfire",
        .fireplace: "Fireplace",
        .cityTraffic: "City Traffic",
        .cafe: "Cafe Ambience",
    ]
}

// MARK: - Play Sound Intent

struct PlaySoundIntent: AppIntent {
    static var title: LocalizedStringResource = "Play Sound"
    static var description = IntentDescription("Play a white noise or sleep sound")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Sound")
    var sound: SoundNameAppEnum

    static var parameterSummary: some ParameterSummary {
        Summary("Play \(\.$sound)")
    }

    func perform() async throws -> some IntentResult {
        await AppShortcutAction.shared.setPendingAction(.playSound(sound.rawValue))
        return .result()
    }
}

// MARK: - Start Sleep Timer Intent

struct StartSleepTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Sleep Timer"
    static var description = IntentDescription("Start a sleep timer for 30 minutes")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await AppShortcutAction.shared.setPendingAction(.startTimer(30))
        return .result()
    }
}

// MARK: - Open Sleep Clock Intent

struct OpenSleepClockIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Sleep Clock"
    static var description = IntentDescription("Open the bedside sleep clock")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await AppShortcutAction.shared.setPendingAction(.openSleepClock)
        return .result()
    }
}

// MARK: - Toggle Playback Intent

struct TogglePlaybackIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Playback"
    static var description = IntentDescription("Play or pause the current sound")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await AppShortcutAction.shared.setPendingAction(.toggle)
        return .result()
    }
}

// MARK: - App Shortcuts Provider

struct WhiteNoiseShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PlaySoundIntent(),
            phrases: [
                "Play \(\.$sound) in \(.applicationName)",
                "Start \(\.$sound) in \(.applicationName)",
                "Play \(\.$sound) sound in \(.applicationName)"
            ],
            shortTitle: "Play Sound",
            systemImageName: "play.circle.fill"
        )
        AppShortcut(
            intent: StartSleepTimerIntent(),
            phrases: [
                "Start sleep timer in \(.applicationName)",
                "Set sleep timer in \(.applicationName)"
            ],
            shortTitle: "Sleep Timer",
            systemImageName: "moon.zzz.fill"
        )
        AppShortcut(
            intent: OpenSleepClockIntent(),
            phrases: [
                "Open sleep clock in \(.applicationName)",
                "Show bedside clock in \(.applicationName)"
            ],
            shortTitle: "Sleep Clock",
            systemImageName: "clock.fill"
        )
        AppShortcut(
            intent: TogglePlaybackIntent(),
            phrases: [
                "Toggle \(.applicationName)",
                "Pause \(.applicationName)"
            ],
            shortTitle: "Toggle Playback",
            systemImageName: "playpause.fill"
        )
    }
}

// MARK: - Shared Action Coordinator

@Observable
@MainActor
class AppShortcutAction {
    static let shared = AppShortcutAction()

    enum Action: Equatable {
        case playSound(String)
        case startTimer(Int)
        case openSleepClock
        case toggle
    }

    var pendingAction: Action?

    private init() {}

    func setPendingAction(_ action: Action) {
        pendingAction = action
    }
}
