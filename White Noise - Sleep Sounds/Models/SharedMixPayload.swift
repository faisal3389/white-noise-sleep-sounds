import Foundation

// Compact URL-safe encoding for a shareable mix.
//
// Shape: whitenoise://mix?v=1&n=<name>&c=<id1:vol,id2:vol,...>
// Volume is encoded as an integer 0-100 to keep URLs short and readable.
struct SharedMixPayload: Equatable, Identifiable {
    static let schemeHost = "mix"
    static let version = "1"

    let id = UUID()
    var name: String
    var components: [MixComponent]

    init(name: String, components: [MixComponent]) {
        self.name = name
        self.components = components
    }

    init?(mix: SoundMix) {
        guard !mix.components.isEmpty else { return nil }
        self.name = mix.name
        self.components = mix.components
    }

    func toURL() -> URL? {
        var comps = URLComponents()
        comps.scheme = "whitenoise"
        comps.host = Self.schemeHost

        let encodedComponents = components
            .map { "\($0.soundId):\(Int(($0.volume * 100).rounded()))" }
            .joined(separator: ",")

        comps.queryItems = [
            URLQueryItem(name: "v", value: Self.version),
            URLQueryItem(name: "n", value: name),
            URLQueryItem(name: "c", value: encodedComponents)
        ]
        return comps.url
    }

    static func decode(from url: URL) -> SharedMixPayload? {
        guard url.scheme == "whitenoise", url.host == schemeHost else { return nil }
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = comps?.queryItems ?? []
        let version = items.first(where: { $0.name == "v" })?.value
        guard version == Self.version else { return nil }

        let rawName = items.first(where: { $0.name == "n" })?.value ?? ""
        let rawComponents = items.first(where: { $0.name == "c" })?.value ?? ""
        guard !rawComponents.isEmpty else { return nil }

        // Only accept sound IDs that exist in the current library — keeps the
        // feature forward-compatible when we retire or rename sounds.
        let validIds = Set(SoundLibrary.allSounds.map { $0.id })

        let parsed: [MixComponent] = rawComponents
            .split(separator: ",")
            .compactMap { pair in
                let parts = pair.split(separator: ":", maxSplits: 1)
                guard parts.count == 2 else { return nil }
                let id = String(parts[0])
                guard validIds.contains(id) else { return nil }
                let volInt = Int(parts[1]) ?? 70
                let clamped = max(0, min(100, volInt))
                return MixComponent(soundId: id, volume: Float(clamped) / 100.0)
            }
        guard !parsed.isEmpty else { return nil }

        let name = rawName.isEmpty ? "Shared Mix" : rawName
        return SharedMixPayload(name: name, components: parsed)
    }

    func toSoundMix() -> SoundMix {
        SoundMix(name: name, description: "Shared mix", components: components)
    }
}
