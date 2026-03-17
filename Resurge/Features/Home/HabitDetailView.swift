import SwiftUI
import CoreData

struct HabitDetailView: View {

    @ObservedObject var habit: CDHabit
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var showEditHabit = false
    @State private var showDeleteAlert = false

    private var programType: ProgramType {
        ProgramType(rawValue: habit.programType) ?? .smoking
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Sobriety counter
                VStack(spacing: 8) {
                    Text(programType.tagline)
                        .font(Typography.callout)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)

                    SobrietyCounterView(startDate: habit.startDate)

                    Text("free from \(habit.name.lowercased())")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .padding(AppStyle.cardPadding)
                .frame(maxWidth: .infinity)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .shadow(
                    color: AppStyle.cardShadow.color,
                    radius: AppStyle.cardShadow.radius,
                    x: AppStyle.cardShadow.x,
                    y: AppStyle.cardShadow.y
                )
                .padding(.horizontal, AppStyle.screenPadding)

                // Stats cards
                HStack(spacing: AppStyle.spacing) {
                    detailStatCard(
                        icon: "heart.fill",
                        iconColor: .neonGreen,
                        value: "\(habit.daysSoberCount)",
                        label: "Days Strong"
                    )

                    detailStatCard(
                        icon: "clock.fill",
                        iconColor: .primaryTeal,
                        value: formattedTimeSaved,
                        label: "Life Reclaimed"
                    )
                }
                .padding(.horizontal, AppStyle.screenPadding)

                // Progress toward goal
                progressCard
                    .padding(.horizontal, AppStyle.screenPadding)

                // Health timeline
                healthTimelineCard
                    .padding(.horizontal, AppStyle.screenPadding)

                // Quick actions
                quickActionsSection
                    .padding(.horizontal, AppStyle.screenPadding)

                // Reason to quit
                if let reason = habit.reasonToQuit, !reason.isEmpty {
                    reasonCard(reason)
                        .padding(.horizontal, AppStyle.screenPadding)
                }
            }
            .padding(.vertical, AppStyle.spacing)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showEditHabit = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.primaryTeal)
                }
            }
        }
        .sheet(isPresented: $showEditHabit) {
            AddEditHabitView(mode: .edit(habit))
                .environmentObject(environment)
                .environment(\.managedObjectContext, viewContext)
        }
        .alert("Delete Habit", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                environment.habitRepository.delete(habit)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(habit.name)\"? This action cannot be undone.")
        }
    }

    // MARK: - Stat Card

    private func detailStatCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)

            Text(value)
                .font(Typography.statValue)
                .foregroundColor(.appText)

            Text(label)
                .font(Typography.statLabel)
                .foregroundColor(.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .shadow(
            color: AppStyle.cardShadow.color,
            radius: AppStyle.cardShadow.radius,
            x: AppStyle.cardShadow.x,
            y: AppStyle.cardShadow.y
        )
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        VStack(spacing: AppStyle.spacing) {
            HStack {
                Text("Goal Progress")
                    .font(Typography.headline)
                    .foregroundColor(.appText)
                Spacer()
                Text("\(habit.daysSoberCount) / \(habit.goalDays) days")
                    .font(Typography.callout)
                    .foregroundColor(.subtleText)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.neonPurple.opacity(0.1))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progressFraction, height: 12)
                        .animation(.easeInOut, value: progressFraction)
                }
            }
            .frame(height: 12)

            Text(progressMessage)
                .font(Typography.caption)
                .foregroundColor(.subtleText)
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .shadow(
            color: AppStyle.cardShadow.color,
            radius: AppStyle.cardShadow.radius,
            x: AppStyle.cardShadow.x,
            y: AppStyle.cardShadow.y
        )
    }

    private var progressFraction: CGFloat {
        guard habit.goalDays > 0 else { return 0 }
        return min(CGFloat(habit.daysSoberCount) / CGFloat(habit.goalDays), 1.0)
    }

    private var progressMessage: String {
        let remaining = Int(habit.goalDays) - habit.daysSoberCount
        if remaining <= 0 {
            return "You have reached your goal! Consider setting a new one."
        }
        return "\(remaining) days remaining. You are doing great!"
    }

    // MARK: - Health Timeline

    private var healthTimelineCard: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text("Health Timeline")
                .font(Typography.headline)
                .foregroundColor(.appText)

            ForEach(realMilestones) { milestone in
                HStack(spacing: AppStyle.spacing) {
                    let milestoneDays = milestone.requiredMinutes / 1440
                    Image(systemName: habit.daysSoberCount >= milestoneDays ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(habit.daysSoberCount >= milestoneDays ? .primaryTeal : .subtleText.opacity(0.4))
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(milestone.title)
                            .font(Typography.callout)
                            .foregroundColor(habit.daysSoberCount >= milestoneDays ? .appText : .subtleText)

                        Text(milestone.description)
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }

                    Spacer()

                    Text(milestone.timeDescription)
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .shadow(
            color: AppStyle.cardShadow.color,
            radius: AppStyle.cardShadow.radius,
            x: AppStyle.cardShadow.x,
            y: AppStyle.cardShadow.y
        )
    }

    private var realMilestones: [HealthMilestone] {
        HealthMilestone.milestones(for: programType)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            Text("Quick Actions")
                .font(Typography.headline)
                .foregroundColor(.appText)

            HStack(spacing: AppStyle.spacing) {
                quickActionButton(icon: "flame.fill", label: "Log Craving", color: .accentOrange)
                quickActionButton(icon: "book.fill", label: "Journal", color: .primaryTeal)
                quickActionButton(icon: "wrench.and.screwdriver.fill", label: "Tools", color: .premiumGold)
            }
        }
    }

    private func quickActionButton(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(label)
                .font(Typography.caption)
                .foregroundColor(.appText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppStyle.spacing)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .shadow(
            color: AppStyle.cardShadow.color,
            radius: AppStyle.cardShadow.radius,
            x: AppStyle.cardShadow.x,
            y: AppStyle.cardShadow.y
        )
    }

    // MARK: - Reason Card

    private func reasonCard(_ reason: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.accentOrange)
                Text("Your Why")
                    .font(Typography.headline)
                    .foregroundColor(.appText)
            }

            Text(reason)
                .font(Typography.body)
                .foregroundColor(.subtleText)
        }
        .padding(AppStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentOrange.opacity(0.06))
        .cornerRadius(AppStyle.cornerRadius)
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

struct HabitDetailView_Previews: PreviewProvider {
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
            dailyUnits: 10,
            reasonToQuit: "I want to breathe freely and be healthy for my family."
        )

        NavigationView {
            HabitDetailView(habit: habit)
        }
        .environmentObject(AppEnvironment.preview)
        .environment(\.managedObjectContext, context)
    }
}
