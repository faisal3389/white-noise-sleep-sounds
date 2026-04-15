import Foundation
import SwiftUI

struct PlaylistItem: Identifiable, Codable, Hashable {
    let id: UUID
    let soundId: String
    var durationMinutes: Int? // nil = play until manually advanced

    init(soundId: String, durationMinutes: Int? = nil) {
        self.id = UUID()
        self.soundId = soundId
        self.durationMinutes = durationMinutes
    }

    var sound: Sound? {
        SoundLibrary.allSounds.first { $0.id == soundId }
    }
}

@Observable
class PlaylistManager {
    private static let storageKey = "saved_playlist"

    var items: [PlaylistItem] = []
    var currentIndex: Int = 0
    var isActive: Bool = false

    private var advanceTimer: Timer?

    var onPlaySound: ((Sound) -> Void)?
    var onPlaylistFinished: (() -> Void)?

    var currentItem: PlaylistItem? {
        guard isActive, items.indices.contains(currentIndex) else { return nil }
        return items[currentIndex]
    }

    var hasItems: Bool { !items.isEmpty }

    init() {
        load()
    }

    // MARK: - Playlist Management

    func addSound(_ sound: Sound) {
        let item = PlaylistItem(soundId: sound.id)
        items.append(item)
        save()
    }

    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        // Adjust currentIndex if needed
        if currentIndex >= items.count {
            currentIndex = max(0, items.count - 1)
        }
        save()
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func setDuration(for itemId: UUID, minutes: Int?) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].durationMinutes = minutes
            save()
        }
    }

    func clearPlaylist() {
        stopPlaylist()
        items.removeAll()
        save()
    }

    // MARK: - Playback

    func startPlaylist() {
        guard !items.isEmpty else { return }
        currentIndex = 0
        isActive = true
        playCurrentItem()
    }

    func startPlaylist(from index: Int) {
        guard items.indices.contains(index) else { return }
        currentIndex = index
        isActive = true
        playCurrentItem()
    }

    func stopPlaylist() {
        advanceTimer?.invalidate()
        advanceTimer = nil
        isActive = false
    }

    func advanceToNext() {
        advanceTimer?.invalidate()
        advanceTimer = nil

        currentIndex += 1
        if currentIndex >= items.count {
            // Playlist finished
            isActive = false
            currentIndex = 0
            onPlaylistFinished?()
            return
        }
        playCurrentItem()
    }

    func goToPrevious() {
        advanceTimer?.invalidate()
        advanceTimer = nil

        currentIndex = max(0, currentIndex - 1)
        playCurrentItem()
    }

    private func playCurrentItem() {
        guard let item = currentItem, let sound = item.sound else {
            advanceToNext()
            return
        }

        onPlaySound?(sound)

        // Schedule auto-advance if duration is set
        if let minutes = item.durationMinutes, minutes > 0 {
            advanceTimer?.invalidate()
            advanceTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: false) { [weak self] _ in
                self?.advanceToNext()
            }
        }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let saved = try? JSONDecoder().decode([PlaylistItem].self, from: data) else { return }
        items = saved
    }
}
