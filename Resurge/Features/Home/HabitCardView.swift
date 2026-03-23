import SwiftUI
import CoreData

struct HabitCardView: View {

    @ObservedObject var habit: CDHabit

    private var programType: ProgramType {
        ProgramType(rawValue: habit.programType) ?? .smoking
    }

    private var progress: Double {
        guard habit.goalDays > 0 else { return 0 }
        return min(Double(habit.daysSoberCount) / Double(habit.goalDays), 1.0)
    }

    var body: some View {
        VStack(spacing: AppStyle.spacing) {
            // Top row: name + icon
            HStack {
                Image(systemName: habit.iconName ?? programType.iconName)
                    .font(.title3)
                    .foregroundColor(.primaryTeal)

                Text(habit.safeDisplayName)
                    .font(Typography.headline)
                    .foregroundColor(.appText)

                Spacer()

                Text(programType.displayName)
                    .font(Typography.badge)
                    .foregroundColor(.primaryTeal)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primaryTeal.opacity(0.1))
                    .cornerRadius(8)
            }

            // Progress ring + days count
            HStack(spacing: AppStyle.largeSpacing) {
                ProgressRingView(
                    progress: progress,
                    lineWidth: AppStyle.progressRingLineWidth,
                    size: AppStyle.progressRingSize
                ) {
                    VStack(spacing: 2) {
                        Text("\(habit.daysSoberCount)")
                            .font(Typography.statValue)
                            .foregroundColor(.appText)
                        Text("days")
                            .font(Typography.statLabel)
                            .foregroundColor(.subtleText)
                    }
                }

                VStack(alignment: .leading, spacing: AppStyle.spacing) {
                    // Health progress
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.neonGreen)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(habit.currentStreak) day streak")
                                .font(Typography.headline)
                                .foregroundColor(.appText)
                            Text("going strong")
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)
                        }
                    }

                    // Time saved
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.primaryTeal)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formattedTimeSaved)
                                .font(Typography.headline)
                                .foregroundColor(.appText)
                            Text("reclaimed")
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)
                        }
                    }
                }

                Spacer()
            }

            // View Details link
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("View Details")
                        .font(Typography.callout)
                        .foregroundColor(.primaryTeal)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.primaryTeal)
                }
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12, x: 0, y: 4)
    }

    // MARK: - Helpers

    private var formattedTimeSaved: String {
        let totalMinutes = habit.timeSavedMinutes
        let hours = Int(totalMinutes) / 60
        let minutes = Int(totalMinutes) % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Preview

struct HabitCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit.create(
            in: context,
            name: "Smoking",
            programType: ProgramType.smoking.rawValue,
            startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            goalDays: 30,
            costPerUnit: 0.50,
            timePerUnit: 10,
            dailyUnits: 10
        )

        HabitCardView(habit: habit)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
