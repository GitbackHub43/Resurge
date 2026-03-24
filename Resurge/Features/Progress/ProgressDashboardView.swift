import SwiftUI
import CoreData

struct ProgressDashboardView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var activeHabits: FetchedResults<CDHabit>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDAchievementUnlock.unlockedAt, ascending: false)],
        animation: .default
    ) private var unlocks: FetchedResults<CDAchievementUnlock>

    // Habit pill switcher
    @State private var selectedHabitIndex: Int = 0

    // Calendar state
    @State private var selectedMonth: Date = DebugDate.now

    // Collapsible streak+calendar
    @State private var isStreakCalendarExpanded: Bool = true

    // MARK: - Selected Habit

    private var selectedHabit: CDHabit? {
        guard !activeHabits.isEmpty else { return nil }
        return activeHabits[min(selectedHabitIndex, activeHabits.count - 1)]
    }

    private var selectedProgramType: ProgramType {
        guard let habit = selectedHabit else { return .smoking }
        return ProgramType(rawValue: habit.programType) ?? .smoking
    }

    // MARK: - Computed Aggregates (filtered by selected habit)

    private var currentStreak: Int {
        guard let habit = selectedHabit else { return 0 }
        return habit.currentStreak
    }

    private var bestStreak: Int {
        guard let habit = selectedHabit else { return 0 }
        return MetricsEngine.bestStreak(for: habit)
    }

    private var habitTimeSavedMinutes: Double {
        guard let habit = selectedHabit else { return 0 }
        return habit.timeSavedMinutes
    }

    private var unlockedKeys: Set<String> {
        let filtered: [CDAchievementUnlock]
        if let habit = selectedHabit {
            filtered = unlocks.filter { $0.habit == habit }
        } else {
            filtered = Array(unlocks)
        }
        return Set(filtered.map { $0.achievementKey })
    }

    private var allUnlockedKeys: Set<String> {
        Set(unlocks.map { $0.achievementKey })
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppStyle.largeSpacing) {

                        // [0] Habit Pill Switcher
                        if activeHabits.count > 1 {
                            insightsHabitPillSwitcher
                        }

                        // [1] Streak + Calendar (merged, collapsible)
                        streakCalendarSection

                        RainbowDivider()
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [2] Health Milestones
                        healthMilestonesSection

                        RainbowDivider()
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [3] Time Reclaimed
                        timeReclaimedSection

                        RainbowDivider()
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [4] Badges
                        badgesSection

                        RainbowDivider()
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [5] Analytics Preview (premium)
                        analyticsSection

                        RainbowDivider()
                            .padding(.horizontal, AppStyle.screenPadding)

                        // [6] Recent Activity
                        recentActivitySection
                    }
                    .padding(.vertical, AppStyle.screenPadding)
                }
            }
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ActivePetView()
                }
            }
            .onChange(of: activeHabits.count) { _ in
                if selectedHabitIndex >= activeHabits.count {
                    selectedHabitIndex = max(activeHabits.count - 1, 0)
                }
            }
        }
    }

    // MARK: - Habit Pill Switcher

    private var insightsHabitPillSwitcher: some View {
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

    // MARK: - [1] Streak + Calendar (Merged, Collapsible)

    private var streakCalendarSection: some View {
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedMonth)
        let monthStart = calendar.date(from: comps) ?? selectedMonth
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        // .weekday: 1=Sunday, 2=Monday, ... 7=Saturday (always, regardless of firstWeekday)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingBlanks = firstWeekday - 1 // Sunday-first: Sunday=0 blanks, Monday=1, etc.
        let logEntries = fetchLogEntries(for: monthStart)
        let today = DebugDate.startOfToday

        return VStack(alignment: .leading, spacing: AppStyle.spacing) {
            // Header with chevron toggle
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isStreakCalendarExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.neonOrange)
                    Text("Recovery Calendar")
                        .font(Typography.headline)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Image(systemName: isStreakCalendarExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.subtleText)
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Large streak count
            VStack(spacing: 4) {
                if currentStreak > 0 {
                    HStack(spacing: 6) {
                        Text("\u{1F525}")
                            .font(.title2)
                        Text("\(currentStreak) Day Streak")
                            .font(Typography.title)
                            .foregroundColor(.neonOrange)
                    }
                }

                if bestStreak > 0 {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundColor(.neonGold)
                        Text("Best streak: \(bestStreak) day\(bestStreak == 1 ? "" : "s")")
                            .font(Typography.callout)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            if isStreakCalendarExpanded {
                // Month navigation
                HStack {
                    Button(action: {
                        var newComps = calendar.dateComponents([.year, .month], from: monthStart)
                        newComps.month = (newComps.month ?? 1) - 1
                        if let prev = calendar.date(from: newComps) {
                            selectedMonth = prev
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.neonCyan)
                    }

                    Spacer()

                    Text(monthYearString(from: monthStart))
                        .font(.headline.weight(.bold))
                        .foregroundColor(.appText)

                    Spacer()

                    Button(action: {
                        var newComps = calendar.dateComponents([.year, .month], from: monthStart)
                        newComps.month = (newComps.month ?? 1) + 1
                        if let next = calendar.date(from: newComps) {
                            selectedMonth = next
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.neonCyan)
                    }
                }
                .padding(.horizontal, 4)

                // Day-of-week headers
                let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(0..<7, id: \.self) { i in
                        Text(weekdays[i])
                            .font(.caption.weight(.bold))
                            .foregroundColor(.subtleText)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Calendar grid with flame overlays
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                    // Leading blanks
                    ForEach(0..<leadingBlanks, id: \.self) { _ in
                        Color.clear
                            .frame(width: 28, height: 28)
                    }

                    // Days of the month
                    ForEach(1...daysInMonth, id: \.self) { day in
                        let dayDate = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart
                        let dayStart = calendar.startOfDay(for: dayDate)
                        let isFuture = dayStart > today
                        let status = dayStatus(for: dayStart, logEntries: logEntries, isFuture: isFuture)

                        ZStack {
                            Circle()
                                .fill(status.color)
                                .frame(width: 28, height: 28)

                            if status.showFlame {
                                Text("\u{1F525}")
                                    .font(.system(size: 11))
                                    .offset(x: 8, y: -8)
                            }

                            if status.showLapseX {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 12, height: 12)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 6, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 8, y: -8)
                            }

                            Text("\(day)")
                                .font(.caption2.weight(.medium))
                                .foregroundColor(status.textColor)
                        }
                    }
                }
            }
        }
        .neonCard(glow: .neonOrange)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - [2] Health Milestones Section

    private var healthMilestonesSection: some View {
        let milestones = HealthMilestone.milestones(for: selectedProgramType)
        let daysCount = selectedHabit?.daysSoberCount ?? 0
        let achieved = milestones.filter { daysCount >= ($0.requiredMinutes / 1440) }.count

        return VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppStyle.spacing) {
                sectionHeader(icon: "heart.fill", title: "Health Milestones", color: .neonGreen)

                VStack(spacing: 8) {
                    Text("\(achieved)/\(milestones.count)")
                        .font(Typography.statValue)
                        .foregroundColor(.neonGreen)

                    Text("milestones reached")
                        .font(Typography.statLabel)
                        .foregroundColor(.textSecondary)

                    // Show next 3 upcoming milestones
                    let upcoming = milestones.filter { daysCount < ($0.requiredMinutes / 1440) }.prefix(3)
                    if !upcoming.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(Array(upcoming)) { milestone in
                                let milestoneDays = milestone.requiredMinutes / 1440
                                let progress = milestoneDays > 0 ? min(Double(daysCount) / Double(milestoneDays), 1.0) : 0

                                HStack(spacing: 10) {
                                    Image(systemName: milestone.iconName)
                                        .font(.system(size: 14))
                                        .foregroundColor(.neonGreen)
                                        .frame(width: 20)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(milestone.title)
                                            .font(Typography.caption)
                                            .foregroundColor(.textPrimary)

                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(Color.neonGreen.opacity(0.15))
                                                    .frame(height: 4)
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(Color.neonGreen)
                                                    .frame(width: geo.size.width * CGFloat(progress), height: 4)
                                            }
                                        }
                                        .frame(height: 4)
                                    }

                                    Text(milestone.timeDescription)
                                        .font(Typography.caption)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .neonCard(glow: .neonGreen)
            .padding(.horizontal, AppStyle.screenPadding)

            Text("Health milestones are based on published medical research and are for informational purposes only. This app does not provide medical advice. Consult a healthcare professional for personalized guidance.")
                .font(Typography.footnote)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.top, 4)
        }
    }

    // MARK: - [3] Time Reclaimed Section

    private var timeReclaimedSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            sectionHeader(icon: "clock.fill", title: "Time Reclaimed", color: .neonCyan)

            VStack(spacing: 8) {
                Text(formatTime(habitTimeSavedMinutes))
                    .font(Typography.statValue)
                    .foregroundColor(.neonCyan)

                if habitTimeSavedMinutes > 0 {
                    Text(timeEquivalentText)
                        .font(Typography.footnote)
                        .foregroundColor(.textSecondary)
                        .italic()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .neonCard(glow: .neonCyan)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - [4] Badges Section

    private var badgesSection: some View {
        let healthBadgesForHabit = MilestoneBadge.healthBadges(for: selectedProgramType)
        let programBadgesForHabit = MilestoneBadge.programBadges.filter { $0.programType == selectedProgramType }
        let journalBadges = MilestoneBadge.behaviorBadges.filter { $0.key.contains("journal") }
        let allBadgesRaw = MilestoneBadge.streakBadges + MilestoneBadge.timeBadges + healthBadgesForHabit + journalBadges + programBadgesForHabit
        var seenKeys = Set<String>()
        let allBadges = allBadgesRaw.filter { seenKeys.insert($0.key).inserted }
        let recentUnlocked = allBadges.filter { unlockedKeys.contains($0.key) }.prefix(4)

        return VStack(alignment: .leading, spacing: AppStyle.spacing) {
            HStack {
                sectionHeader(icon: "trophy.fill", title: "Badges", color: .neonPurple)
                Spacer()
            }

            // Show up to 4 recently unlocked badges in a row
            if !recentUnlocked.isEmpty {
                HStack(spacing: 16) {
                    ForEach(Array(recentUnlocked)) { badge in
                        badgeCircle(badge: badge, isUnlocked: true)
                    }
                    Spacer()
                }
            } else {
                Text("Complete daily rituals to unlock badges!")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }

            // "View All Badges" button
            NavigationLink(destination: AchievementsView()) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.neonPurple)
                    Text("View All Badges")
                        .font(Typography.headline)
                        .foregroundColor(.appText)
                    Spacer()
                    Text("\(unlockedKeys.count)/\(allBadges.count)")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                    Image(systemName: "chevron.right")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .padding(AppStyle.cardPadding)
                .background(Color.neonPurple.opacity(0.08))
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.neonPurple.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Text("Unlock badges by hitting streaks, reclaiming time, reaching health milestones, and journaling.")
                .font(Typography.caption)
                .foregroundColor(.subtleText)
        }
        .neonCard(glow: .neonPurple)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - [5] Analytics Section

    private var analyticsSection: some View {
        Group {
            if UserDefaults.standard.bool(forKey: "isPremium") {
                NavigationLink(destination: AdvancedAnalyticsView()) {
                    HStack {
                        Image(systemName: "chart.xyaxis.line").foregroundColor(.neonPurple)
                        Text("Advanced Analytics").font(Typography.headline).foregroundColor(.appText)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.subtleText)
                    }
                    .padding(AppStyle.cardPadding)
                    .background(Color.neonPurple.opacity(0.08))
                    .cornerRadius(AppStyle.cornerRadius)
                    .overlay(RoundedRectangle(cornerRadius: AppStyle.cornerRadius).stroke(Color.neonPurple.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppStyle.screenPadding)
            } else {
                // Show locked analytics preview for free users
                Button {
                    // Show premium gate
                } label: {
                    HStack {
                        Image(systemName: "chart.xyaxis.line").foregroundColor(.neonPurple)
                        Text("Advanced Analytics").font(Typography.headline).foregroundColor(.appText)
                        Spacer()
                        Image(systemName: "lock.fill").foregroundColor(.neonGold)
                    }
                    .padding(AppStyle.cardPadding)
                    .background(Color.neonPurple.opacity(0.05))
                    .cornerRadius(AppStyle.cornerRadius)
                    .overlay(RoundedRectangle(cornerRadius: AppStyle.cornerRadius).stroke(Color.neonGold.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppStyle.screenPadding)
            }
        }
    }

    // MARK: - [6] Recent Activity Section

    private var recentActivitySection: some View {
        let events = fetchRecentActivity()

        return VStack(alignment: .leading, spacing: AppStyle.spacing) {
            sectionHeader(icon: "clock.fill", title: "Recent Activity", color: .neonCyan)

            if events.isEmpty {
                Text("No recent activity")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 10) {
                    ForEach(events.indices, id: \.self) { index in
                        let event = events[index]
                        HStack(spacing: 12) {
                            // Colored icon circle
                            ZStack {
                                Circle()
                                    .fill(event.color.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: event.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(event.color)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.description)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.appText)
                                HStack(spacing: 6) {
                                    Text({
                                        let f = DateFormatter(); f.dateFormat = "MMM d, h:mm a"
                                        return f.string(from: event.date)
                                    }())
                                        .font(.system(size: 10))
                                        .foregroundColor(.subtleText.opacity(0.7))
                                    Text(event.relativeTime)
                                        .font(Typography.caption)
                                        .foregroundColor(.subtleText)
                                }
                            }

                            Spacer()
                        }

                        if index < events.count - 1 {
                            Divider()
                                .background(Color.subtleText.opacity(0.2))
                        }
                    }
                }
            }

            // See All link
            NavigationLink(destination: ActivityLogView()) {
                HStack {
                    Spacer()
                    Text("See All")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.neonCyan)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.neonCyan)
                    Spacer()
                }
                .padding(.top, 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .neonCard(glow: .neonCyan)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Subviews

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(title)
                .font(Typography.headline)
                .foregroundColor(.textPrimary)
        }
    }

    private func badgeCircle(badge: MilestoneBadge, isUnlocked: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                BadgeEmblemView(badge: badge, isUnlocked: isUnlocked, size: 52)

                if badge.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.neonGold)
                        .offset(x: -16, y: -16)
                }
            }

            Text(badge.title)
                .font(Typography.badge)
                .foregroundColor(isUnlocked ? .textPrimary : .textSecondary)
                .lineLimit(1)
                .frame(width: 60)
        }
    }

    // MARK: - Calendar Helpers

    private struct DayDisplayStatus {
        let color: Color
        let textColor: Color
        let showFlame: Bool
        let showLapseX: Bool

        init(color: Color, textColor: Color, showFlame: Bool, showLapseX: Bool = false) {
            self.color = color
            self.textColor = textColor
            self.showFlame = showFlame
            self.showLapseX = showLapseX
        }
    }

    private func dayStatus(for date: Date, logEntries: [CDDailyLogEntry], isFuture: Bool) -> DayDisplayStatus {
        if isFuture {
            return DayDisplayStatus(color: Color.gray.opacity(0.1), textColor: .gray.opacity(0.4), showFlame: false)
        }

        let calendar = Calendar.current
        let matchingEntries = logEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }

        // Also check CDCravingEntry for lapses (gave in from craving alert)
        var hasCravingLapse = false
        if let habit = selectedHabit {
            let cravingRequest = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
            cravingRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "habit == %@", habit),
                NSPredicate(format: "didResist == NO"),
                NSPredicate(format: "timestamp >= %@ AND timestamp < %@", dayStart as NSDate, dayEnd as NSDate)
            ])
            cravingRequest.fetchLimit = 1
            hasCravingLapse = ((try? viewContext.fetch(cravingRequest))?.count ?? 0) > 0
        }

        if hasCravingLapse {
            return DayDisplayStatus(color: Color.red.opacity(0.7), textColor: .white, showFlame: false, showLapseX: true)
        }

        if !matchingEntries.isEmpty {
            // If ANY entry for this day has a lapse, the day is a lapse day
            let hasLapse = matchingEntries.contains { $0.lapsedToday }
            if hasLapse {
                return DayDisplayStatus(color: Color.red.opacity(0.7), textColor: .white, showFlame: false, showLapseX: true)
            } else {
                return DayDisplayStatus(color: Color.green.opacity(0.7), textColor: .white, showFlame: true)
            }
        }

        // No data for this day
        let today = DebugDate.startOfToday
        if date <= today {
            return DayDisplayStatus(color: Color.gray.opacity(0.15), textColor: .subtleText, showFlame: false)
        }

        return DayDisplayStatus(color: Color.gray.opacity(0.1), textColor: .gray.opacity(0.4), showFlame: false)
    }

    private func fetchLogEntries(for monthStart: Date) -> [CDDailyLogEntry] {
        let calendar = Calendar.current
        guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return [] }

        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        var predicates: [NSPredicate] = [
            NSPredicate(format: "date >= %@ AND date < %@", monthStart as NSDate, monthEnd as NSDate)
        ]
        if let habit = selectedHabit {
            predicates.append(NSPredicate(format: "habit == %@", habit))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDDailyLogEntry.date, ascending: true)]

        return (try? viewContext.fetch(request)) ?? []
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Recent Activity Helpers

    private struct ActivityEvent {
        let icon: String
        let color: Color
        let description: String
        let date: Date
        let relativeTime: String
    }

    private func fetchRecentActivity() -> [ActivityEvent] {
        var events: [ActivityEvent] = []

        // Fetch cravings
        let cravingRequest = NSFetchRequest<CDCravingEntry>(entityName: "CDCravingEntry")
        if let habit = selectedHabit {
            cravingRequest.predicate = NSPredicate(format: "habit == %@", habit)
        }
        cravingRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDCravingEntry.timestamp, ascending: false)]
        // No fetch limit — show all
        if let cravings = try? viewContext.fetch(cravingRequest) {
            for craving in cravings {
                let habitLabel = craving.habit?.safeDisplayName
                if craving.didResist {
                    let desc = habitLabel != nil ? "Craving resisted for \(habitLabel!)" : "Craving resisted"
                    events.append(ActivityEvent(icon: "shield.fill", color: .neonGreen, description: desc, date: craving.timestamp, relativeTime: relativeTimeString(from: craving.timestamp)))
                } else {
                    let desc = habitLabel != nil ? "Lapse logged for \(habitLabel!)" : "Lapse logged"
                    events.append(ActivityEvent(icon: "exclamationmark.triangle.fill", color: .neonOrange, description: desc, date: craving.timestamp, relativeTime: relativeTimeString(from: craving.timestamp)))
                }
            }
        }

        // Fetch daily logs — ALL types (morning, afternoon, evening)
        let logRequest = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        if let habit = selectedHabit {
            logRequest.predicate = NSPredicate(format: "habit == %@", habit)
        }
        logRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDDailyLogEntry.createdAt, ascending: false)]
        // No fetch limit — show all
        if let logs = try? viewContext.fetch(logRequest) {
            for log in logs {
                let habitLabel = log.habit?.safeDisplayName ?? ""
                let entryLabel: String
                let icon: String
                let color: Color
                switch log.entryType {
                case "morning":
                    entryLabel = "Morning Plan for \(habitLabel)"
                    icon = "sunrise.fill"
                    color = .neonGold
                case "afternoon":
                    entryLabel = "Afternoon Check-In for \(habitLabel)"
                    icon = "sun.max.fill"
                    color = .neonCyan
                case "evening":
                    entryLabel = "Evening Review for \(habitLabel)"
                    icon = "moon.stars.fill"
                    color = .neonPurple
                default:
                    entryLabel = "Daily check-in for \(habitLabel)"
                    icon = "checkmark.circle.fill"
                    color = .neonGold
                }
                events.append(ActivityEvent(icon: icon, color: color, description: entryLabel, date: log.createdAt, relativeTime: relativeTimeString(from: log.createdAt)))
            }
        }

        // Fetch journal entries
        let journalRequest = NSFetchRequest<CDJournalEntry>(entityName: "CDJournalEntry")
        if let habit = selectedHabit {
            journalRequest.predicate = NSPredicate(format: "habit == %@", habit)
        }
        journalRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDJournalEntry.createdAt, ascending: false)]
        // No fetch limit — show all
        if let journals = try? viewContext.fetch(journalRequest) {
            for journal in journals {
                let habitLabel = journal.habit?.safeDisplayName ?? ""
                let isGratitude = journal.promptUsed?.contains("gratitude") == true
                let isCravingJournal = journal.promptUsed?.contains("craving") == true
                let desc: String
                let icon: String
                let color: Color
                if isGratitude {
                    desc = "Gratitude log for \(habitLabel)"
                    icon = "heart.fill"
                    color = .neonGold
                } else if isCravingJournal {
                    desc = "Craving journal for \(habitLabel)"
                    icon = "bolt.heart.fill"
                    color = .neonOrange
                } else {
                    desc = "Journal entry for \(habitLabel)"
                    icon = "book.fill"
                    color = .neonBlue
                }
                events.append(ActivityEvent(icon: icon, color: color, description: desc, date: journal.createdAt, relativeTime: relativeTimeString(from: journal.createdAt)))
            }
        }

        // Fetch If-Then Plans
        if let habit = selectedHabit {
            let planRequest = NSFetchRequest<CDIfThenPlan>(entityName: "CDIfThenPlan")
            planRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "habitId == %@", habit.id as CVarArg),
                NSPredicate(format: "activeFlag == YES")
            ])
            planRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDIfThenPlan.createdAt, ascending: false)]
            // No fetch limit — show all
            if let plans = try? viewContext.fetch(planRequest) {
                for plan in plans {
                    events.append(ActivityEvent(icon: "shield.fill", color: .neonGreen, description: "If-Then Plan: \(plan.triggerType)", date: plan.createdAt, relativeTime: relativeTimeString(from: plan.createdAt)))
                }
            }
        }

        // Sort by date descending, show most recent 10
        events.sort { $0.date > $1.date }
        return Array(events.prefix(10))
    }

    private func relativeTimeString(from date: Date) -> String {
        let now = DebugDate.now
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: now)
            let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
            if date >= startOfYesterday {
                return "Yesterday"
            } else {
                let days = Int(interval / 86400)
                return "\(days)d ago"
            }
        }
    }

    // MARK: - Helpers

    private func formatTime(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }

    private var timeEquivalentText: String {
        let hours = habitTimeSavedMinutes / 60.0
        if hours >= 6 {
            let books = Int(hours / 6)
            return "That's \(books) book\(books == 1 ? "" : "s") worth of reading!"
        } else if hours >= 2 {
            let movies = Int(hours / 2)
            return "That's \(movies) movie\(movies == 1 ? "" : "s")!"
        }
        return "Keep going to reclaim more time!"
    }

}

// MARK: - Preview

struct ProgressDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        ProgressDashboardView()
            .environment(\.managedObjectContext, env.viewContext)
            .environmentObject(env)
            .preferredColorScheme(.dark)
    }
}
