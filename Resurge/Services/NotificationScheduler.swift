import UserNotifications

struct NotificationScheduler {

    static let maxPending = 55

    static func rescheduleAll(
        morningHour: Int,
        morningMinute: Int,
        eveningHour: Int,
        eveningMinute: Int,
        quoteSlots: [(hour: Int, minute: Int)]
    ) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        var scheduled = 0

        // Morning plan reminder (repeating daily)
        scheduleDailyRepeating(
            id: "morning_plan",
            hour: morningHour,
            minute: morningMinute,
            title: "Morning Plan",
            body: "Take 1 minute to set your intention for today.",
            center: center
        )
        scheduled += 1

        // Evening review reminder (repeating daily)
        scheduleDailyRepeating(
            id: "evening_review",
            hour: eveningHour,
            minute: eveningMinute,
            title: "Evening Review",
            body: "Reflect on your day. What went well?",
            center: center
        )
        scheduled += 1

        // Quote notifications (rolling 7-day window)
        for (slotIndex, slot) in quoteSlots.enumerated() {
            for day in 0..<7 {
                guard scheduled < maxPending else { return }
                let id = "quote_\(slotIndex)_day\(day)"
                scheduleOneOff(
                    id: id,
                    daysFromNow: day,
                    hour: slot.hour,
                    minute: slot.minute,
                    title: "Daily Motivation",
                    body: QuoteBank.quoteOfTheDay().text,
                    center: center
                )
                scheduled += 1
            }
        }
    }

    private static func scheduleDailyRepeating(
        id: String,
        hour: Int,
        minute: Int,
        title: String,
        body: String,
        center: UNUserNotificationCenter
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        var dc = DateComponents()
        dc.hour = hour
        dc.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private static func scheduleOneOff(
        id: String,
        daysFromNow: Int,
        hour: Int,
        minute: Int,
        title: String,
        body: String,
        center: UNUserNotificationCenter
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        guard let date = Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) else { return }
        var dc = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dc.hour = hour
        dc.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
