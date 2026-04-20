import SwiftUI

struct MixImportSheet: View {
    let payload: SharedMixPayload
    @Bindable var player: AudioPlayerViewModel
    var mixesManager: MixesManager
    @Environment(\.dismiss) private var dismiss

    @State private var saved = false

    private var mix: SoundMix { payload.toSoundMix() }
    private var componentNames: String {
        mix.components.compactMap { $0.sound?.name }.joined(separator: " + ")
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                artwork
                    .frame(height: 280)
                    .clipped()
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [Color.appBackground, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 80)
                    }

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Someone shared a mix")
                            .font(.system(size: 13, weight: .semibold))
                            .tracking(2)
                            .foregroundStyle(Color.appAccent)

                        Text(mix.name)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        if !componentNames.isEmpty {
                            Text(componentNames)
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }

                    Divider().overlay(Color.white.opacity(0.1))

                    VStack(spacing: 10) {
                        ForEach(mix.components) { component in
                            componentRow(component)
                        }
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        Button {
                            AnalyticsManager.shared.track(.mixImportPlayed, properties: [
                                "component_count": mix.components.count
                            ])
                            if !saved {
                                mixesManager.saveMix(mix)
                                saved = true
                            }
                            player.playMix(mix: mix, source: "shared_import")
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("Play this mix")
                            }
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button {
                            AnalyticsManager.shared.track(.mixImportSaved, properties: [
                                "component_count": mix.components.count
                            ])
                            mixesManager.saveMix(mix)
                            saved = true
                            dismiss()
                        } label: {
                            Text(saved ? "Saved to your mixes" : "Save to my mixes")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(saved)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            AnalyticsManager.shared.track(.mixImportOpened, properties: [
                "component_count": mix.components.count
            ])
        }
        .onDisappear {
            if !saved {
                AnalyticsManager.shared.track(.mixImportDismissed)
            }
        }
    }

    @ViewBuilder
    private var artwork: some View {
        GeometryReader { geo in
            if let bg = mix.components.first?.sound?.backgroundImage {
                Image(bg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.05), .black.opacity(0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Color.appSurface
            }
        }
    }

    private func componentRow(_ component: MixComponent) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.08))
                .frame(width: 40, height: 40)
                .overlay {
                    if let thumb = component.sound?.thumbnailImage {
                        Image(thumb)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "waveform")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

            Text(component.sound?.name ?? component.soundId)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            Text("\(Int((component.volume * 100).rounded()))%")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.vertical, 6)
    }
}
