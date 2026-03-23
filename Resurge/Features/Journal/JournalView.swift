import SwiftUI
import CoreData

struct JournalView: View {
    @EnvironmentObject var environment: AppEnvironment
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDJournalEntry.date, ascending: false)],
        animation: .default
    ) private var entries: FetchedResults<CDJournalEntry>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES")
    ) private var habits: FetchedResults<CDHabit>

    @State private var showEditor = false
    @State private var editingEntry: CDJournalEntry?
    @State private var promptToPreFill: String?

    // MARK: - Journal Templates

    private struct JournalTemplate: Identifiable {
        let id = UUID()
        let name: String
        let color: Color
        let text: String
    }

    private let templates: [JournalTemplate] = [
        JournalTemplate(
            name: "Morning Reflection",
            color: .neonGold,
            text: "How am I feeling this morning? What am I grateful for? What's my intention for today?"
        ),
        JournalTemplate(
            name: "Evening Wind-Down",
            color: .neonPurple,
            text: "What went well today? What was challenging? What did I learn? How do I feel right now?"
        ),
        JournalTemplate(
            name: "Trigger Analysis",
            color: .neonOrange,
            text: "What triggered me? How intense was it (1-10)? What did I do? What could I do differently next time?"
        ),
        JournalTemplate(
            name: "Gratitude List",
            color: .neonGreen,
            text: "Three things I'm grateful for today:\n1.\n2.\n3.\nWhy these matter to me:"
        ),
        JournalTemplate(
            name: "Letter to Future Self",
            color: .neonMagenta,
            text: "Dear future me,\n\nI want you to remember..."
        )
    ]

    // MARK: - Date Grouping

    private enum DateSection: String, CaseIterable {
        case today = "TODAY"
        case yesterday = "YESTERDAY"
        case thisWeek = "THIS WEEK"
        case earlier = "EARLIER"
    }

    private var groupedEntries: [(section: DateSection, entries: [CDJournalEntry])] {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
        let startOfWeek = calendar.date(byAdding: .day, value: -7, to: startOfToday)!

        var groups: [DateSection: [CDJournalEntry]] = [:]
        for section in DateSection.allCases {
            groups[section] = []
        }

        for entry in entries {
            let entryDate = entry.date
            if entryDate >= startOfToday {
                groups[.today, default: []].append(entry)
            } else if entryDate >= startOfYesterday {
                groups[.yesterday, default: []].append(entry)
            } else if entryDate >= startOfWeek {
                groups[.thisWeek, default: []].append(entry)
            } else {
                groups[.earlier, default: []].append(entry)
            }
        }

        return DateSection.allCases.compactMap { section in
            let sectionEntries = groups[section] ?? []
            guard !sectionEntries.isEmpty else { return nil }
            return (section: section, entries: sectionEntries)
        }
    }

    // MARK: - Journaling Streak

    private var journalingStreak: Int {
        let calendar = Calendar.current
        let allDates = Set(entries.map { calendar.startOfDay(for: $0.date) })
        guard !allDates.isEmpty else { return 0 }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // If no entry today, start from yesterday
        if !allDates.contains(checkDate) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        while allDates.contains(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return streak
    }

    // MARK: - Mood Trend Data (last 7 entries)

    private var moodTrendEntries: [CDJournalEntry] {
        // Last 7 entries in chronological order (oldest first for chart)
        Array(entries.prefix(7)).reversed()
    }

    private func moodColor(for mood: Int16) -> Color {
        switch mood {
        case 1: return .neonOrange    // terrible/sad
        case 2: return .neonOrange    // bad/sad
        case 3: return .neonCyan      // neutral
        case 4: return .neonGreen     // good/happy
        case 5: return .neonGold      // great/excited
        default: return .neonCyan
        }
    }

    private func moodTintColor(for mood: Int16) -> Color {
        switch mood {
        case 1: return .neonOrange    // terrible (sad)
        case 2: return .neonOrange    // bad (sad)
        case 3: return .neonCyan      // neutral
        case 4: return .neonGreen     // good (happy)
        case 5: return .neonMagenta   // great (ecstatic)
        default: return .neonCyan
        }
    }

    // MARK: - Daily Prompt

    private static let generalPrompts = [
        "What am I grateful for today?",
        "What triggered me today and how did I handle it?",
        "What is one thing I am proud of this week?",
        "How do I feel right now, and why?",
        "What would I tell a friend in my situation?",
        "What is one small win I had today?",
        "What challenged me today and what did I learn?",
        "How have I grown since starting my recovery?",
        "What does my ideal tomorrow look like?",
        "What emotion am I sitting with right now?",
        "What boundaries did I set or maintain today?",
        "Who supported me today, and how can I thank them?",
        "What pattern do I notice in my behavior this week?",
        "What is one thing I can forgive myself for today?",
        "If I could talk to my future self, what would I say?"
    ]

    private var todaysPrompt: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let allPrompts = Self.generalPrompts
        return allPrompts[dayOfYear % allPrompts.count]
    }

    // MARK: - Time Formatter

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // MARK: - Streak Badge
                        if journalingStreak > 0 {
                            HStack {
                                Spacer()
                                HStack(spacing: 6) {
                                    Text("\(journalingStreak) day streak")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.neonOrange)
                                    Text("\u{1F525}")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.neonOrange.opacity(0.12))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.neonOrange.opacity(0.3), lineWidth: 1)
                                )
                                Spacer()
                            }
                        }

                        // MARK: - Mood Trend Chart
                        if moodTrendEntries.count >= 2 {
                            moodTrendChart
                        }

                        // MARK: - Today's Prompt Card
                        todaysPromptCard

                        // MARK: - Templates
                        templatesSection

                        // MARK: - Entries by Section
                        if entries.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(Color.neonPurple.opacity(0.5))
                                Text("No journal entries yet")
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                Text("Tap the + button to write your first entry.")
                                    .font(.subheadline)
                                    .foregroundColor(.subtleText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(groupedEntries, id: \.section) { group in
                                Section {
                                    ForEach(group.entries, id: \.id) { entry in
                                        Button {
                                            editingEntry = entry
                                        } label: {
                                            journalEntryCard(entry)
                                        }
                                    }
                                } header: {
                                    Text(group.section.rawValue)
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.subtleText)
                                        .tracking(1.2)
                                        .padding(.top, group.section == groupedEntries.first?.section ? 0 : 8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                }

                // MARK: - FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            editingEntry = nil
                            promptToPreFill = nil
                            showEditor = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.neonPurple.opacity(0.4), radius: 8, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Journal")
            .sheet(isPresented: $showEditor) {
                JournalEditorView(initialPrompt: promptToPreFill)
                    .environmentObject(environment)
                    .environment(\.managedObjectContext, environment.viewContext)
            }
            .sheet(item: $editingEntry) { entry in
                JournalEditorView(existingEntry: entry)
                    .environmentObject(environment)
                    .environment(\.managedObjectContext, environment.viewContext)
            }
        }
    }

    // MARK: - Mood Trend Chart

    private var moodTrendChart: some View {
        let trendEntries = moodTrendEntries

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.caption)
                    .foregroundColor(.neonBlue)
                Text("Mood Trend")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.appText)
            }

            GeometryReader { geo in
                let width = geo.size.width
                let height: CGFloat = 50
                let count = trendEntries.count
                let stepX = count > 1 ? width / CGFloat(count - 1) : width
                // Mood range: 1-5, map to 0-height (inverted: 5=top, 1=bottom)
                let minMood: CGFloat = 1
                let maxMood: CGFloat = 5

                ZStack {
                    // Connecting lines
                    if count > 1 {
                        Path { path in
                            for i in 0..<count {
                                let x = CGFloat(i) * stepX
                                let moodVal = CGFloat(trendEntries[i].mood)
                                let y = height - ((moodVal - minMood) / (maxMood - minMood)) * height
                                if i == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                    }

                    // Mood dots
                    ForEach(0..<count, id: \.self) { i in
                        let x = CGFloat(i) * stepX
                        let moodVal = CGFloat(trendEntries[i].mood)
                        let y = height - ((moodVal - minMood) / (maxMood - minMood)) * height

                        Circle()
                            .fill(moodColor(for: trendEntries[i].mood))
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
                .frame(height: height)
            }
            .frame(height: 50)
            .padding(.horizontal, 4)

            // Emoji labels for Y axis reference
            HStack {
                Text("\u{1F61E}")
                    .font(.caption2)
                Spacer()
                Text("\u{1F610}")
                    .font(.caption2)
                Spacer()
                Text("\u{1F604}")
                    .font(.caption2)
            }
            .padding(.horizontal, 4)
        }
        .neonCard(glow: .neonBlue)
    }

    // MARK: - Templates Section

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "doc.text.fill")
                    .font(.caption)
                    .foregroundColor(.neonPurple)
                Text("Templates")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.appText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(templates) { template in
                        Button {
                            promptToPreFill = template.text
                            editingEntry = nil
                            showEditor = true
                        } label: {
                            Text(template.name)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(template.color)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(template.color.opacity(0.08))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(template.color.opacity(0.4), lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Today's Prompt Card

    private var todaysPromptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.neonGold)
                Text("Today's Prompt")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.appText)
            }

            Text(todaysPrompt)
                .font(.body)
                .foregroundColor(.appText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                promptToPreFill = todaysPrompt
                editingEntry = nil
                showEditor = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.line")
                    Text("Start Writing")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .rainbowCard()
    }

    // MARK: - Entry Card (with mood tint)

    @ViewBuilder
    private func journalEntryCard(_ entry: CDJournalEntry) -> some View {
        let tint = moodTintColor(for: entry.mood)

        HStack(alignment: .top, spacing: 0) {
            // Rainbow left border
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .padding(.vertical, 4)

            HStack(alignment: .top, spacing: 12) {
                // Mood emoji
                let mood = MoodState(rawValue: Int(entry.mood)) ?? .neutral
                Text(mood.emoji)
                    .font(.system(size: 32))

                // Title + preview + timestamp
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title ?? "Untitled")
                        .font(.headline)
                        .foregroundColor(.appText)
                        .lineLimit(1)

                    Text(entry.body)
                        .font(.subheadline)
                        .foregroundColor(.subtleText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack {
                        Text(Self.timeFormatter.string(from: entry.date))
                            .font(.caption)
                            .foregroundColor(.subtleText)

                        Spacer()

                        if let habit = entry.habit {
                            Text(habit.safeDisplayName)
                                .font(.caption2.weight(.medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.neonOrange.opacity(0.12))
                                .foregroundColor(.neonOrange)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(
            ZStack {
                Color.cardBackground
                tint.opacity(0.05)
            }
        )
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(Color.neonPurple.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.neonPurple.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        JournalView()
            .environment(\.managedObjectContext, env.viewContext)
            .environmentObject(env)
    }
}
