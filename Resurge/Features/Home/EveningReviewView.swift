import SwiftUI
import CoreData

struct EveningReviewView: View {
    @ObservedObject var habit: CDHabit
    var initialEntry: CDDailyLogEntry? = nil
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var overallMood: Int = 3  // 1-5
    @State private var todayWin = ""
    @State private var didLapse = false
    @State private var lapseNote = ""
    @State private var tomorrowPlan = ""
    @State private var gratitude = ""
    @State private var showCompletion = false
    @State private var eveningReflection = ""
    @State private var selectedEveningTags: Set<String> = []
    @State private var existingEntry: CDDailyLogEntry?
    @State private var hasLoadedData = false
    @State private var isUpdate = false

    private let moodEmojis = [
        (emoji: "\u{1F61E}", label: "Tough"),
        (emoji: "\u{1F615}", label: "Hard"),
        (emoji: "\u{1F610}", label: "Okay"),
        (emoji: "\u{1F642}", label: "Good"),
        (emoji: "\u{1F60A}", label: "Great")
    ]

    private let eveningTags: [(name: String, icon: String, color: Color)] = [
        ("Proud", "hand.thumbsup.fill", .neonGreen),
        ("Grateful", "heart.fill", .neonGold),
        ("Peaceful", "leaf.fill", .neonCyan),
        ("Relieved", "sun.max.fill", .neonGold),
        ("Exhausted", "zzz", .neonPurple),
        ("Struggled", "cloud.rain.fill", .neonOrange),
        ("Tempted", "exclamationmark.triangle.fill", .neonOrange),
        ("Accomplished", "star.fill", .neonGold),
        ("Lonely", "person.fill.questionmark", .neonMagenta),
        ("Strong", "bolt.fill", .neonGreen)
    ]

    private var todayString: String {
        DebugDate.todayString
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: existingEntry?.createdAt ?? initialEntry?.createdAt ?? DebugDate.now)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if showCompletion {
                completionOverlay
            } else {
                ScrollView {
                    VStack(spacing: AppStyle.largeSpacing) {
                        headerSection
                        moodCheckSection
                        winSection
                        eveningTagsSection
                        lapseCheckSection
                        reflectionSection
                        gratitudeSection
                        tomorrowSection
                        saveButton
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            // Reset ALL state — SwiftUI caches NavigationLink destinations
            showCompletion = false
            isUpdate = false
            existingEntry = nil
            loadExistingEntry()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Evening Review/Reflection")
                    .font(Typography.largeTitle)
                    .rainbowText()
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.textSecondary)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.neonPurple)
                Text(formattedDate)
                    .font(Typography.callout)
                    .foregroundColor(.textSecondary)
                Spacer()
            }

            HStack {
                Text(habit.safeDisplayName)
                    .font(Typography.headline)
                    .foregroundColor(.neonCyan)
                Spacer()
            }

            Text("Today is done. Whatever happened, you showed up.")
                .font(Typography.callout)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
        .padding(.top, 20)
    }

    // MARK: - Mood Check

    private var moodCheckSection: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("How was today overall?")
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { index in
                    let level = index + 1
                    let item = moodEmojis[index]
                    Button {
                        overallMood = level
                    } label: {
                        VStack(spacing: 4) {
                            Text(item.emoji)
                                .font(.title2)
                            Text(item.label)
                                .font(Typography.caption)
                                .foregroundColor(overallMood == level ? .textPrimary : .textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            overallMood == level
                                ? moodColor(for: level).opacity(0.15)
                                : Color.clear
                        )
                        .cornerRadius(AppStyle.smallCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                .stroke(
                                    overallMood == level ? moodColor(for: level).opacity(0.5) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
        }
        .neonCard(glow: moodColor(for: overallMood))
    }

    private func moodColor(for level: Int) -> Color {
        switch level {
        case 1: return .neonMagenta
        case 2: return .neonOrange
        case 3: return .neonGold
        case 4: return .neonCyan
        case 5: return .neonGreen
        default: return .neonCyan
        }
    }

    // MARK: - Win of the Day

    private var winSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's one thing you're proud of today?")
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            TextField("I made it through a craving", text: $todayWin)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .padding(AppStyle.cardPadding)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
        .neonCard(glow: .neonGold)
    }

    // MARK: - Lapse Check

    private var lapseCheckSection: some View {
        VStack(spacing: AppStyle.spacing) {
            HStack {
                Text("Did you lapse today?")
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                Toggle("", isOn: $didLapse)
                    .labelsHidden()
                    .tint(.neonOrange)
            }

            if didLapse {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What happened?")
                        .font(Typography.caption)
                        .foregroundColor(.neonOrange)

                    ZStack(alignment: .topLeading) {
                        if lapseNote.isEmpty {
                            Text("Describe what led to it...")
                                .font(Typography.body)
                                .foregroundColor(.textSecondary.opacity(0.5))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                        TextEditor(text: $lapseNote)
                            .font(Typography.body)
                            .foregroundColor(.textPrimary)
                            .frame(minHeight: 80)
                            .padding(4)
                            .background(Color.cardBackground)
                            .cornerRadius(AppStyle.smallCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                    .stroke(Color.neonOrange.opacity(0.4), lineWidth: 1)
                            )
                    }

                    Text("This is not failure. This is data.")
                        .font(Typography.callout)
                        .foregroundColor(.neonCyan)
                        .font(Font.body.italic())
                }
            }
        }
        .neonCard(glow: didLapse ? .neonOrange : .neonCyan)
    }

    // MARK: - Evening Tags

    private var eveningTagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today I felt:")
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(eveningTags, id: \.name) { tag in
                        let selected = selectedEveningTags.contains(tag.name)
                        Button {
                            if selected { selectedEveningTags.remove(tag.name) }
                            else { selectedEveningTags.insert(tag.name) }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: tag.icon)
                                    .font(.system(size: 10))
                                Text(tag.name)
                                    .font(Typography.caption)
                            }
                            .foregroundColor(selected ? .white : .subtleText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selected ? tag.color.opacity(0.7) : Color.cardBackground)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selected ? tag.color : Color.cardBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .neonCard(glow: .neonBlue)
    }

    // MARK: - Reflection

    private var programType: ProgramType {
        ProgramType(rawValue: habit.programType) ?? .smoking
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(programType.reflectionMessage)
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            TextField("One insight or lesson from today", text: $eveningReflection)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .padding(AppStyle.cardPadding)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
        .neonCard(glow: .neonPurple)
    }

    // MARK: - Gratitude

    private var gratitudeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("One thing you're grateful for:")
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            TextField("Something that made today better", text: $gratitude)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .padding(AppStyle.cardPadding)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
        .neonCard(glow: .neonPurple)
    }

    // MARK: - Tomorrow's Plan

    private var tomorrowSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("One thing to focus on tomorrow:")
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            TextField("Avoid a trigger, use breathing before...", text: $tomorrowPlan)
                .font(Typography.body)
                .foregroundColor(.textPrimary)
                .padding(AppStyle.cardPadding)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        }
        .neonCard(glow: .neonBlue)
    }

    // MARK: - Save Button

    private var canSaveEvening: Bool {
        !todayWin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedEveningTags.isEmpty &&
        !eveningReflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !gratitude.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !tomorrowPlan.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (!didLapse || !lapseNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private var saveButton: some View {
        Button {
            saveEveningReview()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text(existingEntry != nil ? "Update Evening Review" : "Save Evening Review")
            }
        }
        .buttonStyle(RainbowButtonStyle())
        .disabled(!canSaveEvening)
        .opacity(canSaveEvening ? 1.0 : 0.4)
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        VStack(spacing: 20) {
            Spacer()

            if didLapse {
                Image(systemName: "heart.fill")
                    .font(.system(size: 72))
                    .foregroundColor(.neonCyan)
                    .shadow(color: .neonCyan.opacity(0.5), radius: 20)

                Text("You're not starting over.")
                    .font(Typography.title)
                    .foregroundColor(.neonCyan)

                VStack(spacing: 8) {
                    Text("You're starting from experience. Your timer has reset, but your growth hasn't. Every lesson you've learned is still yours.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)

                    Text("Tomorrow is a fresh start. You've got this.")
                        .font(Font.callout.italic())
                        .foregroundColor(.neonCyan.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
            } else {
                Image(systemName: isUpdate ? "checkmark.circle.fill" : "moon.stars.fill")
                    .font(.system(size: 72))
                    .foregroundColor(isUpdate ? .neonGreen : .neonPurple)

                Text(isUpdate ? "Updated!" : "Rest well tonight")
                    .font(Typography.title)
                    .foregroundColor(.textPrimary)

                Text("Tomorrow is a new day.")
                    .font(Typography.body)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
        // No auto-dismiss here — saveEveningReview() handles the dismiss timing
    }

    // MARK: - Load Existing Entry

    private func loadExistingEntry() {
        if let entry = initialEntry {
            populateFromEntry(entry)
            return
        }

        let today = DebugDate.startOfToday
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "date == %@", today as NSDate),
            NSPredicate(format: "entryType == %@", "evening")
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDDailyLogEntry.createdAt, ascending: false)]
        request.fetchLimit = 1

        if let entry = try? viewContext.fetch(request).first {
            populateFromEntry(entry)
        }
    }

    private func populateFromEntry(_ entry: CDDailyLogEntry) {
        existingEntry = entry
        isUpdate = true
        overallMood = Int(entry.mood)
        if overallMood < 1 || overallMood > 5 { overallMood = 3 }
        todayWin = entry.wins ?? ""
        didLapse = entry.lapsedToday
        lapseNote = entry.lapseNotes ?? ""
        tomorrowPlan = entry.planForTomorrow ?? ""
        eveningReflection = entry.reflectionText ?? ""
        gratitude = entry.gratitudeText ?? ""
        if let tagsString = entry.tags, !tagsString.isEmpty {
            selectedEveningTags = Set(tagsString.components(separatedBy: ","))
        }
    }

    // MARK: - Save Logic

    private func saveEveningReview() {
        let entry: CDDailyLogEntry
        if let existing = existingEntry {
            entry = existing
        } else {
            entry = CDDailyLogEntry(context: viewContext)
            entry.id = UUID()
            entry.date = DebugDate.startOfToday
            entry.createdAt = Date()
            entry.habit = habit
        }

        entry.entryType = "evening"
        entry.mood = Int16(overallMood)
        entry.didReflect = true
        entry.reflectionText = eveningReflection.isEmpty ? nil : eveningReflection
        entry.wins = todayWin.isEmpty ? nil : todayWin
        entry.lapsedToday = didLapse
        entry.lapseNotes = didLapse ? (lapseNote.isEmpty ? nil : lapseNote) : nil
        entry.planForTomorrow = tomorrowPlan.isEmpty ? nil : tomorrowPlan
        entry.gratitudeText = gratitude.isEmpty ? nil : gratitude
        entry.tags = selectedEveningTags.isEmpty ? nil : selectedEveningTags.sorted().joined(separator: ",")

        // Lapse resets the recovery timer
        if didLapse {
            habit.resetOnLapse()
        }

        do {
            try viewContext.save()
        } catch {
            print("EveningReviewView: Failed to save entry \u{2014} \(error.localizedDescription)")
        }

        // Surges awarded only when all 3 daily loops complete (handled in HomeView)

        UserDefaults.standard.set(todayString, forKey: "lastEveningReviewDate_\(habit.id.uuidString)")
        existingEntry = entry
        isUpdate = true

        // Evaluate badges immediately
        environment.achievementService.evaluate(for: habit)

        // Check if all 3 daily loop tasks are now done
        checkDailyLoopCompletion()

        // Always show completion and dismiss
        withAnimation(.easeInOut(duration: 0.3)) {
            showCompletion = true
        }
        let delay: Double = didLapse ? 5.0 : 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func checkDailyLoopCompletion() {
        let today = DebugDate.startOfToday as NSDate
        let types = ["morning", "afternoon", "evening"]
        var completedCount = 0
        for entryType in types {
            let req = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "habit == %@", habit),
                NSPredicate(format: "date == %@", today),
                NSPredicate(format: "entryType == %@", entryType)
            ])
            if ((try? viewContext.count(for: req)) ?? 0) > 0 { completedCount += 1 }
        }
        if completedCount >= 3 {
            CelebrationManager.shared.trigger(.rainbowBurst)
        }
    }
}

// MARK: - Preview

struct EveningReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit.create(
            in: context,
            name: "Quit Smoking",
            programType: ProgramType.smoking.rawValue
        )
        EveningReviewView(habit: habit)
            .environment(\.managedObjectContext, context)
            .preferredColorScheme(.dark)
    }
}
