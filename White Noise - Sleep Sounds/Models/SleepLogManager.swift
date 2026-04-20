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
    private static let activeSessionKey = "sleep_log_active_session"
    private static let heartbeatInterval: TimeInterval = 30

    private struct ActiveSession: Codable {
        let startDate: Date
        var lastHeartbeat: Date
        let contextId: String
        let soundName: String
        let soundId: String?
        let mixName: String?
    }

    var entries: [SleepLogEntry] = []

    private var activeSession: ActiveSession?
    private var heartbeatTimer: Timer?

    init() {
        load()
        finalizePendingSession()
    }

    // MARK: - Public API

    /// Single entry point driven by ContentView observing the player. Handles
    /// start, context-switch, and end in one place so we never double-start or
    /// lose a session when the user pauses, resumes, or swaps sounds.
    func syncToPlayback(isPlaying: Bool, contextId: String?, soundName: String, soundId: String?, mixName: String?) {
        guard isPlaying, let contextId else {
            endSession()
            return
        }

        if let active = activeSession {
            if active.contextId == contextId { return }
            endSession()
        }

        startSession(contextId: contextId, soundName: soundName, soundId: soundId, mixName: mixName)
    }

    func endSession() {
        stopHeartbeat()
        guard let session = activeSession else { return }
        activeSession = nil
        UserDefaults.standard.removeObject(forKey: Self.activeSessionKey)
        finalize(session: session, endDate: Date())
    }

    // MARK: - Session lifecycle

    private func startSession(contextId: String, soundName: String, soundId: String?, mixName: String?) {
        let now = Date()
        activeSession = ActiveSession(
            startDate: now,
            lastHeartbeat: now,
            contextId: contextId,
            soundName: soundName,
            soundId: soundId,
            mixName: mixName
        )
        saveActiveSession()
        startHeartbeat()
        AnalyticsManager.shared.track(.sleepSessionStarted, properties: [
            "sound_name": soundName,
            "sound_id": soundId ?? "",
            "is_mix": mixName != nil
        ])
    }

    /// If the app was killed mid-session (common for overnight use), we can't
    /// know exactly when playback stopped. Use the last heartbeat timestamp as
    /// a best-effort end time so the session still gets logged.
    private func finalizePendingSession() {
        guard let data = UserDefaults.standard.data(forKey: Self.activeSessionKey),
              let session = try? JSONDecoder().decode(ActiveSession.self, from: data) else {
            return
        }
        UserDefaults.standard.removeObject(forKey: Self.activeSessionKey)
        finalize(session: session, endDate: session.lastHeartbeat)
    }

    private func finalize(session: ActiveSession, endDate: Date) {
        let duration = Int(endDate.timeIntervalSince(session.startDate) / 60)
        guard duration >= 1 else { return }
        let entry = SleepLogEntry(
            date: session.startDate,
            durationMinutes: duration,
            soundName: session.soundName,
            soundId: session.soundId,
            mixName: session.mixName
        )
        entries.insert(entry, at: 0)
        save()
        AnalyticsManager.shared.track(.sleepSessionEnded, properties: [
            "sound_name": session.soundName,
            "duration_minutes": duration,
            "is_mix": session.mixName != nil
        ])
    }

    // MARK: - Heartbeat

    private func startHeartbeat() {
        stopHeartbeat()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: Self.heartbeatInterval, repeats: true) { [weak self] _ in
            self?.heartbeat()
        }
    }

    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    private func heartbeat() {
        guard activeSession != nil else { return }
        activeSession?.lastHeartbeat = Date()
        saveActiveSession()
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

    /// Consecutive calendar days ending today or yesterday that have at least
    /// one session. Yesterday is included so the streak stays intact during the
    /// day after a night of sleep — the user hasn't "broken" it until they skip
    /// a full night.
    var currentStreak: Int {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        let dayKeys = Set(entries.map { calendar.startOfDay(for: $0.date) })

        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }

        var cursor: Date
        if dayKeys.contains(today) {
            cursor = today
        } else if dayKeys.contains(yesterday) {
            cursor = yesterday
        } else {
            return 0
        }

        var streak = 0
        while dayKeys.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
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

    private func saveActiveSession() {
        guard let session = activeSession,
              let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: Self.activeSessionKey)
    }
}
