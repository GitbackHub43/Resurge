import SwiftUI
import CoreData

final class CravingModeViewModel: ObservableObject {
    enum Step: Int, CaseIterable {
        case intensity, triggers, chooseTool, useTool, outcome
    }

    @Published var currentStep: Step = .intensity
    @Published var intensity: Double = 5
    @Published var selectedTriggers: Set<String> = []
    @Published var selectedTool: CravingToolKind = .breathing
    @Published var timerSeconds: Int = 0
    @Published var timerRunning = false
    @Published var didResist = true
    @Published var isComplete = false

    let habit: CDHabit
    private let cravingRepository: CravingRepositoryProtocol

    init(habit: CDHabit, cravingRepository: CravingRepositoryProtocol) {
        self.habit = habit
        self.cravingRepository = cravingRepository
    }

    func nextStep() {
        guard let nextIndex = Step(rawValue: currentStep.rawValue + 1) else {
            saveCraving()
            return
        }
        withAnimation { currentStep = nextIndex }
    }

    func previousStep() {
        guard let prev = Step(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation { currentStep = prev }
    }

    func saveCraving() {
        _ = cravingRepository.create(
            habit: habit,
            intensity: Int(intensity),
            trigger: selectedTriggers.joined(separator: ", "),
            tool: selectedTool.displayName,
            didResist: didResist,
            duration: timerSeconds,
            mood: 3
        )
        isComplete = true
    }
}
