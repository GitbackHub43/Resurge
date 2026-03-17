import Foundation
import CoreData
import SwiftUI

final class VirtualCompanionService: ObservableObject {

    @Published var companion: CDVirtualCompanion?

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadCompanion()
    }

    // MARK: - Get or Create

    @discardableResult
    func getOrCreate(context: NSManagedObjectContext) -> CDVirtualCompanion {
        if let existing = companion {
            return existing
        }

        let request = NSFetchRequest<CDVirtualCompanion>(entityName: "CDVirtualCompanion")
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            DispatchQueue.main.async { self.companion = existing }
            return existing
        }

        let newCompanion = CDVirtualCompanion(context: context)
        newCompanion.id = UUID()
        newCompanion.name = "Guardian"
        newCompanion.species = "sprout"
        newCompanion.level = 1
        newCompanion.xp = 0
        newCompanion.currentMood = "happy"
        newCompanion.createdAt = Date()

        try? context.save()
        DispatchQueue.main.async { self.companion = newCompanion }
        return newCompanion
    }

    // MARK: - Add XP (no-op, kept for API compatibility)

    func addXP(_ amount: Int32) {
        // No-op: leveling is now streak-based via updateFromRecoveryState()
    }

    // MARK: - Update From Recovery State

    /// Call this to refresh the companion's level and mood from actual recovery data.
    func updateFromRecoveryState(habits: [CDHabit], context: NSManagedObjectContext) {
        guard let companion = companion else { return }

        let streak = longestActiveStreak(habits: habits)
        companion.level = Int32(levelForStreak(streak))
        companion.currentMood = computeMoodFromRecovery(habits: habits, context: context)

        try? context.save()
        objectWillChange.send()
    }

    // MARK: - Current Level (streak-based)

    func currentLevel() -> Int {
        Int(companion?.level ?? 1)
    }

    /// Compute level from longest streak milestone reached.
    func levelForStreak(_ days: Int) -> Int {
        switch days {
        case 0...6:
            return 1
        case 7...13:
            return 2
        case 14...29:
            return 3
        case 30...59:
            return 4
        case 60...89:
            return 5
        default:
            return 6
        }
    }

    // MARK: - Mood From Recovery

    /// Compute mood based on real recovery signals: streak, lapses, and journaling.
    func computeMoodFromRecovery(habits: [CDHabit], context: NSManagedObjectContext) -> String {
        let streak = longestActiveStreak(habits: habits)
        let journalsThisWeek = journalCountLast7Days(context: context)

        if streak >= 30 && journalsThisWeek >= 3 {
            return "ecstatic"
        }
        if streak >= 14 && journalsThisWeek >= 2 {
            return "proud"
        }
        if streak >= 7 {
            return "happy"
        }
        if streak >= 3 {
            return "neutral"
        }
        if streak >= 1 {
            return "worried"
        }
        // streak == 0 — lapsed today
        return "sad"
    }

    // MARK: - Contextual Message

    /// Returns a context-aware supportive message based on current recovery state.
    func contextualMessage(for habits: [CDHabit], context: NSManagedObjectContext) -> String {
        let streak = longestActiveStreak(habits: habits)
        let daysSinceLastLapse = self.daysSinceLastLapse(context: context)
        let journalsThisWeek = journalCountLast7Days(context: context)

        if streak >= 30 {
            return "I'm so proud of how far you've come! \(streak) days strong!"
        }
        if streak >= 7 {
            return "One week down! You're building real momentum."
        }
        if let lapseDays = daysSinceLastLapse, lapseDays <= 3 {
            return "Hey, setbacks happen. What matters is you're still here."
        }
        if journalsThisWeek == 0 {
            return "Want to write down how you're feeling? It really helps."
        }
        if streak == 0 {
            return "Today is a fresh start. I believe in you."
        }
        return "Every day you show up, you get stronger."
    }

    // MARK: - Mood for Streak (legacy convenience)

    func moodForStreak(_ days: Int) -> String {
        switch days {
        case 0:
            return "sad"
        case 1...2:
            return "worried"
        case 3...6:
            return "neutral"
        case 7...13:
            return "happy"
        case 14...29:
            return "proud"
        default:
            return "ecstatic"
        }
    }

    // MARK: - Private Helpers

    private func loadCompanion() {
        let request = NSFetchRequest<CDVirtualCompanion>(entityName: "CDVirtualCompanion")
        request.fetchLimit = 1
        companion = try? context.fetch(request).first
    }

    /// Returns the current streak of the first active habit, or 0 if none.
    func longestActiveStreak(habits: [CDHabit]) -> Int {
        let activeHabits = habits.filter { $0.isActive }
        guard !activeHabits.isEmpty else { return 0 }
        return activeHabits.map { $0.currentStreak }.max() ?? 0
    }

    /// Days since the most recent lapse (CDCravingEntry where didResist == false). Returns nil if no lapses found.
    private func daysSinceLastLapse(context: NSManagedObjectContext) -> Int? {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "didResist == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1

        guard let lastLapse = try? context.fetch(request).first else { return nil }

        let calendar = Calendar.current
        let lapseDay = calendar.startOfDay(for: lastLapse.timestamp)
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: lapseDay, to: today)
        return max(components.day ?? 0, 0)
    }

    /// Number of journal entries in the last 7 days.
    private func journalCountLast7Days(context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
        let calendar = Calendar.current
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        request.predicate = NSPredicate(format: "date >= %@", sevenDaysAgo as NSDate)

        return (try? context.count(for: request)) ?? 0
    }
}
