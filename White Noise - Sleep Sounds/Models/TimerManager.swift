import Foundation
import UserNotifications

@Observable
class TimerManager {
    var isTimerActive = false
    var remainingSeconds: Int = 0
    var selectedMinutes: Int = 30
    var fadeOutEnabled = true
    var totalSeconds: Int = 0

    // Alarm
    var alarmEnabled = false
    var alarmTime = Date()

    private var timer: Timer?
    private(set) var targetDate: Date?
    var onTimerComplete: (() -> Void)?
    var onFadeOut: ((Float) -> Void)?

    var remainingFormatted: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func startTimer(minutes: Int) {
        stopTimer()
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
        isTimerActive = true
        targetDate = Date().addingTimeInterval(TimeInterval(totalSeconds))

        if alarmEnabled {
            scheduleAlarm()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        remainingSeconds = 0
        totalSeconds = 0
        targetDate = nil
    }

    func cancelAlarm() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["sleepAlarm"])
    }

    private func tick() {
        guard let targetDate else {
            stopTimer()
            return
        }

        let remaining = Int(targetDate.timeIntervalSinceNow)

        if remaining <= 0 {
            AnalyticsManager.shared.track(.timerCompleted, properties: ["total_seconds": totalSeconds])
            onTimerComplete?()
            stopTimer()
            return
        }

        remainingSeconds = remaining

        // Fade out over last 30 seconds
        if fadeOutEnabled && remaining <= 30 {
            let fadeVolume = Float(remaining) / 30.0
            onFadeOut?(fadeVolume)
        }
    }

    // MARK: - Alarm

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error {
                print("Notification permission error: \(error)")
            }
        }
    }

    private func scheduleAlarm() {
        cancelAlarm()

        let content = UNMutableNotificationContent()
        content.title = "Wake Up"
        content.body = "Your alarm is going off. Tap to open White Noise."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: alarmTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "sleepAlarm", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Alarm scheduling error: \(error)")
            }
        }
    }
}
