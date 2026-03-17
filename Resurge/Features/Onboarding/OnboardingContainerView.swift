import SwiftUI
import CoreData

struct OnboardingContainerView: View {

    let onComplete: () -> Void

    @EnvironmentObject var environment: AppEnvironment
    @State private var currentStep = 0

    // Shared onboarding state
    @State private var habitName = ""
    @State private var selectedProgramType: ProgramType = .smoking
    @State private var startDate = Date()
    @State private var dailyUnits: Double = 10
    @State private var reasonToQuit = ""
    @State private var goalPeriod: GoalPeriod = .oneMonth
    @State private var programSetupValues: [String: String] = [:]
    @State private var isGoingForward = true

    private let totalSteps = 8

    var body: some View {
        VStack(spacing: 0) {
            // Step content (no swipe — controlled only by buttons)
            Group {
                switch currentStep {
                case 0:
                    WelcomeView(onNext: { advanceStep() })
                case 1:
                    TimezoneSetupView()
                case 2:
                    AddHabitOnboardingView(
                        habitName: $habitName,
                        selectedProgramType: $selectedProgramType,
                        startDate: $startDate,
                        dailyUnits: $dailyUnits,
                        onNext: { advanceStep() }
                    )
                case 3:
                    ProgramSetupView(
                        programType: selectedProgramType,
                        setupValues: $programSetupValues,
                        startDate: $startDate,
                        onNext: { advanceStep() }
                    )
                case 4:
                    WhyGoalsView(
                        reasonToQuit: $reasonToQuit,
                        goalPeriod: $goalPeriod,
                        onNext: { advanceStep() }
                    )
                case 5:
                    NotificationSetupView(
                        notificationManager: environment.notificationManager,
                        onNext: { advanceStep() }
                    )
                case 6:
                    SubscriptionOfferView(onNext: {
                        advanceStep()
                    })
                case 7:
                    SurgesIntroView(onNext: {
                        saveHabitAndFinish()
                    })
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            .transition(.asymmetric(
                insertion: .move(edge: isGoingForward ? .trailing : .leading),
                removal: .move(edge: isGoingForward ? .leading : .trailing)
            ))

            // Bottom bar: Back button + dots + Next button
            if currentStep > 0 && currentStep < 6 {
                bottomNavBar
            } else {
                // Welcome (0), Subscription (6), and Surges intro (7) have their own buttons
                progressDots
                    .padding(.bottom, AppStyle.largeSpacing)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Bottom Navigation Bar

    private var bottomNavBar: some View {
        VStack(spacing: AppStyle.spacing) {
            progressDots

            HStack(spacing: AppStyle.spacing) {
                // Back button
                Button {
                    dismissKeyboard()
                    goBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonPurple))

                // Next button
                Button {
                    dismissKeyboard()
                    advanceStep()
                } label: {
                    HStack(spacing: 4) {
                        Text(currentStep == 4 ? "Finish" : "Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
                .disabled(!canProceed)
                .opacity(canProceed ? 1.0 : 0.5)
            }
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
    }

    // MARK: - Can Proceed (validation per step)

    private var canProceed: Bool {
        switch currentStep {
        case 1:
            // Timezone — always allow
            return true
        case 2:
            // Choose habit — always true since default is .smoking
            return true
        case 3:
            // Program setup (Customize Your Plan) — always allow (has defaults)
            return true
        case 4:
            // Your Why + Goals — must have a reason
            return !reasonToQuit.trimmingCharacters(in: .whitespaces).isEmpty
        case 5:
            // Notifications — always allow
            return true
        default:
            return true
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                let colors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold, .neonGreen, .neonGold]
                Circle()
                    .fill(index <= currentStep ? colors[index % colors.count] : Color.neonPurple.opacity(0.2))
                    .frame(width: index == currentStep ? 10 : 8,
                           height: index == currentStep ? 10 : 8)
                    .shadow(color: index == currentStep ? colors[index % colors.count].opacity(0.6) : .clear, radius: 4, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
        .padding(.top, AppStyle.spacing)
    }

    // MARK: - Helpers

    private func advanceStep() {
        dismissKeyboard()
        isGoingForward = true
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = min(currentStep + 1, totalSteps - 1)
        }
    }

    private func goBack() {
        dismissKeyboard()
        isGoingForward = false
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = max(currentStep - 1, 0)
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func saveHabitAndFinish() {
        let goalDays: Int
        switch goalPeriod {
        case .oneWeek:      goalDays = 7
        case .oneMonth:     goalDays = 30
        case .threeMonths:  goalDays = 90
        case .sixMonths:    goalDays = 180
        case .oneYear:      goalDays = 365
        }

        environment.habitRepository.create(
            name: habitName.isEmpty ? selectedProgramType.displayName : habitName,
            programType: selectedProgramType,
            startDate: startDate,
            goalDays: goalDays,
            costPerUnit: 0,
            timePerUnit: 0,
            dailyUnits: dailyUnits,
            reasonToQuit: reasonToQuit.isEmpty ? nil : reasonToQuit
        )

        onComplete()
    }
}

// MARK: - Goal Period

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

// MARK: - Preview

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView(onComplete: {})
            .environmentObject(AppEnvironment.preview)
    }
}
