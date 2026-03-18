import SwiftUI
import CoreData

struct JournalEditorView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES")
    ) private var habits: FetchedResults<CDHabit>

    var existingEntry: CDJournalEntry?
    var initialPrompt: String?
    var entryContext: String?
    var preSelectedHabit: CDHabit? = nil

    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var selectedMood: MoodState = .neutral
    @State private var selectedHabitID: UUID?
    @State private var selectedTags: Set<EntryTag> = []
    @State private var currentPromptIndex: Int = 0

    private var isEditing: Bool { existingEntry != nil }

    // MARK: - Entry Tags

    enum EntryTag: String, CaseIterable, Identifiable {
        // General
        case gratitude, reflection, win, struggle
        // Trigger-specific
        case frustrated, stressed, anxious, angry, lonely, bored, overwhelmed
        // Mood-specific
        case hopeful, proud, peaceful, determined, motivated
        // Recovery-specific
        case craving, lapse, milestone, insight

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .gratitude: return "Gratitude"
            case .reflection: return "Reflection"
            case .win: return "Win"
            case .struggle: return "Struggle"
            case .frustrated: return "Frustrated"
            case .stressed: return "Stressed"
            case .anxious: return "Anxious"
            case .angry: return "Angry"
            case .lonely: return "Lonely"
            case .bored: return "Bored"
            case .overwhelmed: return "Overwhelmed"
            case .hopeful: return "Hopeful"
            case .proud: return "Proud"
            case .peaceful: return "Peaceful"
            case .determined: return "Determined"
            case .motivated: return "Motivated"
            case .craving: return "Craving"
            case .lapse: return "Lapse"
            case .milestone: return "Milestone"
            case .insight: return "Insight"
            }
        }

        var color: Color {
            switch self {
            case .gratitude: return .neonGold
            case .reflection: return .neonPurple
            case .win: return .neonGreen
            case .struggle: return .neonOrange
            case .frustrated, .stressed, .anxious, .angry: return .neonOrange
            case .lonely, .bored, .overwhelmed: return .neonMagenta
            case .hopeful, .proud, .peaceful, .determined, .motivated: return .neonGreen
            case .craving: return .neonOrange
            case .lapse: return .neonMagenta
            case .milestone: return .neonGold
            case .insight: return .neonCyan
            }
        }

        var icon: String {
            switch self {
            case .gratitude: return "heart.fill"
            case .reflection: return "thought.bubble"
            case .win: return "star.fill"
            case .struggle: return "cloud.rain.fill"
            case .frustrated: return "face.dashed"
            case .stressed: return "bolt.fill"
            case .anxious: return "waveform.path.ecg"
            case .angry: return "flame.fill"
            case .lonely: return "person.fill.questionmark"
            case .bored: return "clock.fill"
            case .overwhelmed: return "tornado"
            case .hopeful: return "sun.max.fill"
            case .proud: return "hand.thumbsup.fill"
            case .peaceful: return "leaf.fill"
            case .determined: return "target"
            case .motivated: return "bolt.heart.fill"
            case .craving: return "exclamationmark.triangle.fill"
            case .lapse: return "arrow.counterclockwise"
            case .milestone: return "flag.fill"
            case .insight: return "lightbulb.fill"
            }
        }

        static func tagsForContext(_ context: String?) -> [EntryTag] {
            switch context {
            case "trigger":
                return [.craving, .stressed, .frustrated, .anxious, .angry, .lonely, .bored, .overwhelmed, .struggle]
            case "gratitude":
                return [.gratitude, .hopeful, .proud, .peaceful, .milestone, .win]
            case "morning":
                return [.determined, .motivated, .hopeful, .anxious, .reflection]
            case "evening":
                return [.gratitude, .win, .struggle, .insight, .peaceful, .proud]
            default:
                return [.reflection, .win, .struggle, .insight, .milestone, .hopeful, .proud]
            }
        }
    }

    private var contextualTags: [EntryTag] {
        EntryTag.tagsForContext(entryContext)
    }

    // MARK: - Prompts

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

    private static let programPrompts: [String: [String]] = [
        "smoking": [
            "How did I handle a craving today?",
            "What does breathing freely mean to me?",
            "What would I buy with the money I've saved?"
        ],
        "alcohol": [
            "How did I navigate a social situation sober?",
            "What does clear-headed feel like?",
            "What am I rediscovering about myself?"
        ],
        "porn": [
            "What healthier connection did I seek out today?",
            "How is my self-image changing?",
            "What triggers did I identify and avoid?"
        ],
        "phone": [
            "What did I do with my screen-free time?",
            "How did being present feel today?",
            "What moment would I have missed if I was on my phone?"
        ],
        "socialMedia": [
            "How did I feel after a break from scrolling?",
            "What real-world connection did I make today?",
            "What comparison trap did I avoid?"
        ],
        "gaming": [
            "What did I accomplish outside of games today?",
            "How did I spend my free time differently?",
            "What real-life skill am I building?"
        ],
        "sugar": [
            "How did my energy levels feel today?",
            "What healthy alternative did I enjoy?",
            "What emotional need was behind my craving?"
        ],
        "emotionalEating": [
            "What emotion was I sitting with before I felt hungry?",
            "How did I nourish myself without food?",
            "What body signal helped me make a good choice?"
        ],
        "shopping": [
            "What did I choose not to buy and how did it feel?",
            "What non-material thing brought me joy today?",
            "What is the difference between wanting and needing?"
        ],
        "gambling": [
            "What risk did I avoid today?",
            "How did I handle the urge for excitement?",
            "What does financial peace mean to me?"
        ],
    ]

    private var allPrompts: [String] {
        var prompts = Self.generalPrompts
        if let habit = habits.first,
           let programSpecific = Self.programPrompts[habit.programType] {
            prompts = programSpecific + prompts
        }
        return prompts
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Date header
                        HStack(spacing: 8) {
                            Image(systemName: entryContext == "gratitude" ? "heart.fill" : "book.fill")
                                .foregroundColor(entryContext == "gratitude" ? .neonGold : .neonBlue)
                            Text({
                                let f = DateFormatter(); f.dateStyle = .long; f.timeStyle = .short
                                return f.string(from: existingEntry?.createdAt ?? DebugDate.now)
                            }())
                                .font(Typography.callout)
                                .foregroundColor(.subtleText)
                            Spacer()
                        }

                        // MARK: - Habit Picker
                        if preSelectedHabit == nil && habits.count > 1 {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Which habit is this for?")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.subtleText)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(habits) { habit in
                                            Button {
                                                selectedHabitID = habit.id
                                            } label: {
                                                Text(habit.name)
                                                    .font(.subheadline)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(selectedHabitID == habit.id ? Color.neonBlue : Color.cardBackground)
                                                    .foregroundColor(selectedHabitID == habit.id ? .white : .appText)
                                                    .cornerRadius(10)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: - Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Title")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.subtleText)
                            TextField("Give this entry a title...", text: $title)
                                .font(.body)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: 1
                                        )
                                        .opacity(0.4)
                                )
                        }

                        // MARK: - Tags
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tags")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.subtleText)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(contextualTags) { tag in
                                        Button {
                                            if selectedTags.contains(tag) {
                                                selectedTags.remove(tag)
                                            } else {
                                                selectedTags.insert(tag)
                                            }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: tag.icon)
                                                    .font(.caption2)
                                                Text(tag.displayName)
                                                    .font(.caption.weight(.medium))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedTags.contains(tag)
                                                    ? tag.color.opacity(0.2)
                                                    : Color.clear
                                            )
                                            .foregroundColor(
                                                selectedTags.contains(tag)
                                                    ? tag.color
                                                    : .subtleText
                                            )
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(
                                                        selectedTags.contains(tag)
                                                            ? tag.color
                                                            : Color.subtleText.opacity(0.3),
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: - Body
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Entry")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.subtleText)
                            TextEditor(text: $bodyText)
                                .font(.body)
                                .frame(minHeight: 180)
                                .padding(8)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: 1
                                        )
                                        .opacity(0.4)
                                )

                            // Word count
                            let wordCount = bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? 0
                                : bodyText.split(separator: " ").count
                            Text("\(wordCount) words")
                                .font(Typography.caption)
                                .foregroundColor(.textSecondary)
                        }

                        // MARK: - Mood Picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("How are you feeling?")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.subtleText)
                            HStack(spacing: 0) {
                                ForEach(MoodState.allCases) { mood in
                                    Button {
                                        selectedMood = mood
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(mood.emoji)
                                                .font(.title)
                                            Text(mood.displayName)
                                                .font(.caption2)
                                                .foregroundColor(selectedMood == mood ? .neonPurple : .subtleText)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedMood == mood
                                                ? Color.neonPurple.opacity(0.12)
                                                : Color.clear
                                        )
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedMood == mood ? Color.neonPurple : Color.clear, lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            .padding(6)
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


                        // MARK: - Prompt Card
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Need a prompt?")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.subtleText)

                            VStack(spacing: 12) {
                                Text(allPrompts[currentPromptIndex % allPrompts.count])
                                    .font(.body)
                                    .foregroundColor(.appText)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HStack(spacing: 12) {
                                    Button {
                                        let prompt = allPrompts[currentPromptIndex % allPrompts.count]
                                        if bodyText.isEmpty {
                                            bodyText = prompt + "\n\n"
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "pencil.line")
                                                .font(.caption)
                                            Text("Use Prompt")
                                                .font(.caption.weight(.semibold))
                                        }
                                        .foregroundColor(.neonCyan)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.neonCyan.opacity(0.1))
                                        .cornerRadius(10)
                                    }

                                    Spacer()

                                    Button {
                                        currentPromptIndex = Int.random(in: 0..<allPrompts.count)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "dice.fill")
                                                .font(.caption)
                                            Text("Shuffle")
                                                .font(.caption.weight(.medium))
                                        }
                                        .foregroundColor(.subtleText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.cardBackground)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.subtleText.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .rainbowCard()
                        }

                        // MARK: - Save Button
                        Button {
                            saveEntry()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text(isEditing ? "Update Entry" : "Save Entry")
                        }
                        .buttonStyle(RainbowButtonStyle())
                        .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                        .padding(.top, 4)
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .onAppear {
                if let entry = existingEntry {
                    title = entry.title ?? ""
                    bodyText = entry.body
                    selectedMood = MoodState(rawValue: Int(entry.mood)) ?? .neutral
                    selectedHabitID = entry.habit?.id
                    // Restore tags from promptUsed field
                    if let tagString = entry.promptUsed {
                        let tagNames = tagString.components(separatedBy: ",")
                        for name in tagNames {
                            if let tag = EntryTag(rawValue: name.trimmingCharacters(in: .whitespaces)) {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                } else {
                    // Pre-select habit from parameter or first habit by default
                    if let preSelected = preSelectedHabit {
                        selectedHabitID = preSelected.id
                    } else if selectedHabitID == nil, let firstHabit = habits.first {
                        selectedHabitID = firstHabit.id
                    }
                    if let prompt = initialPrompt, !prompt.isEmpty {
                        bodyText = prompt + "\n\n"
                    }
                    // Auto-tag based on context
                    if entryContext == "gratitude" {
                        selectedTags.insert(.gratitude)
                        if title.isEmpty { title = "Gratitude Log" }
                    } else if entryContext == "craving" {
                        selectedTags.insert(.craving)
                        if title.isEmpty { title = "Craving Journal" }
                    }
                }
                // Randomize starting prompt index
                currentPromptIndex = Int.random(in: 0..<allPrompts.count)
            }
        }
    }

    // MARK: - Save

    private func saveEntry() {
        let selectedHabit = habits.first(where: { $0.id == selectedHabitID })
        let tagsString = selectedTags.map { $0.rawValue }.sorted().joined(separator: ",")

        if let entry = existingEntry {
            entry.title = title.isEmpty ? nil : title
            entry.body = bodyText
            entry.mood = Int16(selectedMood.rawValue)
            entry.habit = selectedHabit
            entry.updatedAt = Date()
            entry.promptUsed = tagsString.isEmpty ? nil : tagsString
        } else {
            guard let habit = selectedHabit ?? habits.first else { return }
            let entry = CDJournalEntry.create(
                in: viewContext,
                habit: habit,
                body: bodyText,
                title: title.isEmpty ? nil : title,
                mood: Int16(selectedMood.rawValue),
                promptUsed: tagsString.isEmpty ? nil : tagsString
            )
            _ = entry
        }
        environment.coreDataStack.save()

        // Evaluate badge unlock immediately after saving
        if let habit = selectedHabit ?? habits.first {
            environment.achievementService.evaluate(for: habit)
        }
    }
}

// MARK: - Preview

struct JournalEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        JournalEditorView()
            .environment(\.managedObjectContext, env.viewContext)
            .environmentObject(env)
    }
}
