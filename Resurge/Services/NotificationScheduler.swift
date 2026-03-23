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
        let morningH = UserDefaults.standard.integer(forKey: "morningLoopHour")
        let morningM = UserDefaults.standard.integer(forKey: "morningLoopMinute")
        let afternoonH = UserDefaults.standard.integer(forKey: "afternoonLoopHour")
        let afternoonM = UserDefaults.standard.integer(forKey: "afternoonLoopMinute")
        let eveningH = UserDefaults.standard.integer(forKey: "eveningLoopHour")
        let eveningM = UserDefaults.standard.integer(forKey: "eveningLoopMinute")

        let morning = morningH > 0 ? morningH : 7
        let morningMin = morningM
        let afternoon = afternoonH > 0 ? afternoonH : 13
        let afternoonMin = afternoonM
        let evening = eveningH > 0 ? eveningH : 19
        let eveningMin = eveningM

        // Daily loop times as (hour, minute)
        let loopTimes = [
            (morning, morningMin),
            (afternoon, afternoonMin),
            (evening, eveningMin)
        ]
        let loopLabels = ["Morning Plan", "Afternoon Check-In", "Evening Review"]
        let loopBodies = [
            "Set your intention for today.",
            "How's your day going? Quick check-in.",
            "Reflect on your day. What went well?"
        ]

        // Fetch habits on main thread — only habits that have started
        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isActive == YES"),
            NSPredicate(format: "startDate <= %@", Date() as NSDate)
        ])
        let habits = (try? context.fetch(request)) ?? []

        struct HabitInfo {
            let id: String
            let name: String
            let programType: String
        }
        let habitInfos = habits.map { HabitInfo(id: $0.id.uuidString, name: $0.name, programType: $0.programType) }
        let habitCount = habitInfos.count

        // Quote slots
        let quoteSlots: [(hour: Int, minute: Int)]
        if isPremium {
            quoteSlots = [
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot1Hour")), UserDefaults.standard.integer(forKey: "quoteSlot1Minute")),
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot2Hour")), UserDefaults.standard.integer(forKey: "quoteSlot2Minute")),
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot3Hour")), UserDefaults.standard.integer(forKey: "quoteSlot3Minute")),
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot4Hour")), UserDefaults.standard.integer(forKey: "quoteSlot4Minute")),
                (max(1, UserDefaults.standard.integer(forKey: "quoteSlot5Hour")), UserDefaults.standard.integer(forKey: "quoteSlot5Minute")),
            ].map { ($0.0 == 1 ? (wakeHour + 1) % 24 : $0.0, $0.1) }
        } else {
            let h = UserDefaults.standard.integer(forKey: "quoteSlot1Hour")
            let m = UserDefaults.standard.integer(forKey: "quoteSlot1Minute")
            quoteSlots = [(h > 0 ? h : (wakeHour + 1) % 24, m)]
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
            // Each habit gets staggered by 1 minute per habit index
            if dailyLoopEnabled {
                for (loopIndex, loopTime) in loopTimes.enumerated() {
                    for (_, habit) in habitInfos.enumerated() {
                        let rawName = habit.name
                        let habitLabel = rawName.lowercased().hasPrefix("quit") ? rawName : "Quit \(rawName)"

                        // All habits fire at the exact same time — they stack
                        scheduleDailyNotification(
                            id: "daily_\(loopLabels[loopIndex].replacingOccurrences(of: " ", with: "_"))_\(habit.id)",
                            hour: loopTime.0, minute: loopTime.1,
                            title: stealthEnabled ? "Reminder" : "\(loopLabels[loopIndex]) — \(habitLabel)",
                            body: stealthEnabled ? "You have a pending check-in." : loopBodies[loopIndex],
                            center: center
                        )
                    }
                }
            }

            // MARK: - Motivational Quote Notifications
            if dailyQuoteEnabled {
                for (slotIndex, slot) in quoteSlots.enumerated() {
                    for (habitIndex, habit) in habitInfos.enumerated() {
                        let programType = ProgramType(rawValue: habit.programType)
                        let rawName = habit.name
                        let habitLabel = rawName.lowercased().hasPrefix("quit") ? rawName : "Quit \(rawName)"

                        let quotePool = QuoteBank.allQuotes.filter { q in
                            q.programTypes == nil || (programType != nil && q.programTypes!.contains(programType!))
                        }

                        // Pick a quote (changes each time app reschedules)
                        let seed = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) + slotIndex * 37 + habitIndex * 13
                        let quote = quotePool.isEmpty ? QuoteBank.allQuotes[0] : quotePool[seed % quotePool.count]

                        // Repeating daily at exact set time — same as daily loop
                        let id = "quote_h\(habitIndex)_s\(slotIndex)"
                        scheduleDailyNotification(
                            id: id,
                            hour: slot.hour, minute: slot.minute,
                            title: stealthEnabled ? "Motivation" : "You\u{2019}ve Got This — \(habitLabel)",
                            body: stealthEnabled ? "Open the app for your daily motivation." : quote.text,
                            center: center
                        )
                    }
                }
            }

            // Log scheduled count
            center.getPendingNotificationRequests { requests in
                print("NotificationScheduler: \(requests.count) notifications scheduled")
                for req in requests.prefix(10) {
                    if let cal = req.trigger as? UNCalendarNotificationTrigger {
                        print("  → \(req.identifier): \(cal.dateComponents.hour ?? 0):\(String(format: "%02d", cal.dateComponents.minute ?? 0))")
                    }
                }
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
            } else {
                print("NotificationScheduler: Scheduled \(id) at \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    // MARK: - Test Notifications (fires immediately for testing)

    static func fireTestNotifications(context: NSManagedObjectContext) {
        let center = UNUserNotificationCenter.current()
        let stealthEnabled = UserDefaults.standard.bool(forKey: "stealth_notifications")

        // Fetch active habits
        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        request.predicate = NSPredicate(format: "isActive == YES")
        let habits = (try? context.fetch(request)) ?? []

        var delay: TimeInterval = 3 // Start 3 seconds from now

        // Daily loop test notifications — 10 sec between habits
        for habit in habits {
            let rawName = habit.name
            let habitLabel = rawName.lowercased().hasPrefix("quit") ? rawName : "Quit \(rawName)"

            let types = [
                ("Morning Plan", "Set your intention for today."),
                ("Afternoon Check-In", "How's your day going? Quick check-in."),
                ("Evening Review", "Reflect on your day. What went well?")
            ]

            for (loopType, body) in types {
                let content = UNMutableNotificationContent()
                content.title = stealthEnabled ? "Reminder" : "\(loopType) — \(habitLabel)"
                content.body = stealthEnabled ? "You have a pending check-in." : body
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                center.add(UNNotificationRequest(identifier: "test_\(loopType)_\(habit.id.uuidString)", content: content, trigger: trigger))
                delay += 10 // 10 sec between each habit
            }
        }

        // 1 minute gap before motivation quotes
        delay += 60

        // Motivational quote test notifications — 10 sec between habits
        let isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        let quoteCount = isPremium ? 5 : 1

        for habit in habits {
            let programType = ProgramType(rawValue: habit.programType)
            let rawName = habit.name
            let habitLabel = rawName.lowercased().hasPrefix("quit") ? rawName : "Quit \(rawName)"

            let quotePool = QuoteBank.allQuotes.filter { q in
                q.programTypes == nil || (programType != nil && q.programTypes!.contains(programType!))
            }

            for i in 0..<quoteCount {
                let quote = quotePool.isEmpty ? QuoteBank.allQuotes[0] : quotePool[i % quotePool.count]

                let content = UNMutableNotificationContent()
                content.title = stealthEnabled ? "Motivation" : "You've Got This — \(habitLabel)"
                content.body = stealthEnabled ? "Open the app for your daily motivation." : quote.text
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                center.add(UNNotificationRequest(identifier: "test_quote_\(habit.id.uuidString)_\(i)", content: content, trigger: trigger))
                delay += 10
            }
        }

        print("NotificationScheduler: Fired test notifications over \(Int(delay)) seconds")
    }
}
