import SwiftUI

struct SoundRowView: View {
    let sound: Sound
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appSurface)
                    .frame(width: 50, height: 50)

                Image(systemName: iconForCategory(sound.category))
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))

                if sound.isPremium {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .offset(x: 16, y: 16)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(sound.name)
                    .font(.body)
                    .foregroundStyle(.white)

                Text(sound.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? Color.appAccent : .white.opacity(0.4))
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private func iconForCategory(_ category: SoundCategory) -> String {
        switch category {
        case .noise: return "waveform"
        case .rain: return "cloud.rain.fill"
        case .nature: return "leaf.fill"
        case .urban: return "building.2.fill"
        case .machine: return "gearshape.fill"
        case .fire: return "flame.fill"
        case .water: return "drop.fill"
        }
    }
}
