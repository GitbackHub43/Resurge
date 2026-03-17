import Foundation
import CoreData

/// Computes derived recovery metrics for a CDHabit.
struct MetricsEngine {

    // MARK: - Best Streak

    /// Returns the maximum contiguous no-lapse streak (in days) from the habit's
    /// start date through today. A lapse is any CDDailyLogEntry where
    /// `lapsedToday == true`.
    static func bestStreak(for habit: CDHabit) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: habit.startDate)
        let today = calendar.startOfDay(for: Date())
        guard today >= start else { return 0 }

        // Build a set of dates on which a lapse occurred.
        let lapseDates: Set<Date>
        if let logs = habit.dailyLogs as? Set<CDDailyLogEntry> {
            lapseDates = Set(
                logs.filter { $0.lapsedToday }
                    .map { calendar.startOfDay(for: $0.date) }
            )
        } else {
            lapseDates = []
        }

        var bestStreak = 0
        var currentStreak = 0
        var cursor = start

        while cursor <= today {
            if lapseDates.contains(cursor) {
                currentStreak = 0
            } else {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        return bestStreak
    }

    // MARK: - Rolling 7-Day Use Frequency

    /// Average number of USE_EPISODE craving entries per day over the last 7 days.
    static func rolling7dFrequency(for habit: CDHabit) -> Double {
        let episodes = useEpisodesInLast7Days(for: habit)
        return Double(episodes.count) / 7.0
    }

    // MARK: - Rolling 7-Day Quantity Average

    /// Average `quantity` of USE_EPISODE craving entries in the last 7 days.
    /// Returns 0 if there are no episodes.
    static func rolling7dQuantityAvg(for habit: CDHabit) -> Double {
        let episodes = useEpisodesInLast7Days(for: habit)
        guard !episodes.isEmpty else { return 0 }
        let total = episodes.reduce(0.0) { $0 + $1.quantity }
        return total / Double(episodes.count)
    }

    // MARK: - Resilience Rate

    /// Fraction of craving entries in the last 7 days where the outcome was
    /// "resisted". Returns 1.0 if there are no craving entries.
    static func resilienceRate(for habit: CDHabit) -> Double {
        let recentEntries = cravingEntriesInLast7Days(for: habit)
        guard !recentEntries.isEmpty else { return 1.0 }
        let resistedCount = recentEntries.filter { $0.outcome == "resisted" }.count
        return Double(resistedCount) / Double(recentEntries.count)
    }

    // MARK: - Improvement vs Baseline

    /// `(habit.dailyUnits - rolling7dQuantityAvg) / habit.dailyUnits`, clamped
    /// to 0...1. Returns 0 if dailyUnits is 0.
    static func improvementVsBaseline(for habit: CDHabit) -> Double {
        guard habit.dailyUnits > 0 else { return 0 }
        let avg = rolling7dQuantityAvg(for: habit)
        let improvement = (habit.dailyUnits - avg) / habit.dailyUnits
        return min(max(improvement, 0), 1)
    }

    // MARK: - Private Helpers

    /// Returns all CDCravingEntry records for the habit from the last 7 days
    /// with `eventType == "USE_EPISODE"`.
    private static func useEpisodesInLast7Days(for habit: CDHabit) -> [CDCravingEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        guard let entries = habit.cravingEntries as? Set<CDCravingEntry> else { return [] }
        return entries.filter { $0.eventType == "USE_EPISODE" && $0.timestamp >= cutoff }
    }

    /// Returns all CDCravingEntry records for the habit from the last 7 days
    /// (regardless of event type).
    private static func cravingEntriesInLast7Days(for habit: CDHabit) -> [CDCravingEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        guard let entries = habit.cravingEntries as? Set<CDCravingEntry> else { return [] }
        return entries.filter { $0.timestamp >= cutoff }
    }
}
