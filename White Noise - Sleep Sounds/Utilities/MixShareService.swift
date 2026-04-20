import SwiftUI
import UIKit

enum MixShareService {
    static let appStoreURL = URL(string: "https://apps.apple.com/us/app/white-noise-sleep-sounds/id6762322017")!

    static func shareMessage(for payload: SharedMixPayload) -> String {
        let names = payload.components.compactMap { $0.sound?.name }.joined(separator: " + ")
        let body = names.isEmpty ? payload.name : "\(payload.name) — \(names)"
        return "🌙 My sleep mix on White Noise: \(body)\n\nGet the app: \(appStoreURL.absoluteString)"
    }

    static func activityItems(for payload: SharedMixPayload) -> [Any] {
        var items: [Any] = [shareMessage(for: payload)]
        if let deepLink = payload.toURL() {
            items.append(deepLink)
        }
        if let image = renderPreview(for: payload) {
            items.append(image)
        }
        return items
    }

    // Renders a 1080x1350 (4:5) share card — the best-performing size for
    // iMessage preview, Instagram, and Twitter/X rich embeds.
    static func renderPreview(for payload: SharedMixPayload) -> UIImage? {
        let size = CGSize(width: 1080, height: 1350)
        let mix = payload.toSoundMix()
        let renderer = ImageRenderer(content: MixSharePreviewCard(mix: mix).frame(width: size.width, height: size.height))
        renderer.scale = 1.0
        return renderer.uiImage
    }
}

private struct MixSharePreviewCard: View {
    let mix: SoundMix

    var body: some View {
        ZStack {
            // Background collage from first component's art
            if let bg = mix.components.first?.sound?.backgroundImage {
                Image(bg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.black
            }

            LinearGradient(
                colors: [.black.opacity(0.1), .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 28) {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 84, height: 84)
                        .overlay {
                            Image(systemName: "waveform")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("White Noise")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Sleep Sounds")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Try my mix")
                        .font(.system(size: 42, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))

                    Text(mix.name)
                        .font(.system(size: 88, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(mix.components.prefix(5)) { component in
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(.white.opacity(0.9))
                                    .frame(width: 14, height: 14)
                                Text(component.sound?.name ?? component.soundId)
                                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()

                Text("whitenoise • sleep sounds")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(64)
        }
        .frame(width: 1080, height: 1350)
        .clipped()
    }
}

struct MixShareSheet: UIViewControllerRepresentable {
    let payload: SharedMixPayload
    let onComplete: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let items = MixShareService.activityItems(for: payload)
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete(completed)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
