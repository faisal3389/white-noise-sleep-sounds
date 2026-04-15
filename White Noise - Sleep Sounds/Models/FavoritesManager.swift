import Foundation

@Observable
class FavoritesManager {
    private static let favoritesKey = "favorited_sound_ids"

    var favoritedIDs: Set<String> {
        didSet { save() }
    }

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.favoritesKey) ?? []
        self.favoritedIDs = Set(saved)
    }

    func isFavorite(_ sound: Sound) -> Bool {
        favoritedIDs.contains(sound.id)
    }

    func toggle(_ sound: Sound) {
        if favoritedIDs.contains(sound.id) {
            favoritedIDs.remove(sound.id)
        } else {
            favoritedIDs.insert(sound.id)
        }
    }

    private func save() {
        UserDefaults.standard.set(Array(favoritedIDs), forKey: Self.favoritesKey)
    }
}
