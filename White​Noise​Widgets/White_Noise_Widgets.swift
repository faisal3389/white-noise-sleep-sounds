import WidgetKit
import SwiftUI
import UIKit

// MARK: - Shared Data

struct WidgetSoundInfo {
    let id: String
    let name: String
    let iconName: String
}

/// Quick-play sound catalog matching SoundLibrary (subset for widget display)
enum WidgetSoundCatalog {
    static let all: [String: WidgetSoundInfo] = [
        "white_noise": WidgetSoundInfo(id: "white_noise", name: "White Noise", iconName: "waveform"),
        "pink_noise": WidgetSoundInfo(id: "pink_noise", name: "Pink Noise", iconName: "waveform"),
        "brown_noise": WidgetSoundInfo(id: "brown_noise", name: "Brown Noise", iconName: "waveform"),
        "blue_noise": WidgetSoundInfo(id: "blue_noise", name: "Blue Noise", iconName: "waveform"),
        "light_rain": WidgetSoundInfo(id: "light_rain", name: "Light Rain", iconName: "cloud.rain"),
        "heavy_rain": WidgetSoundInfo(id: "heavy_rain", name: "Heavy Rain", iconName: "cloud.heavyrain"),
        "forest": WidgetSoundInfo(id: "forest", name: "Forest", iconName: "tree"),
        "birds": WidgetSoundInfo(id: "birds", name: "Birds", iconName: "bird"),
        "ocean_waves": WidgetSoundInfo(id: "ocean_waves", name: "Ocean Waves", iconName: "water.waves"),
        "campfire": WidgetSoundInfo(id: "campfire", name: "Campfire", iconName: "flame"),
        "fan": WidgetSoundInfo(id: "fan", name: "Fan", iconName: "fan"),
        "river": WidgetSoundInfo(id: "river", name: "River", iconName: "drop"),
        "cafe": WidgetSoundInfo(id: "cafe", name: "Cafe", iconName: "cup.and.saucer"),
        "fireplace": WidgetSoundInfo(id: "fireplace", name: "Fireplace", iconName: "fireplace"),
        "city_traffic": WidgetSoundInfo(id: "city_traffic", name: "City Traffic", iconName: "car"),
        "ac": WidgetSoundInfo(id: "ac", name: "Air Conditioner", iconName: "air.conditioner.horizontal"),
    ]

    static let defaultQuickPlay = ["white_noise", "heavy_rain", "ocean_waves"]

    static func info(for id: String) -> WidgetSoundInfo {
        all[id] ?? WidgetSoundInfo(id: id, name: id.replacingOccurrences(of: "_", with: " ").capitalized, iconName: "waveform")
    }

    static func iconName(for id: String) -> String {
        all[id]?.iconName ?? "waveform"
    }
}

// MARK: - Timeline Entry

struct WhiteNoiseEntry: TimelineEntry {
    let date: Date
    let soundName: String?
    let soundId: String?
    let backgroundImage: String?
    let isPlaying: Bool
    let favoriteSoundIds: [String]
    let lastPlayedSoundId: String?

    static var placeholder: WhiteNoiseEntry {
        WhiteNoiseEntry(
            date: .now,
            soundName: "White Noise",
            soundId: "white_noise",
            backgroundImage: "bg_white_noise",
            isPlaying: true,
            favoriteSoundIds: WidgetSoundCatalog.defaultQuickPlay,
            lastPlayedSoundId: "white_noise"
        )
    }

    static var empty: WhiteNoiseEntry {
        WhiteNoiseEntry(
            date: .now,
            soundName: nil,
            soundId: nil,
            backgroundImage: nil,
            isPlaying: false,
            favoriteSoundIds: WidgetSoundCatalog.defaultQuickPlay,
            lastPlayedSoundId: nil
        )
    }
}

// MARK: - Timeline Provider

struct WhiteNoiseProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.com.zalgo.whitenoise")

    func placeholder(in context: Context) -> WhiteNoiseEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WhiteNoiseEntry) -> Void) {
        completion(context.isPreview ? .placeholder : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WhiteNoiseEntry>) -> Void) {
        let entry = currentEntry()
        completion(Timeline(entries: [entry], policy: .atEnd))
    }

    private func currentEntry() -> WhiteNoiseEntry {
        let soundId = defaults?.string(forKey: "widget_currentSoundId")
        let soundName = defaults?.string(forKey: "widget_currentSoundName")
        let bgImage = defaults?.string(forKey: "widget_currentBackgroundImage")
        let isPlaying = defaults?.bool(forKey: "widget_isPlaying") ?? false
        let favorites = defaults?.stringArray(forKey: "widget_favoriteSoundIds") ?? WidgetSoundCatalog.defaultQuickPlay
        let lastPlayedSoundId = defaults?.string(forKey: "widget_lastPlayedSoundId")
        let lastPlayedBgImage = defaults?.string(forKey: "widget_lastPlayedBackgroundImage")

        // Use last played background as fallback, then default to white noise
        let effectiveBgImage = bgImage ?? lastPlayedBgImage ?? "bg_white_noise"

        return WhiteNoiseEntry(
            date: .now,
            soundName: soundName,
            soundId: soundId,
            backgroundImage: effectiveBgImage,
            isPlaying: isPlaying,
            favoriteSoundIds: favorites.isEmpty ? WidgetSoundCatalog.defaultQuickPlay : favorites,
            lastPlayedSoundId: lastPlayedSoundId
        )
    }
}

// MARK: - Widget Colors

enum WidgetColors {
    static let background = Color(red: 0.05, green: 0.06, blue: 0.10)
    static let surface = Color(red: 0.10, green: 0.11, blue: 0.18)
    static let accent = Color(red: 0.49, green: 0.42, blue: 0.94)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
}

// MARK: - Widget Background Helper

struct WidgetBackgroundView: View {
    let backgroundImage: String?
    let overlayOpacity: Double

    var body: some View {
        if let bgImage = backgroundImage, UIImage(named: bgImage) != nil {
            Image(bgImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(overlayOpacity))
        } else {
            LinearGradient(
                colors: [WidgetColors.background, WidgetColors.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Small Widget (1x1) - Play/Pause + Thumbnail

struct SmallWidgetView: View {
    let entry: WhiteNoiseEntry

    var body: some View {
        let deepLink = entry.isPlaying
            ? URL(string: "whitenoise://toggle")!
            : URL(string: "whitenoise://nowplaying")!

        VStack(spacing: 8) {
            Image(systemName: entry.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(WidgetColors.accent)

            if let name = entry.soundName {
                Text(name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(WidgetColors.textPrimary)
                    .lineLimit(1)
            } else {
                Text("White Noise")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(WidgetColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .widgetURL(deepLink)
    }
}

struct NowPlayingSmallWidget: Widget {
    let kind = "NowPlayingSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WhiteNoiseProvider()) { entry in
            if #available(iOS 17.0, *) {
                SmallWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetBackgroundView(backgroundImage: entry.backgroundImage, overlayOpacity: 0.5)
                    }
            } else {
                ZStack {
                    WidgetBackgroundView(backgroundImage: entry.backgroundImage, overlayOpacity: 0.5)
                    SmallWidgetView(entry: entry)
                }
            }
        }
        .configurationDisplayName("Quick Play")
        .description("Tap to play or open White Noise.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Medium Widget (2x2) - Current Sound + Quick Play Buttons

struct MediumWidgetView: View {
    let entry: WhiteNoiseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "waveform")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WidgetColors.accent)
                Text("White Noise")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.accent)
                Spacer()
                if entry.isPlaying {
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(WidgetColors.accent)
                                .frame(width: 3, height: CGFloat([8, 12, 6][i]))
                        }
                    }
                }
            }

            Spacer()

            if let name = entry.soundName {
                Link(destination: URL(string: "whitenoise://nowplaying")!) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.isPlaying ? "Now Playing" : "Paused")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(WidgetColors.textSecondary)
                            .textCase(.uppercase)
                        Text(name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(WidgetColors.textPrimary)
                            .lineLimit(1)
                    }
                }
            } else {
                Text("Tap a sound to play")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WidgetColors.textSecondary)
            }

            HStack(spacing: 8) {
                ForEach(entry.favoriteSoundIds.prefix(3), id: \.self) { soundId in
                    let info = WidgetSoundCatalog.info(for: soundId)
                    let isActive = soundId == (entry.soundId ?? entry.lastPlayedSoundId)
                    Link(destination: URL(string: "whitenoise://play/\(soundId)")!) {
                        HStack(spacing: 4) {
                            Image(systemName: info.iconName)
                                .font(.system(size: 10, weight: .bold))
                            Text(info.name)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                        }
                        .foregroundStyle(isActive ? .white : WidgetColors.textPrimary.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isActive ? WidgetColors.accent : Color.white.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

struct NowPlayingMediumWidget: Widget {
    let kind = "NowPlayingMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WhiteNoiseProvider()) { entry in
            if #available(iOS 17.0, *) {
                MediumWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetBackgroundView(backgroundImage: entry.backgroundImage, overlayOpacity: 0.55)
                    }
            } else {
                ZStack {
                    WidgetBackgroundView(backgroundImage: entry.backgroundImage, overlayOpacity: 0.55)
                    MediumWidgetView(entry: entry)
                        .padding(16)
                }
            }
        }
        .configurationDisplayName("Now Playing")
        .description("See what's playing and quickly start your favorite sounds.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Lock Screen Circular Widget

struct LockScreenCircularView: View {
    let entry: WhiteNoiseEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: entry.isPlaying ? "waveform" : "waveform")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(entry.isPlaying ? .white : .white.opacity(0.6))
        }
        .widgetURL(URL(string: "whitenoise://nowplaying")!)
    }
}

struct LockScreenCircularWidget: Widget {
    let kind = "LockScreenCircularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WhiteNoiseProvider()) { entry in
            if #available(iOS 17.0, *) {
                LockScreenCircularView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                LockScreenCircularView(entry: entry)
            }
        }
        .configurationDisplayName("White Noise")
        .description("Tap to open White Noise.")
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - Lock Screen Rectangular Widget

struct LockScreenRectangularView: View {
    let entry: WhiteNoiseEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                if let name = entry.soundName {
                    Text(name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(entry.isPlaying ? "Playing" : "Paused")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                } else {
                    Text("White Noise")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Tap to open")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()
        }
        .widgetURL(URL(string: "whitenoise://nowplaying")!)
    }
}

struct LockScreenRectangularWidget: Widget {
    let kind = "LockScreenRectangularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WhiteNoiseProvider()) { entry in
            if #available(iOS 17.0, *) {
                LockScreenRectangularView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                LockScreenRectangularView(entry: entry)
            }
        }
        .configurationDisplayName("Now Playing")
        .description("See current sound and playback status.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    NowPlayingSmallWidget()
} timeline: {
    WhiteNoiseEntry.placeholder
    WhiteNoiseEntry.empty
}

#Preview("Medium", as: .systemMedium) {
    NowPlayingMediumWidget()
} timeline: {
    WhiteNoiseEntry.placeholder
    WhiteNoiseEntry.empty
}
