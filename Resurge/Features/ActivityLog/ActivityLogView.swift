import SwiftUI
import CoreData

struct ActivityLogView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var activeHabits: FetchedResults<CDHabit>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDDailyLogEntry.createdAt, ascending: false)],
        animation: .default
    ) private var logEntries: FetchedResults<CDDailyLogEntry>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDCravingEntry.timestamp, ascending: false)],
        animation: .default
    ) private var cravingEntries: FetchedResults<CDCravingEntry>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDJournalEntry.createdAt, ascending: false)],
        animation: .default
    ) private var journalEntries: FetchedResults<CDJournalEntry>

    @State private var selectedDetailEntry: CDDailyLogEntry?
    @State private var selectedJournalEntry: CDJournalEntry?
    @State private var selectedFilter: EntryFilter = .dailyLoop
    @State private var selectedHabitIndex: Int = 0
    @State private var itemToDelete: TimelineItem?
    @State private var showDeleteConfirm = false

    enum EntryFilter: String, CaseIterable {
        case dailyLoop = "Daily Loop"
        case journal = "Journal"
        case gratitude = "Gratitude"
        case cravingJournal = "Craving Journal"
        case cravings = "Cravings"
        case plans = "Plans"
        case all = "All"
    }

    // MARK: - Selected Habit

    private var selectedHabit: CDHabit? {
        guard !activeHabits.isEmpty else { return nil }
        return activeHabits[min(selectedHabitIndex, activeHabits.count - 1)]
    }

    // MARK: - Filtered by Habit

    private var habitLogEntries: [CDDailyLogEntry] {
        guard let habit = selectedHabit else { return Array(logEntries) }
        return logEntries.filter { $0.habit?.id == habit.id }
    }

    private var habitCravingEntries: [CDCravingEntry] {
        guard let habit = selectedHabit else { return Array(cravingEntries) }
        return cravingEntries.filter { $0.habit?.id == habit.id }
    }

    private var habitJournalEntries: [CDJournalEntry] {
        guard let habit = selectedHabit else { return Array(journalEntries) }
        return journalEntries.filter { $0.habit?.id == habit.id }
    }

    // MARK: - Unified Timeline Item

    private enum TimelineItem: Identifiable {
        case checkIn(CDDailyLogEntry)
        case lapse(CDDailyLogEntry)
        case craving(CDCravingEntry)
        case journal(CDJournalEntry)
        case plan(CDIfThenPlan)

        var id: String {
            switch self {
            case .checkIn(let e): return "checkin-\(e.id)"
            case .lapse(let e): return "lapse-\(e.id)"
            case .craving(let e): return "craving-\(e.id)"
            case .journal(let e): return "journal-\(e.id)"
            case .plan(let p): return "plan-\(p.id)"
            }
        }

        var date: Date {
            switch self {
            case .checkIn(let e): return e.createdAt
            case .lapse(let e): return e.createdAt
            case .craving(let e): return e.timestamp
            case .journal(let e): return e.createdAt
            case .plan(let p): return p.createdAt
            }
        }
    }

    private var timelineItems: [TimelineItem] {
        var items: [TimelineItem] = []

        switch selectedFilter {
        case .all:
            for entry in habitLogEntries {
                items.append(.checkIn(entry))
                if entry.lapsedToday {
                    items.append(.lapse(entry))
                }
            }
            for craving in habitCravingEntries {
                items.append(.craving(craving))
            }
            for journal in habitJournalEntries {
                items.append(.journal(journal))
            }
        case .dailyLoop:
            for entry in habitLogEntries {
                items.append(.checkIn(entry))
                if entry.lapsedToday {
                    items.append(.lapse(entry))
                }
            }
        case .journal:
            for journal in habitJournalEntries {
                // Exclude gratitude and craving journal entries from regular journal tab
                let tags = journal.promptUsed ?? ""
                if !tags.contains("gratitude") && !tags.contains("craving") {
                    items.append(.journal(journal))
                }
            }
        case .gratitude:
            for journal in habitJournalEntries {
                if let tags = journal.promptUsed, tags.contains("gratitude") {
                    items.append(.journal(journal))
                }
            }
        case .cravingJournal:
            for journal in habitJournalEntries {
                if let tags = journal.promptUsed, tags.contains("craving") {
                    items.append(.journal(journal))
                }
            }
        case .cravings:
            for craving in habitCravingEntries {
                items.append(.craving(craving))
            }
        case .plans:
            // Show actual If-Then plans created for this habit
            if let habit = selectedHabit {
                let planRequest = NSFetchRequest<CDIfThenPlan>(entityName: "CDIfThenPlan")
                planRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "activeFlag == YES"),
                    NSPredicate(format: "habitId == %@", habit.id as CVarArg)
                ])
                planRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDIfThenPlan.createdAt, ascending: false)]
                if let plans = try? viewContext.fetch(planRequest) {
                    for plan in plans {
                        items.append(.plan(plan))
                    }
                }
            }
        }

        return items.sorted { $0.date > $1.date }
    }

    // MARK: - Date Grouping

    private enum DateGroup: String, CaseIterable {
        case today = "Today"
        case yesterday = "Yesterday"
        case thisWeek = "This Week"
        case earlier = "Earlier"
    }

    private func dateGroup(for date: Date) -> DateGroup {
        let calendar = Calendar.current
        if calendar.isDate(date, inSameDayAs: DebugDate.now) { return .today }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: DebugDate.now),
           calendar.isDate(date, inSameDayAs: yesterday) { return .yesterday }
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: DebugDate.now) ?? DebugDate.now
        if date >= weekAgo { return .thisWeek }
        return .earlier
    }

    private func groupedItems() -> [(group: DateGroup, items: [TimelineItem])] {
        let all = timelineItems
        var grouped: [DateGroup: [TimelineItem]] = [:]
        for item in all {
            let group = dateGroup(for: item.date)
            grouped[group, default: []].append(item)
        }
        return DateGroup.allCases.compactMap { group in
            guard let items = grouped[group], !items.isEmpty else { return nil }
            return (group: group, items: items)
        }
    }

    // MARK: - Relative Time

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return f.string(from: date)
    }

    private func relativeTime(for date: Date) -> String {
        let seconds = Int(DebugDate.now.timeIntervalSince(date))
        if seconds < 60 { return "Just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days == 1 { return "Yesterday" }
        if days < 7 { return "\(days)d ago" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Habit Pill Switcher
                if activeHabits.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(activeHabits.enumerated()), id: \.element.id) { index, habit in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedHabitIndex = index
                                    }
                                } label: {
                                    Text(habit.name)
                                        .font(Typography.caption.weight(.semibold))
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
                        .padding(.vertical, 10)
                    }
                }

                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EntryFilter.allCases, id: \.rawValue) { filter in
                            filterPill(title: filter.rawValue, isSelected: selectedFilter == filter) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.vertical, 10)
                }

                // Content
                if timelineItems.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    List {
                        let sections = groupedItems()
                        ForEach(Array(sections.enumerated()), id: \.element.group.rawValue) { _, section in
                            Section {
                                ForEach(section.items) { item in
                                    timelineCard(for: item)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 5, leading: AppStyle.screenPadding, bottom: 5, trailing: AppStyle.screenPadding))
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                itemToDelete = item
                                                showDeleteConfirm = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            } header: {
                                Text(section.group.rawValue)
                                    .font(Typography.headline)
                                    .foregroundColor(.appText)
                                    .textCase(nil)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onAppear { UITableView.appearance().backgroundColor = .clear }
                }
            }
        }
        .navigationTitle("Activity Log")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedDetailEntry) { entry in
            entryDetailSheet(entry: entry)
        }
        .sheet(item: $selectedJournalEntry) { journal in
            if journal.promptUsed?.contains("craving") == true {
                cravingJournalDetailSheet(journal)
            } else {
                JournalEditorView(existingEntry: journal)
                    .environmentObject(environment)
            }
        }
        .alert("Delete Entry", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    deleteItem(item)
                }
            }
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this entry? This cannot be undone.")
        }
        .onChange(of: activeHabits.count) { _ in
            if selectedHabitIndex >= activeHabits.count {
                selectedHabitIndex = max(activeHabits.count - 1, 0)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundColor(Color.neonCyan.opacity(0.5))
            Text("No activity yet")
                .font(Typography.headline)
                .foregroundColor(.appText)
            Text("Complete your daily tasks to see your activity timeline here.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Filter Pill

    private func filterPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.caption.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? AnyView(
                            LinearGradient(
                                colors: [.neonCyan, .neonPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        : AnyView(Color.cardBackground)
                )
                .foregroundColor(isSelected ? .white : .appText)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Timeline Card

    @ViewBuilder
    private func timelineCard(for item: TimelineItem) -> some View {
        switch item {
        case .checkIn(let entry):
            checkInCard(entry)
        case .lapse(let entry):
            lapseCard(entry)
        case .craving(let entry):
            cravingCard(entry)
        case .journal(let entry):
            journalCard(entry)
        case .plan(let plan):
            planCard(plan)
        }
    }

    // MARK: - Plan Card

    private func planCard(_ plan: CDIfThenPlan) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.neonGreen)
                .frame(width: 4)

            HStack(spacing: 12) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.neonGreen)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("If-Then Plan")
                            .font(Typography.headline)
                            .foregroundColor(.appText)
                        Spacer()
                        Text(formatDate(plan.createdAt))
                            .font(.system(size: 10))
                            .foregroundColor(.subtleText.opacity(0.7))
                    }

                    Text("IF \(plan.triggerType) → THEN \(plan.thenSteps ?? "")")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                        .lineLimit(2)

                    Text(relativeTime(for: plan.createdAt))
                        .font(Typography.footnote)
                        .foregroundColor(.subtleText)
                }

                Spacer()
            }
            .padding(AppStyle.cardPadding)
        }
        .background(Color.neonGreen.opacity(0.03))
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(Color.neonGreen.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Check-In Card

    private func entryTypeLabel(for entry: CDDailyLogEntry) -> String {
        switch entry.entryType {
        case "morning": return "Morning Plan/Review"
        case "afternoon": return "Afternoon Check-In"
        case "evening": return "Evening Review/Reflection"
        default:
            // Fallback for old entries without entryType
            if entry.didPledge && !entry.didReflect { return "Morning Plan/Review" }
            if entry.didReflect && entry.wins == nil && entry.planForTomorrow == nil { return "Afternoon Check-In" }
            return "Evening Review/Reflection"
        }
    }

    private func entryTypeIcon(for entry: CDDailyLogEntry) -> String {
        switch entry.entryType {
        case "morning": return "sunrise.fill"
        case "afternoon": return "sun.max.fill"
        case "evening": return "moon.stars.fill"
        default: return "checkmark.circle.fill"
        }
    }

    private func entryTypeColor(for entry: CDDailyLogEntry) -> Color {
        switch entry.entryType {
        case "morning": return .neonGold
        case "afternoon": return .neonCyan
        case "evening": return .neonPurple
        default: return .neonCyan
        }
    }

    private func checkInCard(_ entry: CDDailyLogEntry) -> some View {
        Button {
            selectedDetailEntry = entry
        } label: {
            HStack(spacing: 0) {
                // Accent bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(entryTypeColor(for: entry))
                    .frame(width: 4)

                HStack(spacing: 12) {
                    // Entry type icon
                    ZStack {
                        Circle()
                            .fill(entryTypeColor(for: entry).opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: entryTypeIcon(for: entry))
                            .font(Typography.body)
                            .foregroundColor(entryTypeColor(for: entry))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entryTypeLabel(for: entry))
                                .font(Typography.headline)
                                .foregroundColor(.appText)
                            Spacer()
                            Text(relativeTime(for: entry.createdAt))
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)
                        }

                        // Date
                        Text(formatDate(entry.createdAt))
                            .font(.system(size: 10))
                            .foregroundColor(.subtleText.opacity(0.7))

                        if let habitName = entry.habit?.name {
                            Text(habitName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.neonPurple)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.neonPurple.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(12)
            }
            .background(Color.cardBackground)
            .cornerRadius(AppStyle.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                    .opacity(0.4)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Delete Item

    private func deleteItem(_ item: TimelineItem) {
        switch item {
        case .checkIn(let entry), .lapse(let entry):
            viewContext.delete(entry)
        case .craving(let entry):
            viewContext.delete(entry)
        case .journal(let entry):
            viewContext.delete(entry)
        case .plan(let plan):
            viewContext.delete(plan)
        }
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete item: \(error.localizedDescription)")
        }
        itemToDelete = nil
    }

    // MARK: - Lapse Card

    private func lapseCard(_ entry: CDDailyLogEntry) -> some View {
        HStack(spacing: 0) {
            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.neonOrange)
                .frame(width: 4)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.neonOrange.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(Typography.body)
                        .foregroundColor(.neonOrange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Lapse logged")
                            .font(Typography.headline)
                            .foregroundColor(.neonOrange)
                        Spacer()
                        Text(relativeTime(for: entry.createdAt))
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }

                    if let notes = entry.lapseNotes, !notes.isEmpty {
                        Text(notes)
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                            .lineLimit(2)
                    }
                }
            }
            .padding(12)
        }
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.smallCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                .stroke(Color.neonOrange.opacity(0.3), lineWidth: 0.5)
        )
    }

    // MARK: - Craving Card

    private func cravingCard(_ entry: CDCravingEntry) -> some View {
        let accentColor: Color = entry.didResist ? .neonGreen : .neonOrange
        let iconName = entry.didResist ? "shield.checkered" : "exclamationmark.triangle"

        return HStack(spacing: 0) {
            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 4)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: iconName)
                        .font(Typography.body)
                        .foregroundColor(accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.didResist ? "Craving resisted" : "Craving")
                            .font(Typography.headline)
                            .foregroundColor(.appText)
                        Spacer()
                        Text(relativeTime(for: entry.timestamp))
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }

                    Text(formatDate(entry.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.subtleText.opacity(0.7))

                    HStack(spacing: 8) {
                        if let trigger = entry.triggerCategory, !trigger.isEmpty {
                            Text(trigger)
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)
                        }
                        Text("Intensity: \(entry.intensity)/10")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }

                    if let note = entry.triggerNote, !note.isEmpty {
                        Text(note)
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                            .lineLimit(2)
                    }
                }
            }
            .padding(12)
        }
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.smallCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .opacity(0.4)
        )
    }

    // MARK: - Journal Card

    private func journalCard(_ entry: CDJournalEntry) -> some View {
        let isGratitude = entry.promptUsed?.contains("gratitude") == true
        let isCravingJournal = entry.promptUsed?.contains("craving") == true
        let cardColor: Color = isGratitude ? .neonGold : (isCravingJournal ? .neonOrange : .neonBlue)
        let cardIcon = isGratitude ? "heart.fill" : (isCravingJournal ? "bolt.heart.fill" : "book.fill")
        let cardTitle = isGratitude ? "Gratitude Log" : (isCravingJournal ? "Craving Journal" : (entry.title ?? "Journal entry"))

        return Button {
            selectedJournalEntry = entry
        } label: {
        HStack(spacing: 0) {
            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(cardColor)
                .frame(width: 4)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: cardIcon)
                        .font(Typography.body)
                        .foregroundColor(cardColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(cardTitle)
                            .font(Typography.headline)
                            .foregroundColor(.appText)
                            .lineLimit(1)
                        Spacer()
                        Text(relativeTime(for: entry.createdAt))
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }

                    Text(formatDate(entry.createdAt))
                        .font(.system(size: 10))
                        .foregroundColor(.subtleText.opacity(0.7))

                    if let habitName = entry.habit?.name {
                        Text(habitName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(cardColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(cardColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(12)
        }
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.smallCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .opacity(0.4)
        )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Entry Detail Sheet

    @ViewBuilder
    private func entryDetailSheet(entry: CDDailyLogEntry) -> some View {
        if let habit = entry.habit {
            // Pass the actual entry so it loads that specific data (not just today's)
            switch entry.entryType {
            case "morning":
                MorningPlanView(habit: habit, initialEntry: entry)
                    .environmentObject(environment)
            case "afternoon":
                QuickCheckInView(habit: habit, initialEntry: entry)
                    .environmentObject(environment)
            case "evening":
                EveningReviewView(habit: habit, initialEntry: entry)
                    .environmentObject(environment)
            default:
                if entry.didPledge && !entry.didReflect {
                    MorningPlanView(habit: habit, initialEntry: entry)
                        .environmentObject(environment)
                } else if entry.didReflect && entry.wins == nil && entry.planForTomorrow == nil {
                    QuickCheckInView(habit: habit, initialEntry: entry)
                        .environmentObject(environment)
                } else {
                    EveningReviewView(habit: habit, initialEntry: entry)
                        .environmentObject(environment)
                }
            }
        } else {
            Text("Entry detail unavailable")
                .foregroundColor(.subtleText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackground.ignoresSafeArea())
        }
    }

    // MARK: - Craving Journal Detail Sheet

    private func cravingJournalDetailSheet(_ journal: CDJournalEntry) -> some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Date
                        HStack {
                            Image(systemName: "bolt.heart.fill")
                                .foregroundColor(.neonOrange)
                            Text(formatDate(journal.createdAt))
                                .font(Typography.callout)
                                .foregroundColor(.subtleText)
                            Spacer()
                        }

                        if let habitName = journal.habit?.name {
                            Text(habitName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.neonOrange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.neonOrange.opacity(0.1))
                                .cornerRadius(6)
                        }

                        // Journal content — same look as craving protocol
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What you wrote during your craving:")
                                .font(Typography.headline)
                                .foregroundColor(.neonOrange)

                            Text(journal.body)
                                .font(Typography.body)
                                .foregroundColor(.appText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(AppStyle.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                                .stroke(Color.neonOrange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Craving Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        selectedJournalEntry = nil
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct ActivityLogView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            ActivityLogView()
                .environment(\.managedObjectContext, env.viewContext)
                .environmentObject(env)
        }
    }
}
