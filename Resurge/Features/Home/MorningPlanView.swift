import SwiftUI
import CoreData

struct MorningPlanView: View {
    @ObservedObject var habit: CDHabit
    var initialEntry: CDDailyLogEntry? = nil
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var intention = ""
    @State private var riskLevel: Int = 3  // 1-5 scale
    @State private var plannedCopingTool = ""
    @State private var hasPledged = false
    @State private var showCompletion = false
    @State private var morningReflection = ""
    @State private var selectedMorningTags: Set<String> = []
    @State private var showValidation = false
    @State private var existingEntry: CDDailyLogEntry?
    @State private var hasLoadedData = false
    @State private var showSavedConfirmation = false
    @State private var isUpdate = false
    @AppStorage("lastMorningPlanDate") private var lastMorningPlanDateString = ""

    private let copingTools = [
        "Breathe", "Call someone", "Go for a walk",
        "Journal", "Use grounding", "Leave the situation"
    ]

    private let riskEmojis = [
        (emoji: "\u{1F60C}", label: "Low"),
        (emoji: "\u{1F642}", label: "Mild"),
        (emoji: "\u{1F614}", label: "Moderate"),
        (emoji: "\u{1F627}", label: "High"),
        (emoji: "\u{1F630}", label: "Very High")
    ]

    private let morningTags: [(name: String, icon: String, color: Color)] = [
        ("Determined", "target", .neonGreen),
        ("Motivated", "bolt.heart.fill", .neonGreen),
        ("Hopeful", "sun.max.fill", .neonGold),
        ("Anxious", "waveform.path.ecg", .neonOrange),
        ("Nervous", "exclamationmark.triangle.fill", .neonOrange),
        ("Grateful", "heart.fill", .neonGold),
        ("Rested", "moon.stars.fill", .neonCyan),
        ("Tired", "zzz", .neonPurple),
        ("Focused", "eye.fill", .neonCyan),
        ("Scattered", "wind", .neonMagenta)
    ]

    private var programType: ProgramType {
        ProgramType(rawValue: habit.programType) ?? .smoking
    }

    private var isPledgedToday: Bool {
        let key = "lastPledgeDate_\(habit.id.uuidString)"
        return UserDefaults.standard.string(forKey: key) == todayString
    }

    private var todayString: String {
        DebugDate.todayString
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let date = existingEntry?.createdAt ?? initialEntry?.createdAt ?? DebugDate.now
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {
                    headerSection
                    pledgeSection
                    morningReflectionSection
                    morningTagsSection
                    riskCheckSection
                    intentionSection
                    saveButton
                }
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isUpdate = false
            existingEntry = nil
            loadExistingEntry()
        }
        .fullScreenCover(isPresented: $showCompletion) {
            completionOverlay
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Morning Plan/Review")
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
                Image(systemName: "sunrise.fill")
                    .foregroundColor(.neonGold)
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
        }
        .padding(.top, 20)
    }

    // MARK: - Daily Pledge

    private var pledgeSection: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("Daily Pledge")
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(programType.pledgeMessage)
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isPledgedToday || hasPledged {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.neonGreen)
                    Text("Pledged")
                        .font(Typography.headline)
                        .foregroundColor(.neonGreen)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.neonGreen.opacity(0.1))
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.neonGreen.opacity(0.35), lineWidth: 1)
                )
            } else {
                Button {
                    hasPledged = true
                    UserDefaults.standard.set(todayString, forKey: "lastPledgeDate_\(habit.id.uuidString)")
                    UserDefaults.standard.set(todayString, forKey: "lastPledgeDate")
                } label: {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("Take Pledge")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(color: .neonPurple))
            }
        }
        .neonCard(glow: .neonPurple)
    }

    // MARK: - Risk Check

    private var riskCheckSection: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("How risky does today feel?")
                .font(Typography.title)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { index in
                    let level = index + 1
                    let item = riskEmojis[index]
                    Button {
                        riskLevel = level
                    } label: {
                        VStack(spacing: 4) {
                            Text(item.emoji)
                                .font(.title2)
                            Text(item.label)
                                .font(Typography.caption)
                                .foregroundColor(riskLevel == level ? .textPrimary : .textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            riskLevel == level
                                ? riskColor(for: level).opacity(0.15)
                                : Color.clear
                        )
                        .cornerRadius(AppStyle.smallCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                .stroke(
                                    riskLevel == level ? riskColor(for: level).opacity(0.5) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
        }
        .neonCard(glow: riskColor(for: riskLevel))
    }

    private func riskColor(for level: Int) -> Color {
        switch level {
        case 1: return .neonGreen
        case 2: return .neonCyan
        case 3: return .neonGold
        case 4: return .neonOrange
        case 5: return .neonMagenta
        default: return .neonCyan
        }
    }

    // MARK: - Intention

    private var intentionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My intention for today:")
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            ZStack(alignment: .topLeading) {
                if intention.isEmpty {
                    Text(programType.goalMessage)
                        .font(Typography.body)
                        .foregroundColor(.textSecondary.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                TextEditor(text: $intention)
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .frame(minHeight: 70)
                    .padding(4)
                    .background(Color.cardBackground)
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(showValidation && intention.trimmingCharacters(in: .whitespaces).isEmpty ? Color.red : Color.cardBorder, lineWidth: showValidation && intention.trimmingCharacters(in: .whitespaces).isEmpty ? 2 : 1)
                    )
            }
        }
        .neonCard(glow: .neonCyan)
    }

    // MARK: - Morning Tags

    private var morningTagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How I'm feeling:")
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(morningTags, id: \.name) { tag in
                        let selected = selectedMorningTags.contains(tag.name)
                        Button {
                            if selected { selectedMorningTags.remove(tag.name) }
                            else { selectedMorningTags.insert(tag.name) }
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

    // MARK: - Morning Reflection

    private var morningReflectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How am I feeling this morning?")
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            ZStack(alignment: .topLeading) {
                if morningReflection.isEmpty {
                    Text("What's on my mind? Any worries or expectations for today?")
                        .font(Typography.body)
                        .foregroundColor(.textSecondary.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                TextEditor(text: $morningReflection)
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)
                    .frame(minHeight: 60)
                    .padding(4)
                    .background(Color.cardBackground)
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
            }
        }
        .neonCard(glow: .neonPurple)
    }

    // MARK: - Save Button

    private var canSaveMorning: Bool {
        (hasPledged || isPledgedToday) &&
        !intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedMorningTags.isEmpty &&
        !morningReflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var saveButton: some View {
        Button {
            saveMorningPlan()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text(existingEntry != nil ? "Update Plan/Review" : "Save Plan/Review")
            }
        }
        .buttonStyle(RainbowButtonStyle())
        .disabled(!canSaveMorning)
        .opacity(canSaveMorning ? 1.0 : 0.4)
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.neonGreen)

            Text(isUpdate ? "Updated!" : "You're ready for today")
                .font(Typography.title)
                .foregroundColor(.textPrimary)

            Text("Go make today count. You've got this.")
                .font(Typography.body)
                .foregroundColor(.textSecondary)

            Spacer()

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Continue")
                    .font(Typography.headline)
                    .foregroundColor(.neonCyan)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan.opacity(0.12))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.neonCyan.opacity(0.3), lineWidth: 1))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    // MARK: - Load Existing Entry

    private func loadExistingEntry() {
        // If an initialEntry was passed (from activity log), use it directly
        if let entry = initialEntry {
            populateFromEntry(entry)
            return
        }

        // Otherwise, fetch today's entry
        let today = DebugDate.startOfToday
        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "habit == %@", habit),
            NSPredicate(format: "date == %@", today as NSDate),
            NSPredicate(format: "entryType == %@", "morning")
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
        hasPledged = entry.didPledge
        intention = entry.pledgeText ?? ""
        morningReflection = entry.reflectionText ?? ""
        riskLevel = Int(entry.stress)
        if riskLevel < 1 || riskLevel > 5 { riskLevel = 3 }
        if let tagsString = entry.tags, !tagsString.isEmpty {
            selectedMorningTags = Set(tagsString.components(separatedBy: ","))
        }
    }

    // MARK: - Save Logic

    private func saveMorningPlan() {
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

        entry.entryType = "morning"
        entry.didPledge = hasPledged || isPledgedToday
        entry.pledgeText = intention.isEmpty ? nil : intention
        entry.reflectionText = morningReflection.isEmpty ? nil : morningReflection
        entry.stress = Int16(riskLevel)
        entry.tags = selectedMorningTags.isEmpty ? nil : selectedMorningTags.sorted().joined(separator: ",")

        do {
            try viewContext.save()
        } catch {
            print("MorningPlanView: Failed to save entry — \(error.localizedDescription)")
        }

        // Surges awarded only when all 3 daily loops complete (handled in HomeView)

        lastMorningPlanDateString = todayString
        existingEntry = entry
        isUpdate = true

        // Evaluate badges immediately
        environment.achievementService.evaluate(for: habit)

        // Check if all 3 daily loop tasks are now done
        checkDailyLoopCompletion()

        // Delay showing overlay so Core Data save notifications settle first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCompletion = true
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

struct MorningPlanView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.preview.viewContext
        let habit = CDHabit.create(
            in: context,
            name: "Quit Smoking",
            programType: ProgramType.smoking.rawValue
        )
        MorningPlanView(habit: habit)
            .environment(\.managedObjectContext, context)
            .preferredColorScheme(.dark)
    }
}
