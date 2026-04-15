import Foundation
import UniformTypeIdentifiers

struct CustomSound: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: String
    let fileName: String // file name in documents directory
    let importedAt: Date

    init(name: String, category: String, fileName: String) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.fileName = fileName
        self.importedAt = Date()
    }

    var fileURL: URL? {
        CustomSoundsManager.soundsDirectory?.appendingPathComponent(fileName)
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CustomSound, rhs: CustomSound) -> Bool { lhs.id == rhs.id }
}

@Observable
class CustomSoundsManager {
    private static let storageKey = "custom_sounds"

    var sounds: [CustomSound] = []

    static var soundsDirectory: URL? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let dir = docs?.appendingPathComponent("CustomSounds")
        if let dir, !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    init() {
        load()
    }

    static let supportedTypes: [UTType] = [.mp3, .mpeg4Audio, .wav, .aiff, .audio]

    func importSound(from sourceURL: URL, name: String, category: String) throws {
        guard sourceURL.startAccessingSecurityScopedResource() else {
            throw ImportError.accessDenied
        }
        defer { sourceURL.stopAccessingSecurityScopedResource() }

        guard let soundsDir = Self.soundsDirectory else {
            throw ImportError.directoryUnavailable
        }

        let ext = sourceURL.pathExtension
        let uniqueFileName = "\(UUID().uuidString).\(ext)"
        let destinationURL = soundsDir.appendingPathComponent(uniqueFileName)

        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

        let customSound = CustomSound(name: name, category: category, fileName: uniqueFileName)
        sounds.append(customSound)
        save()
    }

    func deleteSound(_ sound: CustomSound) {
        if let url = sound.fileURL {
            try? FileManager.default.removeItem(at: url)
        }
        sounds.removeAll { $0.id == sound.id }
        save()
    }

    func renameSound(_ sound: CustomSound, to newName: String) {
        if let index = sounds.firstIndex(where: { $0.id == sound.id }) {
            sounds[index].name = newName
            save()
        }
    }

    // Convert to a Sound model for playback
    func asSound(_ customSound: CustomSound) -> Sound? {
        guard let fileURL = customSound.fileURL else { return nil }
        return Sound(
            id: "custom_\(customSound.id.uuidString)",
            name: customSound.name,
            category: .noise, // Default category for custom sounds
            fileName: fileURL.path,
            backgroundImage: "waveform.circle.fill",
            isPremium: false,
            isGenerated: false
        )
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(sounds) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let saved = try? JSONDecoder().decode([CustomSound].self, from: data) else { return }
        sounds = saved
    }

    enum ImportError: LocalizedError {
        case accessDenied
        case directoryUnavailable

        var errorDescription: String? {
            switch self {
            case .accessDenied: return "Unable to access the selected file."
            case .directoryUnavailable: return "Unable to create storage directory."
            }
        }
    }
}
