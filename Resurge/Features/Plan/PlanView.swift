import SwiftUI
import CoreData

// MARK: - PlanView

struct PlanView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var activeHabits: FetchedResults<CDHabit>

    @State private var selectedHabitIndex: Int = 0
    @State private var showCreatePlan = false
    @State private var showNewWeekCard = false
    @State private var planRefreshTrigger: UUID = UUID()
    @State private var editingPlan: CDIfThenPlan?
    @State private var planToDelete: CDIfThenPlan?
    @State private var showDeleteConfirm = false

    // MARK: - Selected Habit

    private var selectedHabit: CDHabit? {
        guard !activeHabits.isEmpty else { return nil }
        return activeHabits[min(selectedHabitIndex, activeHabits.count - 1)]
    }

    private var selectedProgramType: ProgramType {
        guard let habit = selectedHabit else { return .smoking }
        return ProgramType(rawValue: habit.programType) ?? .smoking
    }

    // MARK: - Per-Habit AppStorage Keys

    private var highRiskStorageKey: String {
        guard let habit = selectedHabit else { return "highRiskWindows_default" }
        return "highRiskWindows_\(habit.id.uuidString)"
    }

    // MARK: - High-Risk Windows (per-habit via UserDefaults)

    private var highRiskWindows: String {
        UserDefaults.standard.string(forKey: highRiskStorageKey) ?? ""
    }

    private var riskWindowsSet: Set<String> {
        Set(highRiskWindows.components(separatedBy: ",").filter { !$0.isEmpty })
    }

    private func toggleRiskWindow(_ key: String) {
        var windows = riskWindowsSet
        if windows.contains(key) {
            windows.remove(key)
        } else {
            windows.insert(key)
        }
        UserDefaults.standard.set(windows.sorted().joined(separator: ","), forKey: highRiskStorageKey)
    }

    private func isRiskWindowActive(_ key: String) -> Bool {
        riskWindowsSet.contains(key)
    }

    // MARK: - Plans Filtered by Habit

    private var filteredPlans: [CDIfThenPlan] {
        let _ = planRefreshTrigger // Force re-evaluation when trigger changes
        guard let habit = selectedHabit else { return [] }
        let request = NSFetchRequest<CDIfThenPlan>(entityName: "CDIfThenPlan")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "activeFlag == YES"),
            NSPredicate(format: "habitId == %@", habit.id as CVarArg)
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDIfThenPlan.createdAt, ascending: false)]
        return (try? viewContext.fetch(request)) ?? []
    }

    // MARK: - Weekly Overview Helpers

    private var calendar: Calendar { Calendar.current }

    private var currentWeekDates: [Date] {
        let today = DebugDate.now
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: calendar.startOfDay(for: today))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private var weekDateRangeString: String {
        guard let first = currentWeekDates.first, let last = currentWeekDates.last else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "Week of \(formatter.string(from: first)) - \(formatter.string(from: last))"
    }

    private func hasPlanForDay(_ date: Date) -> Bool {
        guard let habit = selectedHabit else { return false }
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return false }
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "createdAt >= %@", startOfDay as NSDate),
            NSPredicate(format: "createdAt < %@", endOfDay as NSDate)
        ])
        return ((try? viewContext.count(for: request)) ?? 0) > 0
    }

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: DebugDate.now)
    }

    private func deletePlan(_ plan: CDIfThenPlan) {
        viewContext.delete(plan)
        try? viewContext.save()
    }

    // MARK: - New Day / Week Detection

    private var todayString: String {
        DebugDate.todayString
    }

    private var lastPlanDateKey: String {
        guard let habit = selectedHabit else { return "lastPlanDate_default" }
        return "lastPlanDate_\(habit.id.uuidString)"
    }

    private var hasPlans: Bool {
        !filteredPlans.isEmpty
    }

    /// True if the user hasn't dismissed the prompt today
    private var isNewDayForPrompt: Bool {
        let lastDate = UserDefaults.standard.string(forKey: lastPlanDateKey) ?? ""
        return lastDate != todayString
    }

    private var isMonday: Bool {
        Calendar.current.component(.weekday, from: DebugDate.now) == 2 // Monday
    }

    private var planDayCount: Int {
        selectedHabit?.daysSoberCount ?? 0
    }

    private func keepCurrentPlan() {
        UserDefaults.standard.set(todayString, forKey: lastPlanDateKey)
        showNewWeekCard = false
    }

    private func startNewPlan() {
        UserDefaults.standard.set(todayString, forKey: lastPlanDateKey)
        showNewWeekCard = false
        showCreatePlan = true
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    // Title
                    Text("Your Recovery Strategy")
                        .font(Typography.largeTitle)
                        .rainbowText()
                        .padding(.top, 4)

                    // [0] HABIT PILL SWITCHER
                    if activeHabits.count > 1 {
                        habitPillSwitcher
                    }

                    // [1] THIS WEEK
                    weeklyPlanSection

                    // [3] IF-THEN PLANS
                    ifThenPlansSection
                }
                .padding(.bottom, AppStyle.largeSpacing)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ActivePetView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showCreatePlan) {
            CreatePlanSheet(
                triggers: selectedProgramType.triggers,
                habitId: selectedHabit?.id,
                suggestedPlans: selectedProgramType.suggestedPlans
            ) { triggerType, triggerDetails, thenSteps, responseDetail in
                CDIfThenPlan.create(
                    in: viewContext,
                    triggerType: triggerType,
                    triggerDetails: triggerDetails,
                    thenSteps: thenSteps,
                    responseDetail: responseDetail,
                    habitId: selectedHabit?.id
                )
                try? viewContext.save()
                planRefreshTrigger = UUID()
                // Stamp today so the new day prompt doesn't re-appear
                UserDefaults.standard.set(todayString, forKey: lastPlanDateKey)
            }
        }
        .sheet(item: $editingPlan) { plan in
            EditPlanSheet(
                plan: plan,
                triggers: selectedProgramType.triggers
            ) {
                try? viewContext.save()
                planRefreshTrigger = UUID()
            }
        }
        .alert("Are you sure you want to delete this plan?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let plan = planToDelete {
                    deletePlan(plan)
                    planToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                planToDelete = nil
            }
        }
        .onAppear {
            migrateIfNeeded()
            // Show prompt only if it's a new day and not already dismissed
            if isNewDayForPrompt && !showNewWeekCard {
                showNewWeekCard = true
            }
        }
        .onChange(of: activeHabits.count) { _ in
            if selectedHabitIndex >= activeHabits.count {
                selectedHabitIndex = max(activeHabits.count - 1, 0)
            }
        }
    }

    // MARK: - Migration

    private func migrateIfNeeded() {
        let key = "ifThenPlans"
        guard let json = UserDefaults.standard.string(forKey: key),
              let data = json.data(using: .utf8),
              let oldPlans = try? JSONDecoder().decode([OldIfThenPlan].self, from: data) else { return }
        for old in oldPlans {
            CDIfThenPlan.create(
                in: viewContext,
                triggerType: old.trigger,
                triggerDetails: old.triggerDetail,
                thenSteps: old.response,
                habitId: selectedHabit?.id
            )
        }
        try? viewContext.save()
        UserDefaults.standard.removeObject(forKey: key)
    }

    private struct OldIfThenPlan: Codable {
        var id: UUID
        var trigger: String
        var triggerDetail: String
        var response: String
        var responseDetail: String
    }

    // MARK: - Habit Pill Switcher

    private var habitPillSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(activeHabits.enumerated()), id: \.element.id) { index, habit in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedHabitIndex = index
                        }
                    } label: {
                        Text(habit.safeDisplayName)
                            .font(Typography.caption)
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
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)
        }
    }

    // MARK: - [1] Weekly Plan Section

    private var weeklyPlanSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            HStack {
                Text("This Week")
                    .font(Typography.title)
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("Day \(planDayCount)")
                    .font(Typography.headline)
                    .foregroundColor(.neonCyan)
            }

            Text(weekDateRangeString)
                .font(Typography.caption)
                .foregroundColor(.subtleText)

            // New week keep/renew card
            if showNewWeekCard {
                newWeekCard
            }

            // 7-day dot strip
            HStack(spacing: 0) {
                ForEach(currentWeekDates, id: \.self) { date in
                    VStack(spacing: 6) {
                        Text(dayAbbreviation(for: date))
                            .font(Typography.caption)
                            .foregroundColor(.textSecondary)

                        ZStack {
                            Circle()
                                .fill(hasPlanForDay(date) ? Color.neonGreen : Color.cardBorder)
                                .frame(width: 32, height: 32)

                            if isToday(date) {
                                Circle()
                                    .stroke(Color.neonCyan, lineWidth: 2)
                                    .frame(width: 38, height: 38)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .neonCard(glow: .neonCyan)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    private var newWeekCard: some View {
        VStack(spacing: AppStyle.spacing) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 18))
                    .foregroundColor(.neonGold)
                Text(isMonday ? "New Week" : "New Day")
                    .font(Typography.headline)
                    .foregroundColor(.appText)
                Spacer()
                Text("Day \(planDayCount)")
                    .font(Typography.caption)
                    .foregroundColor(.neonCyan)
            }

            if hasPlans {
                // Has existing plans — offer keep or new
                Text(isMonday
                     ? "New week ahead! Keep your current plan or create a fresh one?"
                     : "New day. Keep your plan or switch it up?")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)

                HStack(spacing: 12) {
                    Button {
                        keepCurrentPlan()
                    } label: {
                        Text("Keep Plan")
                            .font(Typography.caption)
                            .foregroundColor(.neonGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.neonGreen.opacity(0.15))
                            .cornerRadius(AppStyle.smallCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                    .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        startNewPlan()
                    } label: {
                        Text("New Plan")
                            .font(Typography.caption)
                            .foregroundColor(.neonCyan)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.neonCyan.opacity(0.15))
                            .cornerRadius(AppStyle.smallCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                    .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // No plans yet — just create
                Text(isMonday
                     ? "New week! Start strong with a plan."
                     : "New day. Set up your If-Then plan.")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)

                Button {
                    startNewPlan()
                } label: {
                    Text("Create Your Plan")
                }
                .buttonStyle(RainbowButtonStyle())
            }
        }
        .neonCard(glow: .neonGold)
    }

    // MARK: - [2] High-Risk Section

    private var highRiskSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.neonOrange)
                Text("High-Risk Times")
                    .font(Typography.headline)
                    .foregroundColor(.appText)
            }

            Text("Tap to mark times when you're most likely to struggle")
                .font(Typography.caption)
                .foregroundColor(.subtleText)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                riskTimeCard("Morning", icon: "sunrise.fill", color: .neonGold, key: "risk_morning")
                riskTimeCard("Afternoon", icon: "sun.max.fill", color: .neonOrange, key: "risk_afternoon")
                riskTimeCard("Evening", icon: "sunset.fill", color: .neonPurple, key: "risk_evening")
                riskTimeCard("Night", icon: "moon.fill", color: .neonBlue, key: "risk_night")
            }
        }
        .neonCard(glow: .neonOrange)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    private func riskTimeCard(_ title: String, icon: String, color: Color, key: String) -> some View {
        Button {
            toggleRiskWindow(key)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isRiskWindowActive(key) ? color : .subtleText)

                Text(title)
                    .font(Typography.caption)
                    .foregroundColor(isRiskWindowActive(key) ? .textPrimary : .subtleText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isRiskWindowActive(key) ? color.opacity(0.15) : Color.cardBackground)
            .cornerRadius(AppStyle.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                    .stroke(isRiskWindowActive(key) ? color : Color.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - [3] If-Then Plans Section

    private var ifThenPlansSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            HStack {
                Text("Your If-Then Plans")
                    .font(Typography.title)
                    .foregroundColor(.textPrimary)
                Spacer()
                Button {
                    showCreatePlan = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .leading, endPoint: .trailing)
                        )
                }
            }

            let plans = filteredPlans
            if plans.isEmpty {
                emptyStateCard
            } else {
                ForEach(plans) { plan in
                    planCard(plan)
                }
            }
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    private var emptyStateCard: some View {
        VStack(spacing: AppStyle.spacing) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 40))
                .foregroundColor(.neonCyan)

            Text("Build Your Defense")
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            Text("If-Then plans help you prepare for triggers before they happen.")
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Text("Example: IF I feel stressed THEN I will do 5 minutes of breathing")
                .font(Typography.callout)
                .foregroundColor(.textSecondary)
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .neonCard(glow: .neonCyan)
    }

    private func planCard(_ plan: CDIfThenPlan) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                // High-risk time if stored
                if let habit = selectedHabit {
                    let riskKey = "highRiskWindows_\(habit.id.uuidString)"
                    let riskValue = UserDefaults.standard.string(forKey: riskKey) ?? ""
                    if !riskValue.isEmpty {
                        let labels = riskValue.components(separatedBy: ",")
                            .filter { !$0.isEmpty }
                            .compactMap { key -> String? in
                                switch key {
                                case "risk_morning": return "Morning"
                                case "risk_afternoon": return "Afternoon"
                                case "risk_evening": return "Evening"
                                case "risk_night": return "Night"
                                default: return nil
                                }
                            }
                        if !labels.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.neonOrange)
                                Text(labels.joined(separator: ", "))
                                    .font(Typography.caption)
                                    .foregroundColor(.neonOrange)
                            }
                        }
                    }
                }

                // IF row
                HStack(spacing: 6) {
                    Text("IF")
                        .font(Typography.badge)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.neonOrange)
                        .cornerRadius(6)

                    Text(plan.triggerType)
                        .font(Typography.callout)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                }

                // Trigger details
                if let details = plan.triggerDetails, !details.isEmpty {
                    Text(details)
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.leading, 42)
                }

                // THEN row
                HStack(spacing: 6) {
                    Text("THEN")
                        .font(Typography.badge)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.neonGreen)
                        .cornerRadius(6)

                    Text(plan.thenSteps ?? "")
                        .font(Typography.callout)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                }

                // Response detail
                if let detail = plan.responseDetail, !detail.isEmpty {
                    Text(detail)
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.leading, 52)
                }
            }
            Spacer()
        }
        .neonCard(glow: .neonPurple)
        .overlay(alignment: .topTrailing) {
            Button {
                editingPlan = plan
            } label: {
                Image(systemName: "pencil")
                    .font(Typography.caption)
                    .foregroundColor(.neonCyan)
                    .padding(10)
            }
            .buttonStyle(.plain)
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                planToDelete = plan
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                    .padding(10)
            }
            .buttonStyle(.plain)
        }
    }

}

// MARK: - Create Plan Sheet

struct CreatePlanSheet: View {

    @Environment(\.presentationMode) var presentationMode

    let triggers: [String]
    let habitId: UUID?
    var suggestedPlans: [(ifTrigger: String, thenAction: String)] = []
    let onSave: (_ triggerType: String, _ triggerDetails: String, _ thenSteps: String, _ responseDetail: String) -> Void

    static let responses: [(text: String, icon: String)] = [
        ("Do breathing exercise", "wind"),
        ("Leave the situation", "figure.walk"),
        ("Call someone", "phone.fill"),
        ("Go for a walk", "figure.walk"),
        ("Write in journal", "book.fill"),
        ("Use grounding exercise", "hand.raised.fill"),
        ("Play a puzzle game", "puzzlepiece.fill"),
        ("Review my reasons", "heart.fill"),
        ("Wait 10 minutes", "timer"),
        ("Drink water", "drop.fill"),
        ("Do 10 pushups", "figure.strengthtraining.traditional"),
        ("Listen to music", "headphones"),
        ("Take a cold shower", "snowflake"),
        ("Meditate for 5 minutes", "leaf.fill")
    ]

    @State private var selectedTrigger: String = ""
    @State private var triggerDetail: String = ""
    @State private var selectedResponse: String = ""
    @State private var responseDetail: String = ""
    @State private var activeRiskWindows: Set<String> = []

    // High-risk time windows
    private static let riskTimeOptions: [(title: String, icon: String, color: Color, key: String)] = [
        ("Morning", "sunrise.fill", .neonGold, "risk_morning"),
        ("Afternoon", "sun.max.fill", .neonOrange, "risk_afternoon"),
        ("Evening", "sunset.fill", .neonPurple, "risk_evening"),
        ("Night", "moon.fill", .neonBlue, "risk_night")
    ]

    private var highRiskStorageKey: String {
        guard let id = habitId else { return "highRiskWindows_default" }
        return "highRiskWindows_\(id.uuidString)"
    }

    private func isRiskWindowActive(_ key: String) -> Bool {
        activeRiskWindows.contains(key)
    }

    private func toggleRiskWindow(_ key: String) {
        if activeRiskWindows.contains(key) {
            activeRiskWindows.remove(key)
        } else {
            activeRiskWindows.insert(key)
        }
        UserDefaults.standard.set(activeRiskWindows.sorted().joined(separator: ","), forKey: highRiskStorageKey)
    }

    private func loadRiskWindows() {
        let stored = UserDefaults.standard.string(forKey: highRiskStorageKey) ?? ""
        activeRiskWindows = Set(stored.components(separatedBy: ",").filter { !$0.isEmpty })
    }

    private var canSave: Bool {
        !selectedTrigger.isEmpty && !selectedResponse.isEmpty
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppStyle.largeSpacing) {
                        // High-Risk Time Selection
                        VStack(alignment: .leading, spacing: AppStyle.spacing) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.neonOrange)
                                Text("High-Risk Times")
                                    .font(Typography.headline)
                                    .foregroundColor(.appText)
                            }

                            Text("Tap to mark times when you're most likely to struggle")
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(Self.riskTimeOptions, id: \.key) { option in
                                    Button {
                                        toggleRiskWindow(option.key)
                                    } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: option.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(isRiskWindowActive(option.key) ? option.color : .subtleText)

                                            Text(option.title)
                                                .font(Typography.caption)
                                                .foregroundColor(isRiskWindowActive(option.key) ? .textPrimary : .subtleText)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(isRiskWindowActive(option.key) ? option.color.opacity(0.15) : Color.cardBackground)
                                        .cornerRadius(AppStyle.smallCornerRadius)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                                .stroke(isRiskWindowActive(option.key) ? option.color : Color.cardBorder, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .neonCard(glow: .neonOrange)

                        // Quick Suggestions
                        if !suggestedPlans.isEmpty {
                            VStack(alignment: .leading, spacing: AppStyle.spacing) {
                                Text("Quick Add Suggestions")
                                    .font(Typography.headline)
                                    .foregroundColor(.neonCyan)

                                ForEach(suggestedPlans, id: \.ifTrigger) { plan in
                                    Button {
                                        selectedTrigger = plan.ifTrigger
                                        selectedResponse = plan.thenAction
                                    } label: {
                                        HStack(spacing: 8) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("IF \(plan.ifTrigger)")
                                                    .font(Typography.caption)
                                                    .foregroundColor(.neonOrange)
                                                Text("THEN \(plan.thenAction)")
                                                    .font(Typography.caption)
                                                    .foregroundColor(.neonGreen)
                                            }
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.neonCyan)
                                        }
                                        .padding(12)
                                        .background(Color.cardBackground)
                                        .cornerRadius(AppStyle.smallCornerRadius)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                                .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .neonCard(glow: .neonCyan)
                        }

                        // IF Section
                        VStack(alignment: .leading, spacing: AppStyle.spacing) {
                            Text("IF this happens...")
                                .font(Typography.headline)
                                .foregroundColor(.neonOrange)

                            triggerPicker

                            TextField("Add detail (optional)", text: $triggerDetail)
                                .font(Typography.body)
                                .foregroundColor(.textPrimary)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(Color.cardBorder, lineWidth: 1)
                                )
                        }
                        .neonCard(glow: .neonOrange)

                        // Arrow
                        Image(systemName: "arrow.down")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.textSecondary)

                        // THEN Section
                        VStack(alignment: .leading, spacing: AppStyle.spacing) {
                            Text("THEN I will...")
                                .font(Typography.headline)
                                .foregroundColor(.neonGreen)

                            responsePicker

                            TextField("Add detail (optional)", text: $responseDetail)
                                .font(Typography.body)
                                .foregroundColor(.textPrimary)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(Color.cardBorder, lineWidth: 1)
                                )
                        }
                        .neonCard(glow: .neonGreen)

                        // Save Button
                        Button {
                            onSave(selectedTrigger, triggerDetail, selectedResponse, responseDetail)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Save Plan")
                        }
                        .buttonStyle(RainbowButtonStyle())
                        .disabled(!canSave)
                        .opacity(canSave ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.vertical, AppStyle.largeSpacing)
                }
            }
            .navigationTitle("New If-Then Plan")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadRiskWindows() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.neonCyan)
                }
            }
        }
    }

    private var triggerPicker: some View {
        Menu {
            ForEach(triggers, id: \.self) { trigger in
                Button(trigger) {
                    selectedTrigger = trigger
                }
            }
        } label: {
            HStack {
                Text(selectedTrigger.isEmpty ? "Select trigger" : selectedTrigger)
                    .font(Typography.body)
                    .foregroundColor(selectedTrigger.isEmpty ? .textSecondary : .textPrimary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(AppStyle.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                    .stroke(Color.neonOrange.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var responsePicker: some View {
        Menu {
            ForEach(Self.responses, id: \.text) { response in
                Button {
                    selectedResponse = response.text
                } label: {
                    Label(response.text, systemImage: response.icon)
                }
            }
        } label: {
            HStack {
                if let match = Self.responses.first(where: { $0.text == selectedResponse }) {
                    Image(systemName: match.icon)
                        .font(Typography.body)
                        .foregroundColor(.neonGreen)
                }
                Text(selectedResponse.isEmpty ? "Select response" : selectedResponse)
                    .font(Typography.body)
                    .foregroundColor(selectedResponse.isEmpty ? .textSecondary : .textPrimary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(AppStyle.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                    .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Edit Plan Sheet

struct EditPlanSheet: View {

    @Environment(\.presentationMode) var presentationMode
    let plan: CDIfThenPlan

    let triggers: [String]
    let onSave: () -> Void

    @State private var selectedTrigger: String = ""
    @State private var triggerDetail: String = ""
    @State private var selectedResponse: String = ""
    @State private var responseDetail: String = ""
    @State private var activeRiskWindows: Set<String> = []

    private var highRiskStorageKey: String {
        guard let id = plan.habitId else { return "highRiskWindows_default" }
        return "highRiskWindows_\(id.uuidString)"
    }

    private func isRiskWindowActive(_ key: String) -> Bool { activeRiskWindows.contains(key) }

    private func toggleRiskWindow(_ key: String) {
        if activeRiskWindows.contains(key) { activeRiskWindows.remove(key) }
        else { activeRiskWindows.insert(key) }
        UserDefaults.standard.set(activeRiskWindows.sorted().joined(separator: ","), forKey: highRiskStorageKey)
    }

    private func loadRiskWindows() {
        let stored = UserDefaults.standard.string(forKey: highRiskStorageKey) ?? ""
        activeRiskWindows = Set(stored.components(separatedBy: ",").filter { !$0.isEmpty })
    }

    private static let riskTimeOptions: [(title: String, icon: String, color: Color, key: String)] = [
        ("Morning", "sunrise.fill", .neonGold, "risk_morning"),
        ("Afternoon", "sun.max.fill", .neonOrange, "risk_afternoon"),
        ("Evening", "sunset.fill", .neonPurple, "risk_evening"),
        ("Night", "moon.fill", .neonBlue, "risk_night")
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppStyle.largeSpacing) {
                        // High-Risk Time Selection
                        VStack(alignment: .leading, spacing: AppStyle.spacing) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.neonOrange)
                                Text("High-Risk Times").font(Typography.headline).foregroundColor(.appText)
                            }
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(Self.riskTimeOptions, id: \.key) { option in
                                    Button { toggleRiskWindow(option.key) } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: option.icon).font(.system(size: 24))
                                                .foregroundColor(isRiskWindowActive(option.key) ? option.color : .subtleText)
                                            Text(option.title).font(Typography.caption)
                                                .foregroundColor(isRiskWindowActive(option.key) ? .textPrimary : .subtleText)
                                        }
                                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                                        .background(isRiskWindowActive(option.key) ? option.color.opacity(0.15) : Color.cardBackground)
                                        .cornerRadius(AppStyle.smallCornerRadius)
                                        .overlay(RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                            .stroke(isRiskWindowActive(option.key) ? option.color : Color.cardBorder, lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .neonCard(glow: .neonOrange)

                        // IF Section
                        VStack(alignment: .leading, spacing: AppStyle.spacing) {
                            Text("IF this happens...")
                                .font(Typography.headline)
                                .foregroundColor(.neonOrange)

                            Menu {
                                ForEach(triggers, id: \.self) { trigger in
                                    Button(trigger) {
                                        selectedTrigger = trigger
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedTrigger.isEmpty ? "Select trigger" : selectedTrigger)
                                        .font(Typography.body)
                                        .foregroundColor(selectedTrigger.isEmpty ? .textSecondary : .textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(Typography.caption)
                                        .foregroundColor(.textSecondary)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(Color.neonOrange.opacity(0.3), lineWidth: 1)
                                )
                            }

                            TextField("Add detail (optional)", text: $triggerDetail)
                                .font(Typography.body)
                                .foregroundColor(.textPrimary)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(Color.cardBorder, lineWidth: 1)
                                )
                        }
                        .neonCard(glow: .neonOrange)

                        // Arrow
                        Image(systemName: "arrow.down")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.textSecondary)

                        // THEN Section
                        VStack(alignment: .leading, spacing: AppStyle.spacing) {
                            Text("THEN I will...")
                                .font(Typography.headline)
                                .foregroundColor(.neonGreen)

                            Menu {
                                ForEach(CreatePlanSheet.responses, id: \.text) { response in
                                    Button {
                                        selectedResponse = response.text
                                    } label: {
                                        Label(response.text, systemImage: response.icon)
                                    }
                                }
                            } label: {
                                HStack {
                                    if let match = CreatePlanSheet.responses.first(where: { $0.text == selectedResponse }) {
                                        Image(systemName: match.icon)
                                            .font(Typography.body)
                                            .foregroundColor(.neonGreen)
                                    }
                                    Text(selectedResponse.isEmpty ? "Select response" : selectedResponse)
                                        .font(Typography.body)
                                        .foregroundColor(selectedResponse.isEmpty ? .textSecondary : .textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(Typography.caption)
                                        .foregroundColor(.textSecondary)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
                                )
                            }

                            TextField("Add detail (optional)", text: $responseDetail)
                                .font(Typography.body)
                                .foregroundColor(.textPrimary)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(AppStyle.smallCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                        .stroke(Color.cardBorder, lineWidth: 1)
                                )
                        }
                        .neonCard(glow: .neonGreen)

                        // Save Button
                        Button {
                            plan.triggerType = selectedTrigger
                            plan.triggerDetails = triggerDetail.isEmpty ? nil : triggerDetail
                            plan.thenSteps = selectedResponse
                            plan.responseDetail = responseDetail.isEmpty ? nil : responseDetail
                            onSave()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Save Changes")
                        }
                        .buttonStyle(RainbowButtonStyle())
                        .disabled(selectedTrigger.isEmpty || selectedResponse.isEmpty)
                        .opacity((selectedTrigger.isEmpty || selectedResponse.isEmpty) ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.vertical, AppStyle.largeSpacing)
                }
            }
            .navigationTitle("Edit Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.neonCyan)
                }
            }
            .onAppear {
                selectedTrigger = plan.triggerType
                triggerDetail = plan.triggerDetails ?? ""
                selectedResponse = plan.thenSteps ?? ""
                responseDetail = plan.responseDetail ?? ""
                loadRiskWindows()
            }
        }
    }
}

// MARK: - Previews

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
            .environment(\.managedObjectContext, CoreDataStack.preview.viewContext)
            .preferredColorScheme(.dark)
    }
}
