import Foundation

struct MixComponent: Identifiable, Codable, Hashable {
    let id: UUID
    let soundId: String
    var volume: Float

    init(id: UUID = UUID(), soundId: String, volume: Float = 0.7) {
        self.id = id
        self.soundId = soundId
        self.volume = min(max(volume, 0.0), 1.0)
    }

    var sound: Sound? {
        SoundLibrary.allSounds.first { $0.id == soundId }
    }
}

struct SoundMix: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var components: [MixComponent]
    var isFavorite: Bool
    let createdAt: Date

    init(id: UUID = UUID(), name: String, description: String = "", components: [MixComponent], isFavorite: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.components = components
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }

    var backgroundImage: String {
        components.first?.sound?.backgroundImage ?? "bg_white_noise"
    }

    var componentNames: String {
        components.compactMap { $0.sound?.name }.joined(separator: " + ")
    }
}
