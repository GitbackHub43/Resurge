import SwiftUI
import CoreData

struct GoalLadderView: View {
    @ObservedObject var habit: CDHabit
    @AppStorage("isPremium") private var isPremium: Bool = false

    @FetchRequest private var unlocks: FetchedResults<CDAchievementUnlock>

    init(habit: CDHabit) {
        self.habit = habit
        _unlocks = FetchRequest<CDAchievementUnlock>(
            sortDescriptors: [NSSortDescriptor(keyPath: \CDAchievementUnlock.unlockedAt, ascending: false)],
            predicate: NSPredicate(format: "habit == %@", habit)
        )
    }

    private var unlockedKeys: Set<String> {
        Set(unlocks.map { $0.achievementKey })
    }

    // MARK: - Health Milestones

    private struct HealthGoal: Identifiable {
        let id = UUID()
        let title: String
        let iconName: String
        let requiredDays: Int
        let isPremium: Bool
    }

    private let healthGoals: [HealthGoal] = [
        HealthGoal(title: "First Health Win", iconName: "heart.circle.fill", requiredDays: 7, isPremium: false),
        HealthGoal(title: "Body Healing", iconName: "cross.circle.fill", requiredDays: 30, isPremium: true),
        HealthGoal(title: "Mind Clearing", iconName: "brain.head.profile", requiredDays: 90, isPremium: true),
        HealthGoal(title: "Life Transformed", iconName: "figure.mind.and.body", requiredDays: 180, isPremium: true)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppStyle.largeSpacing) {
                // MARK: - Time Milestones
                milestoneSection(
                    title: "Time Milestones",
                    icon: "clock.fill",
                    badges: MilestoneBadge.timeBadges,
                    currentValue: habit.daysSoberCount,
                    unit: "days"
                )

                // MARK: - Streak Milestones
                milestoneSection(
                    title: "Streak Milestones",
                    icon: "flame.fill",
                    badges: MilestoneBadge.streakBadges,
                    currentValue: habit.currentStreak,
                    unit: "days"
                )

                // MARK: - Behavior Milestones
                behaviorSection()

                // MARK: - Health Milestones
                healthSection()
            }
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.vertical, AppStyle.spacing)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Goal Ladder")
    }

    // MARK: - Milestone Section (Time & Streak)

    @ViewBuilder
    private func milestoneSection(
        title: String,
        icon: String,
        badges: [MilestoneBadge],
        currentValue: Int,
        unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            sectionHeader(title: title, icon: icon)

            ForEach(badges) { badge in
                let achieved = currentValue >= badge.requiredDays
                milestoneRow(
                    iconName: badge.iconName,
                    title: badge.title,
                    description: badge.description,
                    achieved: achieved,
                    progressText: "\(min(currentValue, badge.requiredDays))/\(badge.requiredDays) \(unit)",
                    isPremiumBadge: badge.isPremium
                )
            }
        }
    }

    // MARK: - Behavior Section

    @ViewBuilder
    private func behaviorSection() -> some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            sectionHeader(title: "Behavior Milestones", icon: "star.fill")

            ForEach(MilestoneBadge.behaviorBadges) { badge in
                let achieved = unlockedKeys.contains(badge.key)
                milestoneRow(
                    iconName: badge.iconName,
                    title: badge.title,
                    description: badge.description,
                    achieved: achieved,
                    progressText: achieved ? "" : "Locked",
                    isPremiumBadge: badge.isPremium
                )
            }
        }
    }

    // MARK: - Health Section

    @ViewBuilder
    private func healthSection() -> some View {
        let days = habit.daysSoberCount

        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            sectionHeader(title: "Health Milestones", icon: "heart.fill")

            ForEach(healthGoals) { goal in
                let achieved = days >= goal.requiredDays
                milestoneRow(
                    iconName: goal.iconName,
                    title: goal.title,
                    description: "\(min(days, goal.requiredDays)) of \(goal.requiredDays) days",
                    achieved: achieved,
                    progressText: achieved ? "" : "\(days)/\(goal.requiredDays) days",
                    isPremiumBadge: goal.isPremium
                )
            }
        }
    }

    // MARK: - Section Header

    @ViewBuilder
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.neonCyan)
            Text(title)
                .font(Typography.headline)
                .foregroundColor(.appText)
                .rainbowText()
        }
        .padding(.top, 4)
    }

    // MARK: - Milestone Row

    @ViewBuilder
    private func milestoneRow(
        iconName: String,
        title: String,
        description: String,
        achieved: Bool,
        progressText: String,
        isPremiumBadge: Bool
    ) -> some View {
        HStack(spacing: AppStyle.spacing) {
            ZStack {
                Circle()
                    .fill(achieved ? Color.neonPurple.opacity(0.15) : Color.subtleText.opacity(0.08))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(achieved ? .neonCyan : .subtleText.opacity(0.4))
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(Typography.callout.weight(.semibold))
                        .foregroundColor(achieved ? .appText : .subtleText)

                    if isPremiumBadge && !isPremium {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.premiumGold)
                    }
                }

                Text(description)
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
                    .lineLimit(2)
            }

            Spacer()

            if achieved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.neonGreen)
            } else {
                Text(progressText)
                    .font(Typography.caption.weight(.medium))
                    .foregroundColor(.subtleText)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    achieved
                        ? LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: achieved ? 1 : 0
                )
                .opacity(0.4)
        )
        .shadow(color: achieved ? Color.neonPurple.opacity(0.12) : Color.clear, radius: 12)
    }
}

// MARK: - Preview

struct GoalLadderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit(context: context)
        habit.id = UUID()
        habit.name = "Quit Smoking"
        habit.programType = "smoking"
        habit.startDate = Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()
        habit.goalDays = 90
        habit.baselineCostPerDay = 10.0
        habit.isActive = true
        habit.createdAt = Date()
        habit.updatedAt = Date()

        return NavigationView {
            GoalLadderView(habit: habit)
        }
        .preferredColorScheme(.dark)
    }
}
