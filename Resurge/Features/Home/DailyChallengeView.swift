import SwiftUI

struct DailyChallengeView: View {

    @EnvironmentObject var environment: AppEnvironment

    let daysSober: Int
    let programType: ProgramType

    @State private var isCompleted = false
    @State private var showCelebration = false
    @AppStorage private var lastCompletedChallengeDate: String

    // MARK: - Init

    init(daysSober: Int, programType: ProgramType) {
        self.daysSober = daysSober
        self.programType = programType
        _lastCompletedChallengeDate = AppStorage(wrappedValue: "", "lastCompletedChallengeDate_\(programType.rawValue)")
    }

    // MARK: - Computed

    private var challenge: DailyChallenge {
        DailyChallengeService.challengeForDay(daysSober, programType: programType)
    }

    private var phase: RecoveryPhase {
        RecoveryPhase.phase(for: daysSober)
    }

    private var hasCompletedToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return lastCompletedChallengeDate == formatter.string(from: Date())
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            if showCelebration {
                celebrationView
            } else {
                challengeCard
            }
        }
        .onAppear {
            isCompleted = hasCompletedToday
            showCelebration = hasCompletedToday
        }
    }

    // MARK: - Challenge Card

    private var challengeCard: some View {
        VStack(spacing: AppStyle.spacing) {
            // Phase badge
            phaseBadge

            // Icon
            Image(systemName: challenge.iconName)
                .font(.system(size: 36))
                .foregroundColor(.neonCyan)
                .shadow(color: .neonCyan.opacity(0.4), radius: 8, x: 0, y: 0)
                .padding(.top, 4)

            // Title
            Text(challenge.title)
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)

            // Description
            Text(challenge.description)
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Category
            HStack(spacing: 6) {
                Image(systemName: iconForPhase(phase))
                    .font(Typography.caption)
                Text(phase.displayName)
                    .font(Typography.caption)
            }
            .foregroundColor(.neonPurple)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.neonPurple.opacity(0.12))
            .cornerRadius(AppStyle.smallCornerRadius)

            // Complete button
            Button {
                completeChallenge()
            } label: {
                Text("Complete Challenge")
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.top, 4)
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Phase Badge

    private var phaseBadge: some View {
        Text("\(phase.displayName) Phase \u{2022} Day \(daysSober)")
            .font(Typography.caption)
            .foregroundColor(.neonGold)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.neonGold.opacity(0.12))
            .cornerRadius(AppStyle.smallCornerRadius)
    }

    // MARK: - Celebration View

    private var celebrationView: some View {
        VStack(spacing: AppStyle.spacing) {
            // Sparkle decorations
            HStack(spacing: 20) {
                Image(systemName: "sparkle")
                    .foregroundColor(.neonGold)
                Image(systemName: "star.fill")
                    .foregroundColor(.neonCyan)
                Image(systemName: "sparkle")
                    .foregroundColor(.neonMagenta)
            }
            .font(.title2)

            // Checkmark circle
            ZStack {
                Circle()
                    .fill(Color.neonGreen.opacity(0.15))
                    .frame(width: 80, height: 80)

                Circle()
                    .stroke(Color.neonGreen, lineWidth: 3)
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark")
                    .font(.system(size: 36).weight(.bold))
                    .foregroundColor(.neonGreen)
            }
            .shadow(color: .neonGreen.opacity(0.3), radius: 12, x: 0, y: 0)

            Text("Great work!")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("You completed today's challenge")
                .font(Typography.body)
                .foregroundColor(.textSecondary)

            Text(challenge.title)
                .font(Typography.callout)
                .foregroundColor(.neonCyan)
                .italic()

            // Completed indicator
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.neonGreen)
                Text("Completed")
                    .font(Typography.headline)
                    .foregroundColor(.neonGreen)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.neonGreen.opacity(0.1))
            .cornerRadius(AppStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                    .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
            )
            .padding(.top, 4)
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Actions

    private func completeChallenge() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        lastCompletedChallengeDate = formatter.string(from: Date())

        // Award companion XP for completing the challenge
        environment.companionService.addXP(15)

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isCompleted = true
            showCelebration = true
        }
    }

    // MARK: - Helpers

    private func iconForPhase(_ phase: RecoveryPhase) -> String {
        switch phase {
        case .detox:          return "bolt.fill"
        case .building:       return "hammer.fill"
        case .strengthening:  return "shield.fill"
        case .maintaining:    return "crown.fill"
        }
    }
}

// MARK: - Preview

struct DailyChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        DailyChallengeView(daysSober: 3, programType: .smoking)
            .environmentObject(AppEnvironment.preview)
            .background(Color.appBackground)
    }
}
