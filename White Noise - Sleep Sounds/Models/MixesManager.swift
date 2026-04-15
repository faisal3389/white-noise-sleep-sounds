import Foundation

@Observable
class MixesManager {
    private static let storageKey = "saved_mixes"

    var mixes: [SoundMix] = []

    init() {
        loadMixes()
    }

    func saveMix(_ mix: SoundMix) {
        if let index = mixes.firstIndex(where: { $0.id == mix.id }) {
            mixes[index] = mix
        } else {
            mixes.insert(mix, at: 0)
        }
        persist()
    }

    func deleteMix(_ mix: SoundMix) {
        mixes.removeAll { $0.id == mix.id }
        persist()
    }

    func toggleFavorite(_ mix: SoundMix) {
        guard let index = mixes.firstIndex(where: { $0.id == mix.id }) else { return }
        mixes[index].isFavorite.toggle()
        persist()
    }

    func loadMixes() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([SoundMix].self, from: data) else {
            return
        }
        mixes = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(mixes) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    // MARK: - Curated Mixes

    static let curatedMixes: [SoundMix] = [
        SoundMix(
            name: "Rainy Forest",
            description: "Rain pattering through a lush forest canopy",
            components: [
                MixComponent(soundId: "light_rain", volume: 0.7),
                MixComponent(soundId: "forest", volume: 0.5),
                MixComponent(soundId: "birds", volume: 0.3)
            ]
        ),
        SoundMix(
            name: "Ocean Breeze",
            description: "Waves and wind for coastal serenity",
            components: [
                MixComponent(soundId: "ocean_waves", volume: 0.8),
                MixComponent(soundId: "wind", volume: 0.4)
            ]
        ),
        SoundMix(
            name: "Cozy Cabin",
            description: "Fireplace crackling with rain outside",
            components: [
                MixComponent(soundId: "fireplace", volume: 0.7),
                MixComponent(soundId: "heavy_rain", volume: 0.4),
                MixComponent(soundId: "wind", volume: 0.2)
            ]
        ),
    ]
}
