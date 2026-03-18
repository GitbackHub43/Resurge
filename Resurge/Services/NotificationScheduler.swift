import UserNotifications
import CoreData

struct NotificationScheduler {

    // MARK: - Schedule Everything

    /// Call this on app launch and whenever notification settings change.
    static func scheduleAll(context: NSManagedObjectContext) {
        // Gather all data on main thread first
        let dailyLoopEnabled = UserDefaults.standard.object(forKey: "dailyLoopEnabled") as? Bool ?? true
        let dailyQuoteEnabled = UserDefaults.standard.object(forKey: "dailyQuoteEnabled") as? Bool ?? true
        let isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        let stealthEnabled = UserDefaults.standard.bool(forKey: "stealth_notifications")

        let wakeHour = UserDefaults.standard.integer(forKey: "wakeUpHour")
        let afternoonHour = UserDefaults.standard.integer(forKey: "afternoonHour")
        let eveningHour = UserDefaults.standard.integer(forKey: "eveningHour")

        let morning = wakeHour > 0 ? wakeHour : 7
        let afternoon = afternoonHour > 0 ? afternoonHour : 15
        let evening = eveningHour > 0 ? eveningHour : 22

        // Fetch habits on main thread
        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        request.predicate = NSPredicate(format: "isActive == YES")
        let habits = (try? context.fetch(request)) ?? []

        // Collect habit data
        struct HabitInfo {
            let id: String
            let name: String
            let programType: String
        }
        let habitInfos = habits.map { HabitInfo(id: $0.id.uuidString, name: $0.name, programType: $0.programType) }

        // Quote slots
        let quoteSlots: [(hour: Int, minute: Int)]
        if isPremium {
            quoteSlots = [
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot1Hour")), UserDefaults.standard.integer(forKey: "quoteSlot1Minute")),
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot2Hour")), UserDefaults.standard.integer(forKey: "quoteSlot2Minute")),
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot3Hour")), UserDefaults.standard.integer(forKey: "quoteSlot3Minute")),
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot4Hour")), UserDefaults.standard.integer(forKey: "quoteSlot4Minute")),
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot5Hour")), UserDefaults.standard.integer(forKey: "quoteSlot5Minute")),
            ].map { ($0.0 == 1 ? 8 : $0.0, $0.1) }
        } else {
            let h = UserDefaults.standard.integer(forKey: "quoteSlot1Hour")
            let m = UserDefaults.standard.integer(forKey: "quoteSlot1Minute")
            quoteSlots = [(h > 0 ? h : 9, m)] // Default 9am for free users
        }

        // Now schedule on background
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else {
                print("NotificationScheduler: Permission not granted")
                return
            }

            center.removeAllPendingNotificationRequests()

            // MARK: - Daily Loop Reminders
            if dailyLoopEnabled {
                for habit in habitInfos {
                    let rawName = habit.name
                    let habitLabel = rawName.lowercased().hasPrefix("quit") ? rawName : "Quit \(rawName)"

                    scheduleDailyNotification(
                        id: "daily_morning_\(habit.id)",
                        hour: morning, minute: 0,
                        title: stealthEnabled ? "Reminder" : "Morning Plan — \(habitLabel)",
                        body: stealthEnabled ? "You have a pending check-in." : "Set your intention for today.",
                        center: center
                    )

                    scheduleDailyNotification(
                        id: "daily_afternoon_\(habit.id)",
                        hour: afternoon, minute: 0,
                        title: stealthEnabled ? "Reminder" : "Afternoon Check-In — \(habitLabel)",
                        body: stealthEnabled ? "You have a pending check-in." : "How's your day going? Quick check-in.",
                        center: center
                    )

                    scheduleDailyNotification(
                        id: "daily_evening_\(habit.id)",
                        hour: evening, minute: 0,
                        title: stealthEnabled ? "Reminder" : "Evening Review — \(habitLabel)",
                        body: stealthEnabled ? "You have a pending check-in." : "Reflect on your day. What went well?",
                        center: center
                    )
                }
            }

            // MARK: - Motivational Quote Notifications
            if dailyQuoteEnabled {
                for (habitIndex, habit) in habitInfos.enumerated() {
                    let programType = ProgramType(rawValue: habit.programType)
                    let rawName = habit.name
                    let habitLabel = rawName.lowercased().hasPrefix("quit") ? rawName : "Quit \(rawName)"

                    let quotePool = QuoteBank.allQuotes.filter { q in
                        q.programTypes == nil || (programType != nil && q.programTypes!.contains(programType!))
                    }

                    for (slotIndex, slot) in quoteSlots.enumerated() {
                        for day in 0..<7 {
                            guard let targetDate = Calendar.current.date(byAdding: .day, value: day, to: Date()) else { continue }
                            let seed = (Calendar.current.ordinality(of: .day, in: .year, for: targetDate) ?? 1) + slotIndex * 37 + habitIndex * 13
                            let quote = quotePool.isEmpty ? QuoteBank.allQuotes[0] : quotePool[seed % quotePool.count]

                            let id = "quote_h\(habitIndex)_s\(slotIndex)_d\(day)"
                            var dc = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
                            dc.hour = slot.hour
                            dc.minute = slot.minute + habitIndex // Stagger per habit

                            let content = UNMutableNotificationContent()
                            content.title = stealthEnabled ? "Motivation" : "You've Got This — \(habitLabel)"
                            content.body = stealthEnabled ? "Open the app for your daily motivation." : quote.text
                            content.sound = .default

                            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
                            center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
                        }
                    }
                }
            }

            // Log scheduled count
            center.getPendingNotificationRequests { requests in
                print("NotificationScheduler: \(requests.count) notifications scheduled")
            }
        }
    }

    // MARK: - Schedule Daily Notification (repeating)

    private static func scheduleDailyNotification(
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
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger)) { error in
            if let error = error {
                print("NotificationScheduler: Failed to schedule \(id): \(error)")
            }
        }
    }

    // MARK: - Test Notifications

    static func fireTestNotification() {
        let center = UNUserNotificationCenter.current()

        let loopContent = UNMutableNotificationContent()
        loopContent.title = "Morning Plan — Quit Smoking"
        loopContent.body = "Set your intention for today. (Test notification)"
        loopContent.sound = .default
        center.add(UNNotificationRequest(identifier: "test_daily_loop", content: loopContent, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)))

        let quote = QuoteBank.randomQuote()
        let quoteContent = UNMutableNotificationContent()
        quoteContent.title = "You've Got This — Quit Smoking"
        quoteContent.body = quote.text
        quoteContent.sound = .default
        center.add(UNNotificationRequest(identifier: "test_quote", content: quoteContent, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 8, repeats: false)))
    }
}
