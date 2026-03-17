import Foundation
import CoreData

@objc(CDHabit)
public class CDHabit: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var programType: String
    @NSManaged public var startDate: Date
    @NSManaged public var goalDays: Int32
    @NSManaged public var baselineCostPerDay: Double
    @NSManaged public var baselineTimePerDay: Double
    @NSManaged public var costPerUnit: Double
    @NSManaged public var timePerUnit: Double
    @NSManaged public var dailyUnits: Double
    @NSManaged public var reasonToQuit: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var sortOrder: Int16
    @NSManaged public var colorHex: String?
    @NSManaged public var iconName: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var syncID: String?
    @NSManaged public var goalMode: String?
    @NSManaged public var measurementMode: String?
    @NSManaged public var units: String?
    @NSManaged public var safetyLevel: String?

    // MARK: - Relationships

    @NSManaged public var dailyLogs: NSSet?
    @NSManaged public var cravingEntries: NSSet?
    @NSManaged public var achievementUnlocks: NSSet?
    @NSManaged public var journalEntries: NSSet?

    // MARK: - Computed Properties

    /// Number of full calendar days since the start date (not counting today until it ends).
    public var daysSoberCount: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        guard today >= start else { return 0 }
        let components = calendar.dateComponents([.day], from: start, to: today)
        return max(components.day ?? 0, 0)
    }

    /// The current streak in days, broken by any lapse recorded in daily logs.
    public var currentStreak: Int {
        guard let logs = dailyLogs as? Set<CDDailyLogEntry> else {
            return daysSoberCount
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)
        guard today >= start else { return 0 }

        // Build a set of dates on which a lapse occurred.
        let lapseDates: Set<Date> = Set(
            logs.filter { $0.lapsedToday }
                .map { calendar.startOfDay(for: $0.date) }
        )

        // Walk backwards from today counting consecutive lapse-free days.
        var streak = 0
        var cursor = today
        while cursor >= start {
            if lapseDates.contains(cursor) {
                break
            }
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    /// Estimated money saved since the start date based on the baseline cost per day.
    public var moneySaved: Double {
        let days = daysSoberCount
        guard days > 0 else { return 0 }

        if baselineCostPerDay > 0 {
            return baselineCostPerDay * Double(days)
        }
        // Fallback: derive from per-unit cost × daily units.
        return costPerUnit * dailyUnits * Double(days)
    }

    /// Estimated time saved in minutes since the start date.
    public var timeSavedMinutes: Double {
        let days = daysSoberCount
        guard days > 0 else { return 0 }

        if baselineTimePerDay > 0 {
            return baselineTimePerDay * Double(days)
        }
        return timePerUnit * dailyUnits * Double(days)
    }

    // MARK: - Lapse Reset

    /// Resets the recovery timer when a lapse occurs.
    /// Moves startDate to now so days, streak, health milestones, time reclaimed all restart.
    /// Does NOT touch: badges (already earned), analytics/history, journal entries, surges balance.
    public func resetOnLapse() {
        startDate = Date()
        updatedAt = Date()
    }

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        name: String,
        programType: String,
        startDate: Date = Date(),
        goalDays: Int32 = 30,
        baselineCostPerDay: Double = 0,
        baselineTimePerDay: Double = 0,
        costPerUnit: Double = 0,
        timePerUnit: Double = 0,
        dailyUnits: Double = 0,
        reasonToQuit: String? = nil,
        colorHex: String? = nil,
        iconName: String? = nil
    ) -> CDHabit {
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = name
        habit.programType = programType
        habit.startDate = startDate
        habit.goalDays = goalDays
        habit.baselineCostPerDay = baselineCostPerDay
        habit.baselineTimePerDay = baselineTimePerDay
        habit.costPerUnit = costPerUnit
        habit.timePerUnit = timePerUnit
        habit.dailyUnits = dailyUnits
        habit.reasonToQuit = reasonToQuit
        habit.isActive = true
        habit.sortOrder = 0
        habit.colorHex = colorHex
        habit.iconName = iconName
        habit.createdAt = Date()
        habit.updatedAt = Date()
        return habit
    }
}

// MARK: - Generated Accessors for dailyLogs

extension CDHabit {

    @objc(addDailyLogsObject:)
    @NSManaged public func addToDailyLogs(_ value: CDDailyLogEntry)

    @objc(removeDailyLogsObject:)
    @NSManaged public func removeFromDailyLogs(_ value: CDDailyLogEntry)

    @objc(addDailyLogs:)
    @NSManaged public func addToDailyLogs(_ values: NSSet)

    @objc(removeDailyLogs:)
    @NSManaged public func removeFromDailyLogs(_ values: NSSet)
}

// MARK: - Generated Accessors for cravingEntries

extension CDHabit {

    @objc(addCravingEntriesObject:)
    @NSManaged public func addToCravingEntries(_ value: CDCravingEntry)

    @objc(removeCravingEntriesObject:)
    @NSManaged public func removeFromCravingEntries(_ value: CDCravingEntry)

    @objc(addCravingEntries:)
    @NSManaged public func addToCravingEntries(_ values: NSSet)

    @objc(removeCravingEntries:)
    @NSManaged public func removeFromCravingEntries(_ values: NSSet)
}

// MARK: - Generated Accessors for achievementUnlocks

extension CDHabit {

    @objc(addAchievementUnlocksObject:)
    @NSManaged public func addToAchievementUnlocks(_ value: CDAchievementUnlock)

    @objc(removeAchievementUnlocksObject:)
    @NSManaged public func removeFromAchievementUnlocks(_ value: CDAchievementUnlock)

    @objc(addAchievementUnlocks:)
    @NSManaged public func addToAchievementUnlocks(_ values: NSSet)

    @objc(removeAchievementUnlocks:)
    @NSManaged public func removeFromAchievementUnlocks(_ values: NSSet)
}

// MARK: - Generated Accessors for journalEntries

extension CDHabit {

    @objc(addJournalEntriesObject:)
    @NSManaged public func addToJournalEntries(_ value: CDJournalEntry)

    @objc(removeJournalEntriesObject:)
    @NSManaged public func removeFromJournalEntries(_ value: CDJournalEntry)

    @objc(addJournalEntries:)
    @NSManaged public func addToJournalEntries(_ values: NSSet)

    @objc(removeJournalEntries:)
    @NSManaged public func removeFromJournalEntries(_ values: NSSet)
}
