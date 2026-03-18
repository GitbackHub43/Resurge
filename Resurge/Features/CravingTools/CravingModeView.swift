import SwiftUI
import CoreData

struct CravingModeView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.presentationMode) var presentationMode
    var preSelectedHabit: CDHabit? = nil

    // MARK: - State

    enum Step: Int, CaseIterable {
        case intensity = 0
        case triggers
        case chooseTool
        case usingTool
        case outcome
    }

    @State private var currentStep: Step = .intensity
    @State private var intensity: Double = 5
    @State private var selectedTriggers: Set<String> = []
    @State private var selectedTool: CravingToolKind?
    @State private var didResist = true
    @State private var breathScale: CGFloat = 1.0

    // Other trigger
    @State private var isOtherSelected = false
    @State private var customTriggerText = ""

    // Inline tool state
    @State private var currentQuote: Quote? = nil
    @State private var showPuzzleSheet = false
    @State private var showJournalSheet = false
    @State private var journalNotes = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.sortOrder, ascending: true)],
        predicate: NSPredicate(format: "isActive == YES")
    ) private var habits: FetchedResults<CDHabit>

    private let availableTools: [CravingToolKind] = [
        .breathing, .puzzle, .quotes, .journaling
    ]

    var body: some View {
        ZStack {
            // Calming background with breathing animation
            Color.appBackground.ignoresSafeArea()
            breathingBackground

            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.subtleText)
                    Spacer()
                    stepIndicator
                    Spacer()
                    // Invisible balancer
                    Text("Cancel").opacity(0)
                }
                .padding()

                // MARK: - Step Content
                ScrollView {
                    Spacer().frame(height: 20)
                    Group {
                        switch currentStep {
                        case .intensity:
                            intensityStep
                        case .triggers:
                            triggersStep
                        case .chooseTool:
                            chooseToolStep
                        case .usingTool:
                            usingToolStepContent
                        case .outcome:
                            outcomeStepContent
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    Spacer().frame(height: 20)
                }

                // MARK: - Persistent Bottom Button
                Button {
                    handleBottomButtonAction()
                } label: {
                    Text(bottomButtonLabel)
                }
                .buttonStyle(RainbowButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showPuzzleSheet) {
            NavigationView {
                PuzzleGameView()
            }
            .navigationViewStyle(.stack)
        }
    }

    // MARK: - Breathing Background

    private var breathingBackground: some View {
        Circle()
            .fill(Color.neonPurple.opacity(0.06))
            .frame(width: 300, height: 300)
            .scaleEffect(breathScale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
                ) {
                    breathScale = 1.3
                }
            }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 6) {
            ForEach(Step.allCases, id: \.rawValue) { step in
                Circle()
                    .fill(step.rawValue <= currentStep.rawValue ? Color.neonCyan : Color.subtleText.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }

    // MARK: - Step 1: Intensity

    private var intensityStep: some View {
        VStack(spacing: 24) {
            Text("How intense is this craving?")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            Text("\(Int(intensity))")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(intensityColor)

            Slider(value: $intensity, in: 1...10, step: 1)
                .accentColor(intensityColor)
                .padding(.horizontal, 32)

            HStack {
                Text("Mild")
                    .font(.caption)
                    .foregroundColor(.subtleText)
                Spacer()
                Text("Extreme")
                    .font(.caption)
                    .foregroundColor(.subtleText)
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }

    private var intensityColor: Color {
        let val = intensity / 10.0
        if val <= 0.3 { return .green }
        if val <= 0.6 { return .yellow }
        if val <= 0.8 { return .orange }
        return .red
    }

    // MARK: - Step 2: Triggers

    private var triggersStep: some View {
        VStack(spacing: 20) {
            Text("What triggered this craving?")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            let triggerColumns = [GridItem(.adaptive(minimum: 100), spacing: 10)]

            LazyVGrid(columns: triggerColumns, spacing: 10) {
                ForEach(TriggerType.allStandard) { trigger in
                    let isSelected = selectedTriggers.contains(trigger.id)
                    Button {
                        if isSelected {
                            selectedTriggers.remove(trigger.id)
                        } else {
                            selectedTriggers.insert(trigger.id)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: trigger.iconName)
                                .font(.title3)
                            Text(trigger.displayName)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 70)
                        .background(isSelected ? Color.neonMagenta.opacity(0.15) : Color.cardBackground)
                        .foregroundColor(isSelected ? Color.neonMagenta : .appText)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.neonMagenta : Color.clear, lineWidth: 2)
                        )
                    }
                }

                // "Other" button
                Button {
                    isOtherSelected.toggle()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                        Text("Other")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .background(isOtherSelected ? Color.neonMagenta.opacity(0.15) : Color.cardBackground)
                    .foregroundColor(isOtherSelected ? Color.neonMagenta : .appText)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isOtherSelected ? Color.neonMagenta : Color.clear, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal)

            // Custom trigger text field
            if isOtherSelected {
                TextField("Describe your trigger...", text: $customTriggerText)
                    .font(.body)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neonMagenta.opacity(0.5), lineWidth: 1)
                    )
                    .foregroundColor(.appText)
                    .padding(.horizontal)
            }
        }
        .padding()
    }

    // MARK: - Step 3: Choose Tool

    private var chooseToolStep: some View {
        VStack(spacing: 20) {
            Text("Pick a coping tool")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            ForEach(availableTools) { tool in
                let isSelected = selectedTool?.id == tool.id
                Button {
                    selectedTool = tool
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: tool.iconName)
                            .font(.title2)
                            .foregroundColor(isSelected ? .white : .neonCyan)
                            .frame(width: 44, height: 44)
                            .background(isSelected ? Color.neonCyan : Color.neonCyan.opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(tool.displayName)
                                .font(.headline)
                                .foregroundColor(.appText)
                            Text(tool.description)
                                .font(.caption)
                                .foregroundColor(.subtleText)
                                .lineLimit(2)
                        }
                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.neonCyan)
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.neonCyan : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
                }
            }
        }
        .padding()
    }

    // MARK: - Step 4: Using Tool (content only, button is persistent)

    private var usingToolStepContent: some View {
        VStack(spacing: 24) {
            Text(selectedTool?.displayName ?? "Coping Tool")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            // Show tool-specific inline content
            Group {
                switch selectedTool {
                case .breathing:
                    inlineBreathingView
                case .quotes:
                    inlineQuoteView
                case .puzzle:
                    inlinePuzzleView
                case .journaling:
                    inlineJournalingView
                default:
                    Text("Take your time. The craving will pass.")
                        .font(.subheadline)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
            }

            Text("Take your time. The craving will pass.")
                .font(.subheadline)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Inline Breathing View

    @State private var inlineBreathExpanded = false
    @State private var inlineBreathText = "Tap Start to begin"
    @State private var inlineBreathActive = false
    @State private var inlineBreathCycle = 0

    private var inlineBreathingView: some View {
        VStack(spacing: 16) {
            Text(inlineBreathText)
                .font(.title3.weight(.bold))
                .foregroundColor(.neonCyan)
                .animation(.easeInOut(duration: 0.3), value: inlineBreathText)

            ZStack {
                Circle()
                    .fill(Color.neonCyan.opacity(0.05))
                    .frame(width: 200, height: 200)

                Circle()
                    .fill(Color.neonCyan.opacity(0.15))
                    .frame(width: inlineBreathExpanded ? 160 : 60, height: inlineBreathExpanded ? 160 : 60)
                    .shadow(color: Color.neonCyan.opacity(0.5), radius: inlineBreathExpanded ? 20 : 8)

                Circle()
                    .stroke(Color.neonCyan.opacity(0.3), lineWidth: 2)
                    .frame(width: inlineBreathExpanded ? 180 : 80, height: inlineBreathExpanded ? 180 : 80)

                if inlineBreathActive {
                    Text("\(inlineBreathCycle)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color.neonCyan.opacity(0.3))
                }
            }
            .animation(.easeInOut(duration: 4), value: inlineBreathExpanded)

            Text("Cycle \(inlineBreathCycle) of 5")
                .font(.caption)
                .foregroundColor(.subtleText)

            if !inlineBreathActive {
                Button {
                    startInlineBreathing()
                } label: {
                    Text("Start Breathing")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.neonCyan)
                        .cornerRadius(20)
                }
            } else {
                Button {
                    inlineBreathActive = false
                    inlineBreathText = "Tap Start to begin"
                    inlineBreathExpanded = false
                } label: {
                    Text("Stop")
                        .font(.headline)
                        .foregroundColor(.neonOrange)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.neonOrange.opacity(0.15))
                        .cornerRadius(20)
                }
            }
        }
    }

    private func startInlineBreathing() {
        inlineBreathActive = true
        inlineBreathCycle = 0
        runInlineBreathCycle()
    }

    private func runInlineBreathCycle() {
        guard inlineBreathActive else { return }
        inlineBreathCycle += 1

        if inlineBreathCycle > 5 {
            inlineBreathActive = false
            inlineBreathText = "Well done!"
            inlineBreathExpanded = false
            return
        }

        // 4-7-8 pattern
        inlineBreathText = "Breathe in..."
        inlineBreathExpanded = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            guard inlineBreathActive else { return }
            inlineBreathText = "Hold..."

            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                guard inlineBreathActive else { return }
                inlineBreathText = "Breathe out..."
                inlineBreathExpanded = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    guard inlineBreathActive else { return }
                    runInlineBreathCycle()
                }
            }
        }
    }

    // MARK: - Inline Quote View

    private var inlineQuoteView: some View {
        VStack(spacing: 20) {
            let quote = currentQuote ?? QuoteBank.randomQuote()

            VStack(spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundColor(.neonCyan.opacity(0.5))

                Text(quote.text)
                    .font(.body.italic())
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if !quote.author.isEmpty {
                    Text("- \(quote.author)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.subtleText)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
            )

            Button {
                currentQuote = QuoteBank.randomQuote()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("New Quote")
                }
                .font(.headline)
                .foregroundColor(.neonCyan)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.neonCyan.opacity(0.12))
                .cornerRadius(20)
            }
        }
        .onAppear {
            if currentQuote == nil {
                currentQuote = QuoteBank.randomQuote()
            }
        }
    }

    // MARK: - Inline Puzzle View

    private var inlinePuzzleView: some View {
        VStack(spacing: 16) {
            Image(systemName: "puzzlepiece.fill")
                .font(.system(size: 48))
                .foregroundColor(.neonCyan)

            Text("A quick puzzle to redirect your focus and let the urge pass.")
                .font(.subheadline)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)

            Button {
                showPuzzleSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                    Text("Open Puzzle")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.neonCyan)
                .cornerRadius(20)
            }
        }
    }

    // MARK: - Inline Journaling View

    private var inlineJournalingView: some View {
        VStack(spacing: 12) {
            Text("Write down what you're feeling")
                .font(Typography.headline).foregroundColor(.neonBlue)

            TextEditor(text: $journalNotes)
                .font(Typography.body).foregroundColor(.textPrimary)
                .frame(minHeight: 100)
                .padding(4)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius).stroke(Color.cardBorder, lineWidth: 1))
        }
        .neonCard(glow: .neonBlue)
    }

    // MARK: - Step 5: Outcome (content only, button is persistent)

    private var outcomeStepContent: some View {
        VStack(spacing: 24) {
            Text("Did you resist the craving?")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            HStack(spacing: 20) {
                outcomeButton(title: "Yes!", icon: "hand.thumbsup.fill", value: true)
                outcomeButton(title: "No", icon: "hand.thumbsdown.fill", value: false)
            }
            .padding(.horizontal)

            // Comfort message when they gave in
            if !didResist {
                VStack(spacing: 8) {
                    Text("That takes courage to admit.")
                        .font(Typography.headline)
                        .foregroundColor(.neonCyan)

                    Text("Recovery isn't a straight line. Your timer will reset, but you haven't lost the progress you've made inside. Every craving you've fought before made you stronger. This is just one moment — not your whole story.")
                        .font(Typography.callout)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.neonCyan.opacity(0.06))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neonCyan.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                .transition(.opacity)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func outcomeButton(title: String, icon: String, value: Bool) -> some View {
        Button {
            didResist = value
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(didResist == value ? Color.neonGreen.opacity(0.15) : Color.cardBackground)
            .foregroundColor(didResist == value ? Color.neonGreen : .appText)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(didResist == value ? Color.neonGreen : Color.clear, lineWidth: 2)
            )
        }
    }

    // MARK: - Persistent Bottom Button

    private var bottomButtonLabel: String {
        switch currentStep {
        case .intensity:    return "Next"
        case .triggers:     return "Next"
        case .chooseTool:   return "Start Tool"
        case .usingTool:    return "I'm Done"
        case .outcome:      return "Save & Close"
        }
    }

    private func handleBottomButtonAction() {
        switch currentStep {
        case .intensity, .triggers, .chooseTool:
            advanceStep()
        case .usingTool:
            inlineBreathActive = false
            withAnimation { currentStep = .outcome }
        case .outcome:
            saveCravingEntry()
            presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Actions

    private func advanceStep() {
        withAnimation {
            switch currentStep {
            case .intensity:
                currentStep = .triggers
            case .triggers:
                currentStep = .chooseTool
            case .chooseTool:
                currentStep = .usingTool
            case .usingTool:
                currentStep = .outcome
            case .outcome:
                break
            }
        }
    }

    private var allTriggerStrings: String {
        var triggers = Array(selectedTriggers)
        let trimmed = customTriggerText.trimmingCharacters(in: .whitespacesAndNewlines)
        if isOtherSelected && !trimmed.isEmpty {
            triggers.append(trimmed)
        }
        return triggers.joined(separator: ",")
    }

    private func saveCravingEntry() {
        guard let habit = preSelectedHabit ?? habits.first else { return }
        let context = environment.viewContext
        CDCravingEntry.create(
            in: context,
            habit: habit,
            intensity: Int16(intensity),
            triggerCategory: allTriggerStrings,
            triggerNote: journalNotes.isEmpty ? nil : journalNotes,
            copingToolUsed: selectedTool?.id,
            didResist: didResist,
            durationSeconds: Int32(0)
        )

        // Gave in = lapse — reset recovery timer
        if !didResist {
            habit.resetOnLapse()
        }

        // Also save journal notes as a separate craving journal entry
        if !journalNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let journalEntry = CDJournalEntry.create(
                in: context,
                habit: habit,
                body: journalNotes,
                title: "Craving Journal",
                mood: Int16(didResist ? 3 : 1),
                promptUsed: "craving"
            )
            _ = journalEntry
        }

        environment.coreDataStack.save()

        // Evaluate badges immediately after craving protocol
        environment.achievementService.evaluate(for: habit)

        // Surges only earned from daily loop (15/day) — no craving protocol award

        // Trigger Neon Rain celebration when craving is resisted
        if didResist {
            CelebrationManager.shared.trigger(.neonRain)
        }
    }
}

// MARK: - Preview

struct CravingModeView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        CravingModeView()
            .environment(\.managedObjectContext, env.viewContext)
            .environmentObject(env)
    }
}
