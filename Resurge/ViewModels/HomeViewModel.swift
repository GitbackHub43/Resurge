import SwiftUI
import CoreData

final class HomeViewModel: ObservableObject {
    @Published var showAddHabit = false
    @Published var showLogLapse = false
    @Published var selectedHabit: CDHabit?
    @Published var hasPledgedToday = false
    @Published var pledgeText = ""

    private let habitRepository: HabitRepositoryProtocol
    private let logRepository: LogRepositoryProtocol
    private let entitlements: EntitlementManager

    init(habitRepository: HabitRepositoryProtocol,
         logRepository: LogRepositoryProtocol,
         entitlements: EntitlementManager) {
        self.habitRepository = habitRepository
        self.logRepository = logRepository
        self.entitlements = entitlements
    }

    var canAddHabit: Bool {
        let count = habitRepository.fetchActive().count
        return entitlements.canAddHabit(currentCount: count)
    }

    var totalMoneySaved: Double {
        habitRepository.fetchActive().reduce(0) { $0 + $1.moneySaved }
    }

    var totalDaysSober: Int {
        habitRepository.fetchActive().reduce(0) { $0 + $1.daysSoberCount }
    }

    func submitPledge(for habit: CDHabit) {
        let log = logRepository.fetchLog(for: habit, date: Date())
            ?? logRepository.createLog(habit: habit, date: Date())
        logRepository.updatePledge(log: log, text: pledgeText)
        hasPledgedToday = true
    }

    func logLapse(for habit: CDHabit, notes: String) {
        let log = logRepository.fetchLog(for: habit, date: Date())
            ?? logRepository.createLog(habit: habit, date: Date())
        logRepository.logLapse(log: log, notes: notes)
    }
}
