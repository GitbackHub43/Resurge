import SwiftUI
import CoreData

struct AdvancedAnalyticsView: View {
    @EnvironmentObject var environment: AppEnvironment

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES")
    ) private var habits: FetchedResults<CDHabit>

    @State private var selectedHabitIndex: Int = 0
    @State private var showPremiumGate = false

    private var selectedHabit: CDHabit? {
        guard selectedHabitIndex < habits.count else { return nil }
        return habits[selectedHabitIndex]
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if !environment.entitlementManager.check(.advancedAnalytics) {
                    premiumLockedView
                } else if habits.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // MARK: - Habit Picker
                            if habits.count > 1 {
                                Picker("Habit", selection: $selectedHabitIndex) {
                                    ForEach(habits.indices, id: \.self) { idx in
                                        Text(habits[idx].name).tag(idx)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                            }

                            if let habit = selectedHabit {
                                // MARK: - Overview Cards
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                    AnalyticsCard(
                                        title: "Current Streak",
                                        value: "\(habit.currentStreak)",
                                        unit: "days",
                                        icon: "flame.fill",
                                        color: .neonOrange
                                    )
                                    AnalyticsCard(
                                        title: "Days Strong",
                                        value: "\(habit.daysSoberCount)",
                                        unit: "total",
                                        icon: "heart.fill",
                                        color: .neonGreen
                                    )
                                    AnalyticsCard(
                                        title: "Days Free",
                                        value: "\(habit.daysSoberCount)",
                                        unit: "days",
                                        icon: "calendar.badge.checkmark",
                                        color: .neonCyan
                                    )
                                    AnalyticsCard(
                                        title: "Time Saved",
                                        value: String(format: "%.0f", habit.timeSavedMinutes),
                                        unit: "min",
                                        icon: "clock.fill",
                                        color: .neonBlue
                                    )
                                }
                                .padding(.horizontal)

                                // MARK: - Navigation Links
                                VStack(spacing: 12) {
                                    NavigationLink {
                                        WeekOverWeekView()
                                            .environmentObject(environment)
                                    } label: {
                                        analyticsNavRow(
                                            icon: "chart.bar.fill",
                                            title: "Week Over Week",
                                            subtitle: "Compare this week vs last week"
                                        )
                                    }

                                    NavigationLink {
                                        TriggerEffectivenessView()
                                            .environmentObject(environment)
                                    } label: {
                                        analyticsNavRow(
                                            icon: "bolt.heart.fill",
                                            title: "Trigger Analysis",
                                            subtitle: "Your most common triggers"
                                        )
                                    }

                                    NavigationLink {
                                        ToolEffectivenessView()
                                            .environmentObject(environment)
                                    } label: {
                                        analyticsNavRow(
                                            icon: "wrench.and.screwdriver.fill",
                                            title: "Tool Effectiveness",
                                            subtitle: "Which coping tools work best"
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Analytics")
        }
    }

    // MARK: - Premium Locked

    private var premiumLockedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundColor(.premiumGold)
            Text("Advanced Analytics")
                .font(.title2.weight(.bold))
                .rainbowText()
            Text("Unlock deep insights into your recovery journey with a premium subscription.")
                .font(.subheadline)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                showPremiumGate = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Premium")
                }
            }
            .buttonStyle(RainbowButtonStyle())
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(Color.neonPurple.opacity(0.4))
            Text("No habits to analyze")
                .font(.headline)
                .foregroundColor(.appText)
            Text("Add a habit first to see your analytics.")
                .font(.subheadline)
                .foregroundColor(.subtleText)
        }
    }

    @ViewBuilder
    private func analyticsNavRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.neonPurple)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.appText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.subtleText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.subtleText)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Analytics Card

private struct AnalyticsCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)
            Text(title)
                .font(.caption)
                .foregroundColor(.subtleText)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Preview

struct AdvancedAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        AdvancedAnalyticsView()
            .environmentObject(env)
            .environment(\.managedObjectContext, env.viewContext)
    }
}
