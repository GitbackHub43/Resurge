import SwiftUI
import CoreData

final class SettingsViewModel: ObservableObject {
    @Published var pledgeReminderEnabled = false
    @Published var pledgeReminderTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @Published var reflectionReminderEnabled = false
    @Published var reflectionReminderTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    @Published var motivationalEnabled = false
    @Published var biometricLockEnabled = false
    @Published var showExportSheet = false
    @Published var exportData: Data?

    private let notificationManager: NotificationManager
    private let biometricManager: BiometricLockManager

    init(notificationManager: NotificationManager,
         biometricManager: BiometricLockManager) {
        self.notificationManager = notificationManager
        self.biometricManager = biometricManager
    }

    // MARK: - Daily Quote Notifications

    /// Schedules daily motivational quote notifications based on user settings.
    /// Free users get 1 slot, premium users get up to 5 slots.
    func updateQuoteNotifications(isPremium: Bool) {
        let dailyQuoteEnabled = UserDefaults.standard.bool(forKey: "dailyQuoteEnabled")

        guard dailyQuoteEnabled else {
            notificationManager.cancelQuoteNotifications()
            return
        }

        // Request permission first, then schedule
        notificationManager.requestPermissionIfNeeded { [weak self] granted in
            guard let self = self, granted else { return }

            let defaults = UserDefaults.standard
            let slot1Hour = defaults.integer(forKey: "quoteSlot1Hour")
            let slot1Minute = defaults.integer(forKey: "quoteSlot1Minute")
            let slot2Hour = defaults.integer(forKey: "quoteSlot2Hour")
            let slot2Minute = defaults.integer(forKey: "quoteSlot2Minute")
            let slot3Hour = defaults.integer(forKey: "quoteSlot3Hour")
            let slot3Minute = defaults.integer(forKey: "quoteSlot3Minute")
            let slot4Hour = defaults.integer(forKey: "quoteSlot4Hour")
            let slot4Minute = defaults.integer(forKey: "quoteSlot4Minute")
            let slot5Hour = defaults.integer(forKey: "quoteSlot5Hour")
            let slot5Minute = defaults.integer(forKey: "quoteSlot5Minute")

            let allSlots: [(Int, Int)] = isPremium
                ? [(slot1Hour, slot1Minute), (slot2Hour, slot2Minute),
                   (slot3Hour, slot3Minute), (slot4Hour, slot4Minute),
                   (slot5Hour, slot5Minute)]
                : [(slot1Hour, slot1Minute)]

            let calendar = Calendar.current
            let times: [Date] = allSlots.compactMap { hour, minute in
                calendar.date(from: DateComponents(hour: hour, minute: minute))
            }

            let slotCount = times.count
            let quotes: [String] = (0..<slotCount).map { _ in
                QuoteBank.randomQuote().text
            }

            self.notificationManager.scheduleDailyQuotes(
                quotes: quotes,
                times: times,
                programName: "Recovery"
            )
        }
    }

    var canUseBiometrics: Bool {
        biometricManager.canUseBiometrics()
    }

    var biometricTypeName: String {
        switch biometricManager.biometricType() {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return "Not Available"
        }
    }

    func updatePledgeReminder() {
        if pledgeReminderEnabled {
            notificationManager.schedulePledgeReminder(at: pledgeReminderTime)
        } else {
            notificationManager.cancelAll()
        }
    }

    func updateReflectionReminder() {
        if reflectionReminderEnabled {
            notificationManager.scheduleReflectionReminder(at: reflectionReminderTime)
        }
    }

    func requestNotificationPermission() {
        notificationManager.requestPermission()
    }

    func exportHabits(context: NSManagedObjectContext) -> String {
        let request = NSFetchRequest<CDHabit>(entityName: "CDHabit")
        let habits = (try? context.fetch(request)) ?? []
        var csv = "Name,Program,Start Date,Days Sober,Money Saved\n"
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        for habit in habits {
            let name = habit.name ?? "Unknown"
            let program = habit.programType ?? "unknown"
            let start = formatter.string(from: habit.startDate ?? Date())
            csv += "\(name),\(program),\(start),\(habit.daysSoberCount),\(String(format: "%.2f", habit.moneySaved))\n"
        }
        return csv
    }
}
