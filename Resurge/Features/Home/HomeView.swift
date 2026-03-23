import SwiftUI
import CoreData

struct HomeView: View {

    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \CDHabit.createdAt, ascending: false)
        ],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    )
    private var activeHabits: FetchedResults<CDHabit>

    @State private var showAddHabit = false
    @State private var showPremiumGate = false
    @State private var selectedHabitIndex: Int = 0
    @State private var trophyScale: CGFloat = 0.5
    @State private var refreshTrigger: UUID = UUID()
    @State private var showGoalComplete = false
    @State private var isEditingReason = false
    @State private var editedReason = ""
    @State private var showSurgeEarned = false
    @State private var showLockedPopup = false
    @State private var lockedMessage = ""
    @AppStorage("lastSurgeAwardDate") private var lastSurgeAwardDate: String = ""
    @AppStorage("shardBalance") private var shardBalance: Int = 0

    // MARK: - Date Helpers

    private var todayString: String {
        DebugDate.todayString
    }

    private var startOfToday: Date {
        DebugDate.startOfToday
    }

    // MARK: - Computed Properties

    private var selectedHabit: CDHabit? {
        guard !activeHabits.isEmpty else { return nil }
        let index = min(selectedHabitIndex, activeHabits.count - 1)
        return activeHabits[max(index, 0)]
    }

    private var selectedProgramType: ProgramType {
        guard let habit = selectedHabit else { return .smoking }
        return ProgramType(rawValue: habit.programType) ?? .smoking
    }

    private var hasPledgedToday: Bool {
        let _ = refreshTrigger
        guard let habit = selectedHabit else { return false }
        // Check UserDefaults (legacy) OR Core Data entryType
        let key = "lastPledgeDate_\(habit.id.uuidString)"
        if UserDefaults.standard.string(forKey: key) == todayString { return true }
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "date == %@", startOfToday as NSDate),
            NSPredicate(format: "entryType == %@", "morning")
        ])
        return ((try? viewContext.count(for: request)) ?? 0) > 0
    }

    private var hasCheckedInToday: Bool {
        let _ = refreshTrigger
        guard let habit = selectedHabit else { return false }
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "date == %@", startOfToday as NSDate),
            NSPredicate(format: "entryType == %@", "afternoon")
        ])
        return ((try? viewContext.count(for: request)) ?? 0) > 0
    }

    private var hasCompletedEveningReview: Bool {
        let _ = refreshTrigger
        guard let habit = selectedHabit else { return false }
        // Check UserDefaults (legacy) OR Core Data entryType
        let key = "lastEveningReviewDate_\(habit.id.uuidString)"
        if UserDefaults.standard.string(forKey: key) == todayString { return true }
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "date == %@", startOfToday as NSDate),
            NSPredicate(format: "entryType == %@", "evening")
        ])
        return ((try? viewContext.count(for: request)) ?? 0) > 0
    }

    private var totalDailyShardsEarned: Int { 15 }

    private var dailyLoopCompletionCount: Int {
        var count = 0
        if hasPledgedToday { count += 1 }
        if hasCheckedInToday { count += 1 }
        if hasCompletedEveningReview { count += 1 }
        return count
    }

    private var hasEarnedSurgesToday: Bool {
        lastSurgeAwardDate == todayString
    }

    @State private var showMaxSurgesMessage = false
    @State private var habitToDelete: CDHabit?
    @State private var showDeleteConfirm = false
    @State private var showDeleteTooltip = false

    @State private var previousLoopCount: Int = -1

    private func checkAndAwardSurges() {
        let allComplete = hasPledgedToday && hasCheckedInToday && hasCompletedEveningReview
        let currentCount = dailyLoopCompletionCount

        // Only act when count just changed to 3 (not on every re-evaluation)
        guard allComplete, currentCount == 3, previousLoopCount != 3 else {
            previousLoopCount = currentCount
            return
        }
        previousLoopCount = currentCount

        if hasEarnedSurgesToday {
            showMaxSurgesMessage = true
            return
        }

        lastSurgeAwardDate = todayString
        environment.rewardService.awardShards(for: .dailyLoopComplete, context: viewContext)
        let wallet = CDRewardWallet.fetchOrCreate(in: viewContext)
        shardBalance = Int(wallet.shardsBalance)
        showSurgeEarned = true
    }

    // MARK: - Time-Locked Daily Loop Windows

    private var wakeUpHour: Int {
        UserDefaults.standard.integer(forKey: "wakeUpHour")
    }

    private var morningUnlockHour: Int { wakeUpHour }
    private var afternoonUnlockHour: Int { (wakeUpHour + 6) % 24 }
    private var eveningUnlockHour: Int { (wakeUpHour + 12) % 24 }

    private var isHabitStarted: Bool {
        guard let habit = selectedHabit else { return false }
        return habit.startDate <= DebugDate.now
    }

    private func isWindowOpen(unlockHour: Int) -> Bool {
        // Habit hasn't started yet — all windows locked
        guard isHabitStarted else { return false }
        // Day 1 (onboarding day) — all windows open
        if UserDefaults.standard.string(forKey: "onboardingCompletedDate") == todayString {
            return true
        }
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: DebugDate.now)
        return currentHour >= unlockHour
    }

    private var isMorningOpen: Bool { isWindowOpen(unlockHour: morningUnlockHour) }
    private var isAfternoonOpen: Bool { isWindowOpen(unlockHour: afternoonUnlockHour) }
    private var isEveningOpen: Bool { isWindowOpen(unlockHour: eveningUnlockHour) }

    private func lockedTimeString(hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: DebugDate.now) ?? DebugDate.now
        return formatter.string(from: date)
    }

    // MARK: - Scoreboard Helpers

    private func daysOnTrackLast(_ days: Int) -> Int {
        guard let habit = selectedHabit else { return 0 }
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: startOfToday) else { return 0 }
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "createdAt >= %@", startDate as NSDate),
            NSPredicate(format: "createdAt < %@", Date() as NSDate)
        ])
        return (try? viewContext.count(for: request)) ?? 0
    }

    private var cravingsResistedThisWeek: Int {
        guard let habit = selectedHabit else { return 0 }
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: startOfToday) else { return 0 }
        let request = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "didResist == YES"),
            NSPredicate(format: "timestamp >= %@", weekAgo as NSDate)
        ])
        return (try? viewContext.count(for: request)) ?? 0
    }

    private var checkInStreak: Int {
        guard let habit = selectedHabit else { return 0 }
        let calendar = Calendar.current
        var streak = 0
        var cursor = startOfToday

        for _ in 0..<30 {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "habit == %@", habit),
                NSPredicate(format: "createdAt >= %@", previousDay as NSDate),
                NSPredicate(format: "createdAt < %@", cursor as NSDate)
            ])
            let count = (try? viewContext.count(for: request)) ?? 0
            if count > 0 {
                streak += 1
                cursor = previousDay
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    if !activeHabits.isEmpty {
                        // Goal & Why card
                        goalWhyCard

                        // Habit Pill Switcher (multiple habits only)
                        if activeHabits.count > 1 {
                            habitPillSwitcher
                                .padding(.horizontal, AppStyle.screenPadding)
                        }

                        // [1] Hero Card
                        heroCard
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [1.5] Did You Know? Insight Card
                        insightCard
                            .padding(.horizontal, AppStyle.screenPadding)

                        // Future start date banner
                        if let habit = selectedHabit, habit.startDate > Date() {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 24))
                                    .foregroundColor(.neonGold)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Your journey begins on")
                                        .font(Typography.caption)
                                        .foregroundColor(.subtleText)
                                    Text(habit.startDate, style: .date)
                                        .font(Typography.headline)
                                        .foregroundColor(.neonGold)
                                }
                                Spacer()
                            }
                            .padding(AppStyle.cardPadding)
                            .background(Color.neonGold.opacity(0.08))
                            .cornerRadius(AppStyle.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                                    .stroke(Color.neonGold.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, AppStyle.screenPadding)
                        }

                        // [2] BIG CRAVING PROTOCOL BUTTON
                        cravingProtocolButton
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [3] Daily Loop Card
                        dailyLoopCard
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [4] Recovery Scoreboard Mini
                        recoveryScoreboard
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [5] Wins Section
                        winsSection
                            .padding(.horizontal, AppStyle.screenPadding)
                    } else {
                        emptyStateCard
                    }
                }
                .padding(.vertical, AppStyle.spacing)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        ActivePetView()
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Today")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.appText)
                                .lineLimit(1)
                            Text({
                                let f = DateFormatter(); f.dateFormat = "EEE, MMM d"
                                return f.string(from: DebugDate.now)
                            }())
                                .font(.system(size: 11))
                                .foregroundColor(.subtleText)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let habit = selectedHabit {
                        SobrietyCounterView(startDate: habit.startDate, isCompact: true, programColor: Color(hex: selectedProgramType.colorHex))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if environment.entitlementManager.canAddHabit(currentCount: activeHabits.count) {
                            showAddHabit = true
                        } else {
                            showPremiumGate = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.neonCyan, .neonPurple, .neonMagenta],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showAddHabit, onDismiss: {
                // Show tooltip about long-press delete when they have multiple habits
                if activeHabits.count > 1 && !UserDefaults.standard.bool(forKey: "hasSeenDeleteTooltip") {
                    UserDefaults.standard.set(true, forKey: "hasSeenDeleteTooltip")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showDeleteTooltip = true
                    }
                }
            }) {
                AddEditHabitView(mode: .add)
                    .environmentObject(environment)
                    .environment(\.managedObjectContext, viewContext)
            }
            .premiumGate(
                isPresented: showPremiumGate,
                featureName: "Unlimited Habits",
                featureDescription: "Upgrade to premium to track multiple habits and unlock all features.",
                onUnlock: { showPremiumGate = false },
                onDismiss: { showPremiumGate = false }
            )
            .sheet(isPresented: $showGoalComplete) {
                if let habit = selectedHabit {
                    GoalCompleteView(habit: habit)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .alert("Locked", isPresented: $showLockedPopup) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(lockedMessage)
            }
            .alert("+15 Surges Earned!", isPresented: $showSurgeEarned) {
                Button("Awesome!", role: .cancel) {}
            } message: {
                Text("You completed your entire daily loop. Keep showing up every day!")
            }
            .alert("Max Surges Reached", isPresented: $showMaxSurgesMessage) {
                Button("Got It", role: .cancel) {}
            } message: {
                Text("You've already earned your 15 Surges today. Come back tomorrow!")
            }
            .alert("Remove Habit?", isPresented: $showDeleteConfirm) {
                Button("Remove", role: .destructive) {
                    if let habit = habitToDelete {
                        deleteHabit(habit)
                    }
                }
                Button("Cancel", role: .cancel) {
                    habitToDelete = nil
                }
            } message: {
                Text("This will permanently delete this habit and all its data including logs, journal entries, craving records, and progress. This cannot be undone.")
            }
            .alert("Tip", isPresented: $showDeleteTooltip) {
                Button("Got It", role: .cancel) {}
            } message: {
                Text("Press and hold on any habit at the top to remove it and all its data.")
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            refreshTrigger = UUID()
            checkGoalCompletion()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            refreshTrigger = UUID()
        }
        .onChange(of: activeHabits.count) { _ in
            if selectedHabitIndex >= activeHabits.count {
                selectedHabitIndex = max(activeHabits.count - 1, 0)
            }
        }
    }

    // MARK: - Goal & Why Card

    private var goalWhyCard: some View {
        Group {
            if let habit = selectedHabit {
                let days = habit.daysSoberCount
                let goal = Int(habit.goalDays)

                VStack(spacing: 8) {
                    if goal > 0 && days >= goal {
                        // Goal reached!
                        HStack {
                            Image(systemName: "trophy.fill").foregroundColor(.neonGold)
                            Text("Goal Reached!").font(Typography.headline).foregroundColor(.neonGold)
                        }
                        Text("You've completed your \(goal)-day goal!")
                            .font(Typography.caption).foregroundColor(.subtleText)
                    } else if goal > 0 {
                        // Progress toward goal
                        HStack {
                            Image(systemName: "flag.fill").foregroundColor(.neonCyan)
                            Text("\(goal)-Day Goal").font(Typography.headline).foregroundColor(.appText)
                            Spacer()
                            Text("Day \(days)/\(goal)").font(Typography.badge).foregroundColor(.neonCyan)
                        }
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(Color.cardBorder).frame(height: 6)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(colors: [.neonCyan, .neonPurple], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * min(CGFloat(days) / CGFloat(goal), 1.0), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }

                    // Your Why — editable with pencil icon
                    if isEditingReason {
                        HStack(spacing: 8) {
                            TextField("Your reason for quitting...", text: $editedReason)
                                .font(Typography.callout)
                                .foregroundColor(.appText)
                                .padding(8)
                                .background(Color.cardBackground)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.neonCyan.opacity(0.4), lineWidth: 1)
                                )

                            Button {
                                habit.reasonToQuit = editedReason.trimmingCharacters(in: .whitespacesAndNewlines)
                                try? viewContext.save()
                                isEditingReason = false
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.neonGreen)
                            }
                        }
                    } else if let reason = habit.reasonToQuit, !reason.isEmpty {
                        HStack {
                            Text("\"\(reason)\"")
                                .font(Typography.callout).foregroundColor(.subtleText).italic()
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                editedReason = reason
                                isEditingReason = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundColor(.subtleText.opacity(0.6))
                            }
                        }
                    } else {
                        Button {
                            editedReason = ""
                            isEditingReason = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle")
                                    .font(.caption)
                                Text("Add your reason for quitting")
                                    .font(Typography.caption)
                            }
                            .foregroundColor(.neonCyan.opacity(0.6))
                        }
                    }
                }
                .neonCard(glow: .neonCyan)
                .padding(.horizontal, AppStyle.screenPadding)
            }
        }
    }

    // MARK: - [A] Habit Pill Switcher

    private var habitPillSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(activeHabits.enumerated()), id: \.element.id) { index, habit in
                    let programType = ProgramType(rawValue: habit.programType) ?? .smoking
                    Text(habit.safeDisplayName)
                        .font(Typography.caption)
                        .lineLimit(1)
                        .foregroundColor(selectedHabitIndex == index ? .white : .subtleText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            selectedHabitIndex == index
                                ? AnyView(
                                    LinearGradient(
                                        colors: [.neonCyan, .neonPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                : AnyView(Color.cardBackground)
                        )
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    selectedHabitIndex == index
                                        ? Color.clear
                                        : Color.cardBorder,
                                    lineWidth: 1
                                )
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedHabitIndex = index
                            }
                        }
                        .onLongPressGesture {
                            habitToDelete = habit
                            showDeleteConfirm = true
                        }
                }
            }
        }
    }

    // MARK: - [1] Hero Card — "Today's Plan"

    private var heroCard: some View {
        Group {
            if let habit = selectedHabit {
                let programType = ProgramType(rawValue: habit.programType) ?? .smoking
                let quote = QuoteBank.quoteOfTheDay(for: programType)
                let programColor = Color(hex: programType.colorHex)

                VStack(spacing: AppStyle.spacing) {
                    Text(quote.text)
                        .font(Typography.body.italic())
                        .foregroundColor(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        Image(systemName: programType.iconName)
                            .font(Typography.caption)
                            .foregroundColor(programColor)

                        Text("Day \(habit.daysSoberCount)")
                            .font(Typography.headline)
                            .foregroundColor(.appText)

                        Text("\u{2022}")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)

                        HStack(spacing: 2) {
                            Text("\u{1F525}")
                                .font(Typography.caption)
                            Text("\(habit.currentStreak)d streak")
                                .font(Typography.body)
                                .foregroundColor(.subtleText)
                        }

                        Spacer()
                    }
                }
                .rainbowCard()
            }
        }
    }

    // MARK: - [2] BIG CRAVING PROTOCOL BUTTON

    private var cravingProtocolButton: some View {
        NavigationLink(destination: CravingModeView(preSelectedHabit: selectedHabit)) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                Text("CRAVING ALERT")
                    .font(Typography.title)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                LinearGradient(
                    colors: [Color.red, Color(hex: "CC0000")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppStyle.cornerRadius)
            .shadow(color: Color.red.opacity(0.4), radius: 16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - [3] Daily Loop Card

    private var dailyLoopCard: some View {
        VStack(spacing: AppStyle.spacing) {
            // Header
            HStack {
                Text("Daily Loop")
                    .font(Typography.headline)
                    .rainbowText()

                Spacer()

                Text("\(dailyLoopCompletionCount)/3")
                    .font(Typography.headline)
                    .foregroundColor(.neonGreen)
            }

            // Rainbow progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.cardBorder)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(dailyLoopCompletionCount) / 3.0, height: 4)
                }
            }
            .frame(height: 4)

            // Loop rows
            VStack(spacing: 6) {
                // Row 1: Morning Plan/Review
                morningPlanRow

                // Row 2: Quick Check-In
                quickCheckInRow

                // Row 3: Evening Review/Reflection
                eveningReviewRow
            }
        }
        .rainbowCard()
    }

    private func dailyLoopRow(title: String, emoji: String, isComplete: Bool, isOpen: Bool, unlockHour: Int, duration: String, destination: @escaping (CDHabit) -> AnyView) -> some View {
        Group {
            if let habit = selectedHabit {
                if isOpen || isComplete {
                    NavigationLink(destination: destination(habit)
                        .id("\(title)_\(refreshTrigger)")
                        .onDisappear {
                            refreshTrigger = UUID()
                            checkAndAwardSurges()
                        }
                    ) {
                        dailyLoopRowContent(title: title, emoji: emoji, isComplete: isComplete, isOpen: isOpen, unlockHour: unlockHour, duration: duration)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        if !isHabitStarted, let h = selectedHabit {
                            let f = DateFormatter(); f.dateStyle = .medium
                            lockedMessage = "Your journey begins on \(f.string(from: h.startDate)). Daily loop will unlock then."
                        } else {
                            lockedMessage = "\(title) unlocks at \(lockedTimeString(hour: unlockHour))"
                        }
                        showLockedPopup = true
                    } label: {
                        dailyLoopRowContent(title: title, emoji: emoji, isComplete: isComplete, isOpen: isOpen, unlockHour: unlockHour, duration: duration)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func dailyLoopRowContent(title: String, emoji: String, isComplete: Bool, isOpen: Bool, unlockHour: Int, duration: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : (isOpen ? "circle" : "lock.fill"))
                .font(Typography.body)
                .foregroundColor(isComplete ? .neonGreen : (isOpen ? .subtleText : .neonOrange))

            Text("\(emoji) \(title)")
                .font(Typography.body)
                .foregroundColor(isComplete ? .subtleText : (isOpen ? .appText : .subtleText))
                .strikethrough(isComplete, color: .subtleText)

            Spacer()

            if !isOpen && !isComplete {
                Text(lockedTimeString(hour: unlockHour))
                    .font(Typography.caption)
                    .foregroundColor(.neonOrange)
            } else {
                Text(duration)
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }

            Image(systemName: isOpen || isComplete ? "chevron.right" : "lock.fill")
                .font(Typography.caption)
                .foregroundColor(isOpen || isComplete ? .subtleText : .neonOrange.opacity(0.5))
        }
        .padding(.vertical, 6)
    }

    private var morningPlanRow: some View {
        dailyLoopRow(
            title: "Morning Plan/Review", emoji: "\u{2600}\u{FE0F}",
            isComplete: hasPledgedToday, isOpen: isMorningOpen,
            unlockHour: morningUnlockHour, duration: "1 min"
        ) { habit in AnyView(MorningPlanView(habit: habit)) }
    }

    private var quickCheckInRow: some View {
        dailyLoopRow(
            title: "Afternoon Check-In", emoji: "\u{1F4CB}",
            isComplete: hasCheckedInToday, isOpen: isAfternoonOpen,
            unlockHour: afternoonUnlockHour, duration: "30 sec"
        ) { habit in AnyView(QuickCheckInView(habit: habit)) }
    }

    private var eveningReviewRow: some View {
        dailyLoopRow(
            title: "Evening Review/Reflection", emoji: "\u{1F319}",
            isComplete: hasCompletedEveningReview, isOpen: isEveningOpen,
            unlockHour: eveningUnlockHour, duration: "1 min"
        ) { habit in AnyView(EveningReviewView(habit: habit)) }
    }

    // MARK: - [4] Recovery Scoreboard Mini

    private var totalLapseCount: Int {
        let _ = refreshTrigger
        guard let habit = selectedHabit else { return 0 }

        // Count lapses from daily loop check-ins
        let logRequest = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        logRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "lapsedToday == YES")
        ])
        let logLapses = (try? viewContext.count(for: logRequest)) ?? 0

        // Count lapses from craving mode (gave in)
        let cravingRequest = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        cravingRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "didResist == NO")
        ])
        let cravingLapses = (try? viewContext.count(for: cravingRequest)) ?? 0

        return logLapses + cravingLapses
    }

    private var recoveryScoreboard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                scoreboardBox(
                    value: "\(selectedHabit?.daysSoberCount ?? 0)",
                    label: "Days",
                    color: .neonGreen
                )

                scoreboardBox(
                    value: "\(cravingsResistedThisWeek)",
                    label: "Cravings",
                    color: .neonBlue
                )

                scoreboardBox(
                    value: "\(totalLapseCount)",
                    label: "Lapses",
                    color: .red
                )

                NavigationLink(destination: ActivityLogView()) {
                    VStack(spacing: 4) {
                        Image(systemName: "text.book.closed.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.neonCyan, .neonPurple, .neonGold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Log")
                            .font(.system(size: 10))
                            .foregroundColor(.subtleText)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.cardBackground)
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .neonCard()
    }

    private func scoreboardBox(value: String, label: String, color: Color = .neonCyan) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.subtleText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.smallCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - [5] Wins Section

    private var winsSection: some View {
        VStack(spacing: AppStyle.spacing) {
            if dailyLoopCompletionCount >= 3 {
                // All 3 done — show daily reward
                VStack(spacing: 12) {
                    Text("Daily Reward Earned!")
                        .font(Typography.headline)
                        .rainbowText()

                    // Animated badge
                    ZStack {
                        Circle()
                            .fill(Color.neonGold.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.neonGold)
                            .shadow(color: .neonGold.opacity(0.6), radius: 8)
                    }
                    .scaleEffect(trophyScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            trophyScale = 1.1
                        }
                    }

                    Text(hasEarnedSurgesToday ? "You've earned your daily Surges. Come back tomorrow!" : "+\(totalDailyShardsEarned) Surges earned for completing your daily ritual")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
                .neonCard(glow: .neonGold)
            } else {
                // Not all done — show progress motivation
                VStack(spacing: 8) {
                    HStack {
                        Text("Daily Reward")
                            .font(Typography.headline)
                            .foregroundColor(.neonGold)
                        Spacer()
                        Text("\(dailyLoopCompletionCount)/3")
                            .font(Typography.badge)
                            .foregroundColor(.neonGold)
                    }

                    Text("Complete all 3 daily tasks to earn your reward")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)

                    // Mini progress indicators
                    HStack(spacing: 8) {
                        miniRewardDot(filled: hasPledgedToday, label: "Plan")
                        miniRewardDot(filled: hasCheckedInToday, label: "Check-in")
                        miniRewardDot(filled: hasCompletedEveningReview, label: "Review")
                    }
                }
                .neonCard(glow: .neonGold.opacity(0.3))
            }
        }
    }

    // MARK: - [6] Did You Know? Insight Card

    private var insightCard: some View {
        Group {
            if let template = ProgramTemplates.template(for: selectedProgramType),
               !template.insightCards.isEmpty {
                let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: DebugDate.now) ?? 0
                let card = template.insightCards[dayOfYear % template.insightCards.count]
                let programColor = Color(hex: selectedProgramType.colorHex)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(programColor)
                        Text("Did you know?")
                            .font(Typography.headline)
                            .foregroundColor(programColor)
                        Spacer()
                        Text(selectedProgramType.displayName)
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }

                    Text(card.title)
                        .font(Typography.body.weight(.semibold))
                        .foregroundColor(.textPrimary)

                    Text(card.body)
                        .font(Typography.callout)
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .neonCard(glow: programColor)
            }
        }
    }

    private func miniRewardDot(filled: Bool, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: filled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(filled ? .neonGreen : .subtleText)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.subtleText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty State

    // MARK: - Delete Habit

    private func deleteHabit(_ habit: CDHabit) {
        // Delete all related entries
        let logRequest = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        logRequest.predicate = NSPredicate(format: "habit == %@", habit)
        if let logs = try? viewContext.fetch(logRequest) {
            logs.forEach { viewContext.delete($0) }
        }

        let cravingRequest = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        cravingRequest.predicate = NSPredicate(format: "habit == %@", habit)
        if let cravings = try? viewContext.fetch(cravingRequest) {
            cravings.forEach { viewContext.delete($0) }
        }

        let journalRequest = NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
        journalRequest.predicate = NSPredicate(format: "habit == %@", habit)
        if let journals = try? viewContext.fetch(journalRequest) {
            journals.forEach { viewContext.delete($0) }
        }

        let planRequest = NSFetchRequest<CDIfThenPlan>(entityName: "CDIfThenPlan")
        planRequest.predicate = NSPredicate(format: "habitId == %@", habit.id as CVarArg)
        if let plans = try? viewContext.fetch(planRequest) {
            plans.forEach { viewContext.delete($0) }
        }

        // Clean up UserDefaults keys tied to this habit
        let habitId = habit.id.uuidString
        let keysToRemove = [
            "lastPledgeDate_\(habitId)",
            "lastCheckInDate_\(habitId)",
            "lastEveningReviewDate_\(habitId)",
            "highRiskWindows_\(habitId)",
            "goalComplete_\(habitId)",
            "coachingDay_\(habitId)",
            "coachingLastDate_\(habitId)"
        ]
        keysToRemove.forEach { UserDefaults.standard.removeObject(forKey: $0) }

        viewContext.delete(habit)
        try? viewContext.save()

        // Reset index if needed
        if selectedHabitIndex >= activeHabits.count {
            selectedHabitIndex = max(activeHabits.count - 1, 0)
        }
        habitToDelete = nil
        refreshTrigger = UUID()
    }

    // MARK: - Goal Completion Check

    private func checkGoalCompletion() {
        guard let habit = selectedHabit else { return }
        let goal = Int(habit.goalDays)
        guard goal > 0, habit.daysSoberCount >= goal else { return }

        // Only show once per goal — use UserDefaults key
        let key = "goalComplete_\(habit.id.uuidString)_\(goal)"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showGoalComplete = true
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: AppStyle.spacing) {
            Image(systemName: "leaf.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.primaryTeal.opacity(0.5))

            Text("No habits yet")
                .font(Typography.title)
                .foregroundColor(.appText)

            Text("Tap the + button to add your first habit and start tracking your recovery.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)

            Button {
                showAddHabit = true
            } label: {
                Text("Add Your First Habit")
            }
            .buttonStyle(RainbowButtonStyle())
        }
        .padding(AppStyle.cardPadding)
        .padding(.horizontal, AppStyle.screenPadding)
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppEnvironment.preview)
            .environment(\.managedObjectContext, CoreDataStack.preview.viewContext)
    }
}
