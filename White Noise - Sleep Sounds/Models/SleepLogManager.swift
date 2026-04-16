import Foundation

struct SleepLogEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let durationMinutes: Int
    let soundName: String
    let soundId: String?
    let mixName: String?

    init(date: Date = Date(), durationMinutes: Int, soundName: String, soundId: String? = nil, mixName: String? = nil) {
        self.id = UUID()
        self.date = date
        self.durationMinutes = durationMinutes
        self.soundName = soundName
        self.soundId = soundId
        self.mixName = mixName
    }

    var durationFormatted: String {
        let hours = durationMinutes / 60
        let mins = durationMinutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

@Observable
class SleepLogManager {
    private static let storageKey = "sleep_log_entries"

    var entries: [SleepLogEntry] = []

    // Tracking state for an active session
    var sessionStartDate: Date?
    var sessionSoundName: String?
    var sessionSoundId: String?
    var sessionMixName: String?

    init() {
        load()
    }

    // MARK: - Session Tracking

    func startSession(soundName: String, soundId: String? = nil, mixName: String? = nil) {
        sessionStartDate = Date()
        sessionSoundName = soundName
        sessionSoundId = soundId
        sessionMixName = mixName
        AnalyticsManager.shared.track(.sleepSessionStarted, properties: [
            "sound_name": soundName,
            "sound_id": soundId ?? "",
            "is_mix": mixName != nil
        ])
    }

    func endSession() {
        guard let startDate = sessionStartDate, let soundName = sessionSoundName else { return }

        let duration = Int(Date().timeIntervalSince(startDate) / 60)
        // Only log sessions longer than 1 minute
        guard duration >= 1 else {
            clearSession()
            return
        }

        let entry = SleepLogEntry(
            date: startDate,
            durationMinutes: duration,
            soundName: soundName,
            soundId: sessionSoundId,
            mixName: sessionMixName
        )
        entries.insert(entry, at: 0)
        save()
        AnalyticsManager.shared.track(.sleepSessionEnded, properties: [
            "sound_name": soundName,
            "duration_minutes": duration,
            "is_mix": sessionMixName != nil
        ])
        clearSession()
    }

    private func clearSession() {
        sessionStartDate = nil
        sessionSoundName = nil
        sessionSoundId = nil
        sessionMixName = nil
    }

    // MARK: - Queries

    var entriesGroupedByWeek: [(weekLabel: String, entries: [SleepLogEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.dateInterval(of: .weekOfYear, for: entry.date)?.start ?? entry.date
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        return grouped
            .sorted { $0.key > $1.key }
            .map { weekStart, weekEntries in
                let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
                let label = "\(formatter.string(from: weekStart)) – \(formatter.string(from: weekEnd))"
                return (label, weekEntries.sorted { $0.date > $1.date })
            }
    }

    var totalSleepThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return entries
            .filter { $0.date >= startOfWeek }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    var averageSleepDuration: Int {
        guard !entries.isEmpty else { return 0 }
        return entries.reduce(0) { $0 + $1.durationMinutes } / entries.count
    }

    func deleteEntry(_ entry: SleepLogEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let saved = try? JSONDecoder().decode([SleepLogEntry].self, from: data) else { return }
        entries = saved
    }
}
