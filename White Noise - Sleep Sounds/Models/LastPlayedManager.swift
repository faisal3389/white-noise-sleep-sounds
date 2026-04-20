import Foundation

enum LastPlayedContext: Codable, Equatable {
    case sound(id: String)
    case mix(id: UUID)
}

/// Remembers the most recent playback context so returning users can resume
/// with a single tap from Home.
@Observable
final class LastPlayedManager {
    private static let storageKey = "last_played_context_v1"

    private(set) var context: LastPlayedContext?

    init() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode(LastPlayedContext.self, from: data) else { return }
        context = decoded
    }

    func recordSound(_ sound: Sound) {
        context = .sound(id: sound.id)
        persist()
    }

    func recordMix(_ mix: SoundMix) {
        context = .mix(id: mix.id)
        persist()
    }

    func clear() {
        context = nil
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
    }

    // MARK: - Resolution

    func resolveSound() -> Sound? {
        guard case .sound(let id) = context else { return nil }
        return SoundLibrary.allSounds.first { $0.id == id }
    }

    func resolveMix(from mixes: [SoundMix]) -> SoundMix? {
        guard case .mix(let id) = context else { return nil }
        if let saved = mixes.first(where: { $0.id == id }) { return saved }
        return MixesManager.curatedMixes.first { $0.id == id }
    }

    private func persist() {
        guard let context, let data = try? JSONEncoder().encode(context) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
