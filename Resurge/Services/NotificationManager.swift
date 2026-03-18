import Foundation
import UserNotifications

final class NotificationManager {

    private let center = UNUserNotificationCenter.current()

    // MARK: - Permission

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            if granted {
                print("Notification permission granted.")
            }
        }
    }

    /// Requests notification permission if not yet determined, then calls completion with the result.
    /// If already determined, calls completion immediately with whether permission is authorized.
    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            switch settings.authorizationStatus {
            case .notDetermined:
                self.center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    completion(true)
                }
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// Checks the current notification authorization status and calls back on main thread.
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // MARK: - Schedule Pledge Reminder

    func schedulePledgeReminder(at date: Date) {
        schedulePledgeReminder(at: date, programName: nil, pledgeText: nil, habitId: nil)
    }

    func schedulePledgeReminder(at date: Date, programName: String?, pledgeText: String?, habitId: String?) {
        let content = UNMutableNotificationContent()
        content.title = "Morning Pledge"
        if let pledgeText = pledgeText, !pledgeText.isEmpty {
            content.body = pledgeText
        } else {
            content.body = "Start your day with intention. Take a moment to make your daily pledge."
        }
        content.sound = .default
        content.categoryIdentifier = "PLEDGE_REMINDER"

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let identifier: String
        if let habitId = habitId {
            identifier = "com.looproot.pledge.reminder.\(habitId)"
        } else {
            identifier = "com.looproot.pledge.reminder"
        }

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule pledge reminder: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Reflection Reminder

    func scheduleReflectionReminder(at date: Date) {
        scheduleReflectionReminder(at: date, programName: nil, reflectionText: nil, habitId: nil)
    }

    func scheduleReflectionReminder(at date: Date, programName: String?, reflectionText: String?, habitId: String?) {
        let content = UNMutableNotificationContent()
        content.title = "Evening Reflection"
        if let reflectionText = reflectionText, !reflectionText.isEmpty {
            content.body = reflectionText
        } else {
            content.body = "How was your day? Take a few minutes to reflect on your progress."
        }
        content.sound = .default
        content.categoryIdentifier = "REFLECTION_REMINDER"

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let identifier: String
        if let habitId = habitId {
            identifier = "com.looproot.reflection.reminder.\(habitId)"
        } else {
            identifier = "com.looproot.reflection.reminder"
        }

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule reflection reminder: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Motivational (one-time)

    func scheduleMotivational(message: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Stay Strong"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "MOTIVATIONAL"

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "com.looproot.motivational.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule motivational notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Daily Motivational Quotes

    /// Schedules repeating daily motivational quote notifications.
    /// Free users get 1 slot, premium users get up to 4.
    /// - Parameters:
    ///   - quotes: Array of quote strings to rotate through
    ///   - times: Array of Date objects (only hour/minute used) for notification times
    ///   - programName: The habit program name for the notification title
    func scheduleDailyQuotes(quotes: [String], times: [Date], programName: String) {
        // Cancel existing quote notifications first
        cancelQuoteNotifications()

        for (index, time) in times.enumerated() {
            guard index < quotes.count else { break }

            let content = UNMutableNotificationContent()
            content.title = "You've Got This"
            content.body = quotes[index % quotes.count]
            content.sound = .default
            content.categoryIdentifier = "DAILY_QUOTE"

            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let request = UNNotificationRequest(
                identifier: "com.looproot.daily.quote.\(index)",
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule quote \(index): \(error.localizedDescription)")
                }
            }
        }
    }

    /// Cancel only the daily quote notifications
    func cancelQuoteNotifications() {
        let quoteIds = (0..<5).map { "com.looproot.daily.quote.\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: quoteIds)
    }

    // MARK: - High Risk Window Alert

    /// Schedules a notification for a known high-risk time based on user patterns.
    func scheduleHighRiskAlert(hour: Int, minute: Int = 0, message: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "High-Risk Window"
        content.body = message ?? "This is usually a tough time for you. Open your toolkit and stay strong."
        content.sound = .default
        content.categoryIdentifier = "HIGH_RISK_WINDOW"

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "com.looproot.highrisk.\(hour).\(minute)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule high-risk alert: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Goal Reminder

    func scheduleGoalReminder(habitName: String, daysRemaining: Int, at date: Date) {
        let goalText = "\(daysRemaining) days left to reach your \(habitName) goal. Keep going!"
        scheduleGoalReminder(habitName: habitName, at: date, goalText: goalText, habitId: nil)
    }

    func scheduleGoalReminder(habitName: String, at date: Date, goalText: String, habitId: String?) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Reminder"
        content.body = goalText
        content.sound = .default
        content.categoryIdentifier = "GOAL_REMINDER"

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let identifier: String
        if let habitId = habitId {
            identifier = "com.looproot.goal.\(habitId)"
        } else {
            identifier = "com.looproot.goal.\(habitName.lowercased().replacingOccurrences(of: " ", with: "_"))"
        }

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule goal reminder: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Focus Session

    func scheduleFocusSessionStart(in seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session"
        content.body = "Your focus session is about to begin. Find a calm space and get ready."
        content.sound = .default
        content.categoryIdentifier = "FOCUS_SESSION_START"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)

        let request = UNNotificationRequest(
            identifier: "com.looproot.focus.start.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule focus session start: \(error.localizedDescription)")
            }
        }
    }

    func scheduleFocusSessionEnd(in seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Session Complete"
        content.body = "Great work! Your focus session is done. How do you feel?"
        content.sound = .default
        content.categoryIdentifier = "FOCUS_SESSION_END"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)

        let request = UNNotificationRequest(
            identifier: "com.looproot.focus.end.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule focus session end: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Stealth Mode Support

    /// Schedules a notification with redacted content for stealth mode.
    func scheduleStealthNotification(originalTitle: String, originalBody: String, trigger: UNNotificationTrigger, identifier: String) {
        let content = UNMutableNotificationContent()
        let stealthEnabled = UserDefaults.standard.bool(forKey: "stealth_notifications")

        if stealthEnabled {
            content.title = "Reminder"
            content.body = "You have a pending check-in."
        } else {
            content.title = originalTitle
            content.body = originalBody
        }
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Cancel High Risk Alerts

    func cancelHighRiskAlerts() {
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix("com.looproot.highrisk.") }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    // MARK: - Cancel All

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    // MARK: - Pending Count

    func pendingCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
}
