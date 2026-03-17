import SwiftUI
import CoreData

final class AnalyticsViewModel: ObservableObject {
    @Published var selectedHabit: CDHabit?
    @Published var triggerData: [(String, Int)] = []
    @Published var toolData: [(String, Double)] = []
    @Published var weekComparison: (thisWeek: Int, lastWeek: Int) = (0, 0)
    @Published var moodTrend: [(Date, Int)] = []

    private let insightsService: InsightsServiceProtocol

    init(insightsService: InsightsServiceProtocol) {
        self.insightsService = insightsService
    }

    func loadData(for habit: CDHabit) {
        selectedHabit = habit
        triggerData = insightsService.triggerFrequency(for: habit)
        toolData = insightsService.toolEffectiveness(for: habit)
        weekComparison = insightsService.weekOverWeek(for: habit)
        moodTrend = insightsService.moodTrend(for: habit, days: 30)
    }

    var triggerChartData: [ChartDataPoint] {
        triggerData.prefix(8).map { ChartDataPoint(label: $0.0, value: Double($0.1)) }
    }

    var toolChartData: [ChartDataPoint] {
        toolData.prefix(8).map { ChartDataPoint(label: $0.0, value: $0.1 * 100) }
    }

    var weekChangePercent: Double {
        guard weekComparison.lastWeek > 0 else { return 0 }
        return Double(weekComparison.thisWeek - weekComparison.lastWeek) / Double(weekComparison.lastWeek) * 100
    }
}
