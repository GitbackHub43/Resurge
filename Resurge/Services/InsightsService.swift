import Foundation
import CoreData

// MARK: - InsightsServiceProtocol

protocol InsightsServiceProtocol {
    func triggerFrequency(for habit: CDHabit) -> [(String, Int)]
    func moodTrend(for habit: CDHabit, days: Int) -> [(Date, Int)]
    func toolEffectiveness(for habit: CDHabit) -> [(String, Double)]
    func weekOverWeek(for habit: CDHabit) -> (thisWeek: Int, lastWeek: Int)
}

// MARK: - InsightsService

final class InsightsService: InsightsServiceProtocol {

    private let cravingRepository: CravingRepositoryProtocol
    private let logRepository: LogRepositoryProtocol

    init(cravingRepository: CravingRepositoryProtocol, logRepository: LogRepositoryProtocol) {
        self.cravingRepository = cravingRepository
        self.logRepository = logRepository
    }

    // MARK: - Trigger Frequency

    /// Returns an array of (triggerCategory, count) sorted by count descending.
    func triggerFrequency(for habit: CDHabit) -> [(String, Int)] {
        let cravings = cravingRepository.fetchAll(for: habit)
        var frequency: [String: Int] = [:]
        for craving in cravings {
            let trigger = craving.triggerCategory ?? "Unknown"
            frequency[trigger, default: 0] += 1
        }
        return frequency.sorted { $0.value > $1.value }
    }

    // MARK: - Mood Trend

    /// Returns an array of (date, moodRawValue) for the last N days, sorted chronologically.
    func moodTrend(for habit: CDHabit, days: Int) -> [(Date, Int)] {
        let logs = logRepository.fetchLogs(for: habit)
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let filtered = logs
            .filter { $0.date >= cutoff }
            .sorted { $0.date < $1.date }

        return filtered.map { (calendar.startOfDay(for: $0.date), Int($0.mood)) }
    }

    // MARK: - Tool Effectiveness

    /// Returns an array of (toolName, resistRate) where resistRate is 0.0–1.0.
    /// A higher rate means the tool was more effective at resisting cravings.
    func toolEffectiveness(for habit: CDHabit) -> [(String, Double)] {
        let cravings = cravingRepository.fetchAll(for: habit)
        var toolUses: [String: (total: Int, resisted: Int)] = [:]

        for craving in cravings {
            guard let tool = craving.copingToolUsed, !tool.isEmpty else { continue }
            var record = toolUses[tool, default: (total: 0, resisted: 0)]
            record.total += 1
            if craving.didResist {
                record.resisted += 1
            }
            toolUses[tool] = record
        }

        return toolUses.map { (tool, record) in
            let rate = record.total > 0 ? Double(record.resisted) / Double(record.total) : 0.0
            return (tool, rate)
        }.sorted { $0.1 > $1.1 }
    }

    // MARK: - Week Over Week

    /// Returns the craving count for the current week vs. last week.
    func weekOverWeek(for habit: CDHabit) -> (thisWeek: Int, lastWeek: Int) {
        let cravings = cravingRepository.fetchAll(for: habit)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let startOfThisWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfThisWeek) else {
            return (thisWeek: 0, lastWeek: 0)
        }

        var thisWeekCount = 0
        var lastWeekCount = 0

        for craving in cravings {
            let ts = craving.timestamp
            if ts >= startOfThisWeek {
                thisWeekCount += 1
            } else if ts >= startOfLastWeek && ts < startOfThisWeek {
                lastWeekCount += 1
            }
        }

        return (thisWeek: thisWeekCount, lastWeek: lastWeekCount)
    }
}
