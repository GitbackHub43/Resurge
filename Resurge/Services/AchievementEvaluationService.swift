import Foundation
import CoreData

final class AchievementEvaluationService {

    private let context: NSManagedObjectContext
    private let achievementRepository: AchievementRepositoryProtocol

    init(context: NSManagedObjectContext, achievementRepository: AchievementRepositoryProtocol) {
        self.context = context
        self.achievementRepository = achievementRepository
    }

    /// Call this after ANY user action that might unlock a badge
    func evaluate(for habit: CDHabit) {
        let days = habit.daysSoberCount
        let streak = habit.currentStreak

        // Counts for behavior badges
        let journalCount = countJournalEntries(for: habit)
        let cravingsResisted = countCravingsResisted(for: habit)
        let checkInDays = countCheckInDays(for: habit)
        let toolsUsed = countUniqueToolsUsed(for: habit)
        let timeSavedHours = Int(habit.timeSavedMinutes / 60)


        // Include per-habit health badges in evaluation
        let programType = ProgramType(rawValue: habit.programType) ?? .smoking
        let healthBadges = MilestoneBadge.healthBadges(for: programType)
        let allBadgesToEvaluate = MilestoneBadge.allBadges + healthBadges

        for badge in allBadgesToEvaluate {
            guard !achievementRepository.hasUnlocked(habit: habit, key: badge.key) else { continue }

            var shouldUnlock = false

            switch badge.category {
            case .time:
                // Time badges: requiredDays stores HOURS — check against time reclaimed
                shouldUnlock = badge.requiredDays > 0 && timeSavedHours >= badge.requiredDays

            case .streak:
                // Streak badges: based on current streak
                shouldUnlock = badge.requiredDays > 0 && streak >= badge.requiredDays

            case .behavior:
                // Behavior badges: various criteria based on key
                shouldUnlock = checkBehaviorBadge(badge: badge, journalCount: journalCount, cravingsResisted: cravingsResisted, checkInDays: checkInDays, toolsUsed: toolsUsed, timeSavedHours: timeSavedHours, days: days)

            case .program:
                // Program badges: same as time but only for matching program
                if let badgeProgram = badge.programType,
                   let habitProgram = ProgramType(rawValue: habit.programType),
                   badgeProgram == habitProgram {
                    shouldUnlock = badge.requiredDays > 0 && days >= badge.requiredDays
                }

            case .tool:
                // Track badges: based on requiredCount
                if badge.requiredCount > 0 {
                    let count = countForTrack(badge: badge)
                    shouldUnlock = count >= badge.requiredCount
                }
            }

            if shouldUnlock {
                achievementRepository.unlock(habit: habit, key: badge.key)

                // Queue the badge unlock popup
                BadgeUnlockManager.shared.enqueue(badge)

                // Trigger celebrations for newly unlocked badges
                if badge.category == .streak {
                    CelebrationManager.shared.trigger(.goldenShower)
                } else {
                    CelebrationManager.shared.trigger(.cosmicSparkle)
                }
            }
        }
    }

    // MARK: - Behavior Badge Evaluation

    private func checkBehaviorBadge(badge: MilestoneBadge, journalCount: Int, cravingsResisted: Int, checkInDays: Int, toolsUsed: Int, timeSavedHours: Int, days: Int) -> Bool {
        switch badge.key {
        case "first_journal": return journalCount >= 1
        case "journal_10": return journalCount >= 10
        case "journal_50": return journalCount >= 50
        case "journal_100": return journalCount >= 100
        case "journal_250": return journalCount >= 250
        case "journal_500": return journalCount >= 500
        case "craving_crusher_10": return cravingsResisted >= 10
        case "craving_crusher_50": return cravingsResisted >= 50
        case "week_warrior": return checkInDays >= 7
        case "tool_explorer": return toolsUsed >= 5
        case "time_100": return timeSavedHours >= 100
        case "time_500": return timeSavedHours >= 500
        default:
            // Health badges from HealthTimeline — key format: health_{programType}_{index}
            if badge.key.hasPrefix("health_") {
                // requiredDays on the badge tells us how many days the user needs
                return days >= badge.requiredDays
            }
            return false
        }
    }

    // MARK: - Track Badge Evaluation

    private func countForTrack(badge: MilestoneBadge) -> Int {
        guard let trackName = badge.trackName else { return 0 }
        switch trackName {
        case "Wave Rider": return countCravingProtocols()
        case "Resilience Builder": return countLapseRepairs()
        case "Plan Streak": return countMorningPlans()
        case "Urge Scientist": return countUrgeLogEntries()
        case "Values Champ": return countValuesCompassUses()
        default: return 0
        }
    }

    // MARK: - Count Helpers (all use NSFetchRequest pattern)

    private func countJournalEntries(for habit: CDHabit) -> Int {
        let request = NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
        // Only count actual journal entries — exclude gratitude and craving journal entries
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "promptUsed == nil OR (NOT (promptUsed CONTAINS[cd] %@) AND NOT (promptUsed CONTAINS[cd] %@))", "gratitude", "craving")
        ])
        return (try? context.count(for: request)) ?? 0
    }

    private func countCravingsResisted(for habit: CDHabit) -> Int {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "didResist == YES")
        ])
        return (try? context.count(for: request)) ?? 0
    }

    private func countCheckInDays(for habit: CDHabit) -> Int {
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSPredicate(format: "habit == %@", habit)
        return (try? context.count(for: request)) ?? 0
    }

    private func countUniqueToolsUsed(for habit: CDHabit) -> Int {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "copingToolUsed != nil")
        ])
        guard let entries = try? context.fetch(request) else { return 0 }
        let uniqueTools = Set(entries.compactMap { $0.copingToolUsed })
        return uniqueTools.count
    }

    // Track-specific counts (aggregate, not per-habit)
    private func countCravingProtocols() -> Int {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "copingToolUsed != nil")
        return (try? context.count(for: request)) ?? 0
    }

    private func countLapseRepairs() -> Int {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "eventType == %@", "LAPSE_REVIEW")
        return (try? context.count(for: request)) ?? 0
    }

    private func countMorningPlans() -> Int {
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSPredicate(format: "didPledge == YES")
        return (try? context.count(for: request)) ?? 0
    }

    private func countUrgeLogEntries() -> Int {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "copingToolUsed == %@", "Urge Log")
        return (try? context.count(for: request)) ?? 0
    }

    private func countValuesCompassUses() -> Int {
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSPredicate(format: "copingToolUsed == %@", "Values Compass")
        return (try? context.count(for: request)) ?? 0
    }
}
