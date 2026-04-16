import Foundation

enum SoundCategory: String, CaseIterable, Identifiable {
    case noise = "Noise"
    case rain = "Rain"
    case nature = "Nature"
    case urban = "Urban"
    case machine = "Machine"
    case fire = "Fire"
    case water = "Water"
    case premium = "Premium"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .noise: return "waveform"
        case .rain: return "cloud.rain.fill"
        case .nature: return "leaf.fill"
        case .urban: return "building.2.fill"
        case .machine: return "fan.fill"
        case .fire: return "flame.fill"
        case .water: return "drop.fill"
        case .premium: return "star.fill"
        }
    }
}

struct Sound: Identifiable, Hashable {
    let id: String
    let name: String
    let category: SoundCategory
    let fileName: String
    let backgroundImage: String
    let isPremium: Bool
    let isGenerated: Bool

    var thumbnailImage: String {
        "thumb_" + id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Sound, rhs: Sound) -> Bool {
        lhs.id == rhs.id
    }
}
