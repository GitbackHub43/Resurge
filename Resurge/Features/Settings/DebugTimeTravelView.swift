import SwiftUI
import CoreData

/// DEBUG ONLY — Lets you change a habit's start date to simulate time passing.
/// Set the start date back 90 days to test if 90-day badges unlock, etc.
/// REMOVE before App Store submission.
struct DebugTimeTravelView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var activeHabits: FetchedResults<CDHabit>

    @State private var selectedHabitIndex: Int = 0
    @State private var showConfirmation = false
    @State private var lastAction = ""

    private var selectedHabit: CDHabit? {
        guard !activeHabits.isEmpty else { return nil }
        return activeHabits[min(selectedHabitIndex, activeHabits.count - 1)]
    }

    private let timeJumps: [(label: String, days: Int)] = [
        ("1 Day Ago", 1),
        ("3 Days Ago", 3),
        ("7 Days Ago", 7),
        ("14 Days Ago", 14),
        ("30 Days Ago", 30),
        ("60 Days Ago", 60),
        ("90 Days Ago", 90),
        ("180 Days Ago", 180),
        ("270 Days Ago", 270),
        ("365 Days Ago", 365),
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.neonOrange)

                        Text("Time Travel")
                            .font(Typography.largeTitle)
                            .rainbowText()

                        Text("Set your habit's start date back in time to test badges, streaks, and milestones.")
                            .font(Typography.body)
                            .foregroundColor(.subtleText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppStyle.largeSpacing)

                    // Habit selector
                    if activeHabits.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(activeHabits.enumerated()), id: \.element.id) { index, habit in
                                    Button {
                                        selectedHabitIndex = index
                                    } label: {
                                        Text(habit.name)
                                            .font(Typography.caption.weight(.semibold))
                                            .foregroundColor(selectedHabitIndex == index ? .white : .subtleText)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 7)
                                            .background(
                                                selectedHabitIndex == index
                                                    ? AnyView(Color.accentGradient)
                                                    : AnyView(Color.cardBackground)
                                            )
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }

                    // Current status
                    if let habit = selectedHabit {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Current Start Date:")
                                    .font(Typography.caption)
                                    .foregroundColor(.subtleText)
                                Spacer()
                                Text(habit.startDate, style: .date)
                                    .font(Typography.headline)
                                    .foregroundColor(.neonCyan)
                            }
                            HStack {
                                Text("Days Sober:")
                                    .font(Typography.caption)
                                    .foregroundColor(.subtleText)
                                Spacer()
                                Text("\(habit.daysSoberCount)")
                                    .font(Typography.headline)
                                    .foregroundColor(.neonGreen)
                            }
                            HStack {
                                Text("Current Streak:")
                                    .font(Typography.caption)
                                    .foregroundColor(.subtleText)
                                Spacer()
                                Text("\(habit.currentStreak)")
                                    .font(Typography.headline)
                                    .foregroundColor(.neonOrange)
                            }
                        }
                        .padding(AppStyle.cardPadding)
                        .background(Color.cardBackground)
                        .cornerRadius(AppStyle.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                                .stroke(Color.cardBorder, lineWidth: 1)
                        )
                    }

                    // Time jump buttons
                    VStack(spacing: 10) {
                        Text("Set start date to:")
                            .font(Typography.headline)
                            .foregroundColor(.appText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(timeJumps, id: \.days) { jump in
                            Button {
                                setStartDate(daysAgo: jump.days)
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(.neonOrange)
                                    Text(jump.label)
                                        .font(Typography.body)
                                        .foregroundColor(.appText)
                                    Spacer()
                                    Text("\(jump.days)d")
                                        .font(Typography.caption)
                                        .foregroundColor(.subtleText)
                                }
                                .padding(12)
                                .background(Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(Color.cardBorder, lineWidth: 1)
                                )
                            }
                        }

                        // Reset to today
                        Button {
                            setStartDate(daysAgo: 0)
                        } label: {
                            HStack {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.neonMagenta)
                                Text("Reset to Today")
                                    .font(Typography.body)
                                    .foregroundColor(.neonMagenta)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.neonMagenta.opacity(0.08))
                            .cornerRadius(AppStyle.smallCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                    .stroke(Color.neonMagenta.opacity(0.3), lineWidth: 1)
                            )
                        }

                        // Re-evaluate badges button
                        Button {
                            evaluateBadges()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Re-evaluate All Badges")
                            }
                        }
                        .buttonStyle(RainbowButtonStyle())
                        .padding(.top, 8)
                    }

                    // Confirmation toast
                    if showConfirmation {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.neonGreen)
                            Text(lastAction)
                                .font(Typography.caption)
                                .foregroundColor(.neonGreen)
                        }
                        .padding(12)
                        .background(Color.neonGreen.opacity(0.1))
                        .cornerRadius(12)
                        .transition(.opacity)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, AppStyle.screenPadding)
            }
        }
        .navigationTitle("Time Travel")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setStartDate(daysAgo: Int) {
        guard let habit = selectedHabit else { return }
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: Date())) ?? Date()
        habit.startDate = newDate
        habit.updatedAt = Date()
        try? viewContext.save()

        // Immediately evaluate badges for all habits
        for h in activeHabits {
            environment.achievementService.evaluate(for: h)
        }

        // Force Core Data to push changes to all @FetchRequest views
        viewContext.refreshAllObjects()

        lastAction = daysAgo == 0 ? "Reset to today" : "Set to \(daysAgo) days ago — badges evaluated"
        withAnimation { showConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showConfirmation = false }
        }
    }

    private func evaluateBadges() {
        for habit in activeHabits {
            environment.achievementService.evaluate(for: habit)
        }
        viewContext.refreshAllObjects()
        lastAction = "Badges re-evaluated for all habits"
        withAnimation { showConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showConfirmation = false }
        }
    }
}
