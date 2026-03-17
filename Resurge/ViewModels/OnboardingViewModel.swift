import SwiftUI
import CoreData

final class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var habitName = ""
    @Published var selectedProgram: ProgramType = .smoking
    @Published var startDate = Date()
    @Published var dailyUnits: Double = 10
    @Published var costPerUnit: Double = 0.50
    @Published var timePerUnit: Double = 5
    @Published var reasonToQuit = ""
    @Published var goalPeriod: GoalPeriod = .oneMonth
    @Published var notificationsEnabled = false

    let totalSteps = 5

    enum GoalPeriod: String, CaseIterable, Identifiable {
        case oneWeek = "1 Week"
        case oneMonth = "1 Month"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case oneYear = "1 Year"

        var id: String { rawValue }
        var days: Int {
            switch self {
            case .oneWeek: return 7
            case .oneMonth: return 30
            case .threeMonths: return 90
            case .sixMonths: return 180
            case .oneYear: return 365
            }
        }
    }

    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation { currentStep += 1 }
        }
    }

    func previousStep() {
        if currentStep > 0 {
            withAnimation { currentStep -= 1 }
        }
    }

    func createHabit(using repository: HabitRepositoryProtocol) {
        _ = repository.create(
            name: habitName.isEmpty ? selectedProgram.displayName : habitName,
            programType: selectedProgram,
            startDate: startDate,
            goalDays: goalPeriod.days,
            costPerUnit: costPerUnit,
            timePerUnit: timePerUnit,
            dailyUnits: dailyUnits,
            reasonToQuit: reasonToQuit.isEmpty ? nil : reasonToQuit
        )
    }
}
