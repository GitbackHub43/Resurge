import SwiftUI
import CoreData

final class HabitDetailViewModel: ObservableObject {
    @Published var habit: CDHabit
    @Published var showEditSheet = false
    @Published var showCravingMode = false
    @Published var showJournalEditor = false
    @Published var showDeleteConfirmation = false

    private let habitRepository: HabitRepositoryProtocol
    private let logRepository: LogRepositoryProtocol
    private let achievementRepository: AchievementRepositoryProtocol

    init(habit: CDHabit,
         habitRepository: HabitRepositoryProtocol,
         logRepository: LogRepositoryProtocol,
         achievementRepository: AchievementRepositoryProtocol) {
        self.habit = habit
        self.habitRepository = habitRepository
        self.logRepository = logRepository
        self.achievementRepository = achievementRepository
    }

    var daysSober: Int { habit.daysSoberCount }
    var moneySaved: Double { habit.moneySaved }
    var timeSavedHours: Double { habit.timeSavedMinutes / 60.0 }
    var currentStreak: Int { habit.currentStreak }
    var progressToGoal: Double {
        guard habit.goalDays > 0 else { return 0 }
        return min(1.0, Double(daysSober) / Double(habit.goalDays))
    }

    var programTemplate: ProgramTemplate? {
        guard let pt = ProgramType(rawValue: habit.programType ?? "smoking") else { return nil }
        return ProgramTemplates.template(for: pt)
    }

    func deleteHabit() {
        habitRepository.delete(habit)
    }

    func checkAchievements() {
        let days = daysSober
        for badge in MilestoneBadge.allBadges {
            if days >= badge.requiredDays && !achievementRepository.hasUnlocked(habit: habit, key: badge.key) {
                _ = achievementRepository.unlock(habit: habit, key: badge.key)
            }
        }
    }
}
