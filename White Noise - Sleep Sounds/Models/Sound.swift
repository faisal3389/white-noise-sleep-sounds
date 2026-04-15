import Foundation

enum SoundCategory: String, CaseIterable, Identifiable {
    case noise = "Noise"
    case rain = "Rain"
    case nature = "Nature"
    case urban = "Urban"
    case machine = "Machine"
    case fire = "Fire"
    case water = "Water"

    var id: String { rawValue }
}

struct Sound: Identifiable, Hashable {
    let id: String
    let name: String
    let category: SoundCategory
    let fileName: String
    let backgroundImage: String
    let isPremium: Bool
    let isGenerated: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Sound, rhs: Sound) -> Bool {
        lhs.id == rhs.id
    }
}
