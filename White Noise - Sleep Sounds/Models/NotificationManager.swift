import Foundation
import UserNotifications

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    private static let enabledKey = "bedtime_reminder_enabled"
    private static let hourKey = "bedtime_reminder_hour"
    private static let minuteKey = "bedtime_reminder_minute"
    private static let requestIdentifier = "bedtime_reminder_daily"

    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey) }
    }

    var reminderTime: DateComponents {
        didSet {
            UserDefaults.standard.set(reminderTime.hour ?? 22, forKey: Self.hourKey)
            UserDefaults.standard.set(reminderTime.minute ?? 0, forKey: Self.minuteKey)
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        self.isEnabled = defaults.bool(forKey: Self.enabledKey)

        // Default to 10:00 PM if the user has never picked a time.
        let hasHour = defaults.object(forKey: Self.hourKey) != nil
        let hour = hasHour ? defaults.integer(forKey: Self.hourKey) : 22
        let minute = hasHour ? defaults.integer(forKey: Self.minuteKey) : 0
        self.reminderTime = DateComponents(hour: hour, minute: minute)
    }

    // MARK: - Enable / Disable

    /// Request authorization, then schedule (or prompt caller to reflect denial).
    /// Returns true if the reminder is now active.
    @discardableResult
    func enable() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted: Bool
        do {
            granted = try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            granted = false
        }

        guard granted else {
            await MainActor.run {
                self.isEnabled = false
            }
            return false
        }

        await MainActor.run {
            self.isEnabled = true
        }
        schedule()
        return true
    }

    func disable() {
        isEnabled = false
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.requestIdentifier])
    }

    /// Re-schedule for a new time. Caller should have already confirmed enable state.
    func updateTime(_ newTime: DateComponents) {
        reminderTime = newTime
        guard isEnabled else { return }
        schedule()
    }

    // MARK: - Scheduling

    private func schedule() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.requestIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Time to wind down"
        content.body = "Start a mix and drift off. Your streak is waiting."
        content.sound = nil // Don't startle someone already falling asleep.

        var trigger = DateComponents()
        trigger.hour = reminderTime.hour ?? 22
        trigger.minute = reminderTime.minute ?? 0

        let request = UNNotificationRequest(
            identifier: Self.requestIdentifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        center.add(request, withCompletionHandler: nil)
    }

    /// Convenience for UI time pickers.
    var reminderDate: Date {
        get {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = reminderTime.hour
            components.minute = reminderTime.minute
            return calendar.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            updateTime(components)
        }
    }
}
