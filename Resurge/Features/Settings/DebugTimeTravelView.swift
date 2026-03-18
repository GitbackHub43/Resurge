import SwiftUI
import CoreData
import UserNotifications

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
    @State private var testDelay: Int = 10

    private var selectedHabit: CDHabit? {
        guard !activeHabits.isEmpty else { return nil }
        return activeHabits[min(selectedHabitIndex, activeHabits.count - 1)]
    }

    private let timeJumps: [(label: String, days: Int)] = [
        ("+1 Day", 1),
        ("+3 Days", 3),
        ("+7 Days", 7),
        ("+14 Days", 14),
        ("+30 Days", 30),
        ("+60 Days", 60),
        ("+90 Days", 90),
        ("+180 Days", 180),
        ("+270 Days", 270),
        ("+365 Days", 365),
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

                    // Debug offset status
                    if DebugDate.offsetDays != 0 {
                        HStack {
                            Image(systemName: "clock.badge.exclamationmark")
                                .foregroundColor(.neonOrange)
                            Text("Simulated date: ")
                                .font(Typography.caption)
                                .foregroundColor(.neonOrange)
                            Text(DebugDate.now, style: .date)
                                .font(Typography.headline)
                                .foregroundColor(.neonOrange)
                            Spacer()
                        }
                        .padding(10)
                        .background(Color.neonOrange.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Current status
                    if let habit = selectedHabit {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Habit Start Date:")
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

                    // MARK: - Test Notifications

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Test Notifications")
                            .font(Typography.headline)
                            .foregroundColor(.neonOrange)

                        Text("Test each notification type. Minimize the app to see them as banners.")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)

                        // Quick test (5 + 8 seconds)
                        Button {
                            NotificationScheduler.fireTestNotification()
                            lastAction = "Test notifications scheduled! Check in 5-8 seconds."
                            showConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                Text("Quick Test (5s + 8s)")
                            }
                        }
                        .buttonStyle(RainbowButtonStyle())

                        // Test all 3 daily loop notifications
                        Button {
                            fireAllDailyLoopTest()
                            lastAction = "3 daily loop notifications: 10s, 15s, 20s"
                            showConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Test All 3 Daily Loop (10s apart)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.neonCyan.opacity(0.15))
                            .foregroundColor(.neonCyan)
                            .cornerRadius(12)
                        }

                        // Test motivational quotes
                        Button {
                            fireQuoteTest()
                            lastAction = "5 quote notifications: every 6 seconds"
                            showConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "quote.bubble.fill")
                                Text("Test 5 Motivational Quotes (6s apart)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.neonGold.opacity(0.15))
                            .foregroundColor(.neonGold)
                            .cornerRadius(12)
                        }

                        // Custom timer test
                        HStack(spacing: 10) {
                            Text("Custom delay:")
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)
                            Picker("", selection: $testDelay) {
                                Text("10s").tag(10)
                                Text("30s").tag(30)
                                Text("1m").tag(60)
                                Text("5m").tag(300)
                            }
                            .pickerStyle(.segmented)
                        }

                        Button {
                            fireCustomTimerTest()
                            lastAction = "Notification in \(testDelay) seconds"
                            showConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "timer")
                                Text("Fire Custom Timer")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.neonPurple.opacity(0.15))
                            .foregroundColor(.neonPurple)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.top, AppStyle.spacing)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, AppStyle.screenPadding)
            }
        }
        .navigationTitle("Time Travel")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setStartDate(daysAgo: Int) {
        // Set global date offset — makes the entire app think it's X days in the future
        DebugDate.offsetDays = daysAgo

        // Also stamp today's plan date so daily loop and plan prompts reset
        if let habit = selectedHabit {
            let key = "lastPlanDate_\(habit.id.uuidString)"
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: "lastMorningPlanDate")
        }

        // Immediately evaluate badges for all habits
        for h in activeHabits {
            environment.achievementService.evaluate(for: h)
        }

        // Force Core Data to push changes to all @FetchRequest views
        viewContext.refreshAllObjects()

        lastAction = daysAgo == 0 ? "Reset to real time" : "Jumped +\(daysAgo) days — badges evaluated"
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

    // MARK: - Notification Test Helpers

    private func fireAllDailyLoopTest() {
        let center = UNUserNotificationCenter.current()
        let habitName = selectedHabit?.name ?? "Habit"

        let morning = UNMutableNotificationContent()
        morning.title = "Morning Plan"
        morning.body = "Good morning! Set your intention for today. — \(habitName)"
        morning.sound = .default
        center.add(UNNotificationRequest(identifier: "test_morning", content: morning, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)))

        let afternoon = UNMutableNotificationContent()
        afternoon.title = "Afternoon Check-In"
        afternoon.body = "How's your day going? Quick check-in time. — \(habitName)"
        afternoon.sound = .default
        center.add(UNNotificationRequest(identifier: "test_afternoon", content: afternoon, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)))

        let evening = UNMutableNotificationContent()
        evening.title = "Evening Review"
        evening.body = "Time to reflect on your day. What went well? — \(habitName)"
        evening.sound = .default
        center.add(UNNotificationRequest(identifier: "test_evening", content: evening, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)))
    }

    private func fireQuoteTest() {
        let center = UNUserNotificationCenter.current()
        let programType: ProgramType? = {
            guard let habit = selectedHabit else { return nil }
            return ProgramType(rawValue: habit.programType)
        }()

        for i in 0..<5 {
            let quote = QuoteBank.randomQuote(for: programType)
            let content = UNMutableNotificationContent()
            content.title = "You've Got This — \(selectedHabit?.name ?? "Motivation")"
            content.body = quote.text
            content.sound = .default
            center.add(UNNotificationRequest(
                identifier: "test_quote_\(i)",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(6 + i * 6), repeats: false)
            ))
        }
    }

    private func fireCustomTimerTest() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Custom Timer Test"
        content.body = "This notification was scheduled \(testDelay) seconds ago. Notifications are working!"
        content.sound = .default
        center.add(UNNotificationRequest(
            identifier: "test_custom",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(testDelay), repeats: false)
        ))
    }
}
