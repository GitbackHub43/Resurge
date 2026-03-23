import SwiftUI
import CoreData

struct CravingModeView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.presentationMode) var presentationMode
    var preSelectedHabit: CDHabit? = nil

    // MARK: - State

    enum Step: Int, CaseIterable {
        case reassurance = 0
        case intensity
        case triggers
        case chooseTool
        case outcome
    }

    @State private var currentStep: Step = .reassurance
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
                        case .reassurance:
                            reassuranceStep
                        case .intensity:
                            intensityStep
                        case .triggers:
                            triggersStep
                        case .chooseTool:
                            chooseToolStep
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
                .disabled(!canProceed)
                .opacity(canProceed ? 1.0 : 0.4)
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

    // MARK: - Step 0: Reassurance

    private var programColor: Color {
        Color(hex: currentProgramType.colorHex)
    }

    private var reassuranceStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "hand.raised.fill")
                .font(.system(size: 60))
                .foregroundColor(programColor)
                .shadow(color: programColor.opacity(0.5), radius: 16)

            Text("You're Going to Be Okay")
                .font(.title.weight(.bold))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            Text(currentProgramType.goalMessage)
                .font(.title3)
                .foregroundColor(programColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                Text(ProgramType.dailyTip(for: currentProgramType, dayOfYear: Calendar.current.ordinality(of: .day, in: .year, for: DebugDate.now) ?? 0))
                    .font(Typography.callout)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(programColor.opacity(0.06))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(programColor.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)

            Text("This craving will pass. They always do.")
                .font(Typography.callout.italic())
                .foregroundColor(.subtleText.opacity(0.7))

            Spacer()
        }
        .padding()
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

    private var currentProgramType: ProgramType {
        guard let habit = preSelectedHabit ?? habits.first,
              let pt = ProgramType(rawValue: habit.programType) else { return .smoking }
        return pt
    }

    private var triggersStep: some View {
        VStack(spacing: 20) {
            Text("What triggered this craving?")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            let triggerColumns = [GridItem(.adaptive(minimum: 100), spacing: 10)]

            LazyVGrid(columns: triggerColumns, spacing: 10) {
                ForEach(currentProgramType.triggers, id: \.self) { trigger in
                    let isSelected = selectedTriggers.contains(trigger)
                    Button {
                        if isSelected {
                            selectedTriggers.remove(trigger)
                        } else {
                            selectedTriggers.insert(trigger)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: ProgramType.iconForTrigger(trigger))
                                .font(.title3)
                            Text(trigger)
                                .font(.caption)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
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

    @State private var activeToolKind: CravingToolKind? = nil
    @State private var toolCompleted = false

    private var chooseToolStep: some View {
        VStack(spacing: 20) {
            Text("Choose what helps you")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            Text("Recommended for Quit \(currentProgramType.displayName)")
                .font(Typography.caption)
                .foregroundColor(Color(hex: currentProgramType.colorHex))

            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(currentProgramType.recommendedTools, id: \.id) { tool in
                    Button {
                        selectedTool = tool
                        activeToolKind = tool
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: tool.iconName)
                                .font(.system(size: 28))
                                .foregroundColor(.neonCyan)
                            Text(tool.displayName)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.appText)
                                .lineLimit(1)
                            Text(tool.shortDescription)
                                .font(.system(size: 10))
                                .foregroundColor(.subtleText)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.cardBackground)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                }

                // Quick Journal square
                Button {
                    selectedTool = .journaling
                    showJournalSheet = true
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: "pencil.and.scribble")
                            .font(.system(size: 28))
                            .foregroundColor(.neonBlue)
                        Text("Quick Journal")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.appText)
                            .lineLimit(1)
                        Text("Write it out")
                            .font(.system(size: 10))
                            .foregroundColor(.subtleText)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)

            Text("Use a tool, then tell us how it went")
                .font(Typography.caption)
                .foregroundColor(.subtleText)
        }
        .padding()
        .sheet(item: $activeToolKind, onDismiss: {
            // Check if tool signaled completion
            if UserDefaults.standard.bool(forKey: "cravingToolDidComplete") {
                UserDefaults.standard.set(false, forKey: "cravingToolDidComplete")
                toolCompleted = true
            }
        }) { tool in
            NavigationView { toolDestinationView(for: tool) }
                .navigationViewStyle(.stack)
                .environmentObject(environment)
                .environment(\.managedObjectContext, environment.viewContext)
        }
        .sheet(isPresented: $showJournalSheet, onDismiss: {
            // Journal counts as completed if they wrote something
            if !journalNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                toolCompleted = true
                withAnimation { currentStep = .outcome }
            }
        }) {
            NavigationView {
                VStack(spacing: 16) {
                    Text("What are you feeling right now?")
                        .font(Typography.headline)
                        .foregroundColor(.neonBlue)
                        .padding(.top, 20)

                    TextEditor(text: $journalNotes)
                        .font(Typography.body)
                        .foregroundColor(.textPrimary)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
                        .padding(.horizontal)

                    Button {
                        showJournalSheet = false
                    } label: {
                        Text("Done")
                    }
                    .buttonStyle(RainbowButtonStyle())
                    .disabled(journalNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(journalNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
                    .padding(.horizontal)

                    Spacer()
                }
                .background(Color.appBackground.ignoresSafeArea())
                .navigationTitle("Quick Journal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showJournalSheet = false }
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    }

    private func toolDestinationView(for tool: CravingToolKind) -> AnyView {
        // Tools launched from craving protocol skip their own resist popup
        // The craving outcome screen handles that
        switch tool {
        case .breathing:        return AnyView(BreathingExerciseView(skipResistPopup: true))
        case .bodyOverride:     return AnyView(BodyOverrideView(skipResistPopup: true))
        case .futureThinking:   return AnyView(TimePortalView(skipResistPopup: true))
        case .valuesCompass:    return AnyView(ValuesCompassView(skipResistPopup: true))
        case .copingSimulator:  return AnyView(CopingSimulatorView(skipResistPopup: true))
        case .focusShift:       return AnyView(FocusShiftView(skipResistPopup: true))
        case .urgeDefusion:     return AnyView(UrgeDefusionView(skipResistPopup: true))
        case .puzzle:           return AnyView(NumberPuzzleView(skipResistPopup: true))
        default:                return AnyView(BreathingExerciseView(skipResistPopup: true))
        }
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

    @State private var outcomeSelected: Bool? = nil

    private var outcomeStepContent: some View {
        VStack(spacing: 24) {
            Text("How did it go?")
                .font(.title2.weight(.bold))
                .foregroundColor(.appText)

            HStack(spacing: 16) {
                // I Fought Through It
                Button {
                    outcomeSelected = true
                    didResist = true
                } label: {
                    VStack(spacing: 14) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 40))
                        Text("I Fought\nThrough It")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(outcomeSelected == true ? .neonGreen : .neonGreen.opacity(0.7))
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .background(outcomeSelected == true ? Color.neonGreen.opacity(0.12) : Color.neonGreen.opacity(0.04))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(outcomeSelected == true ? Color.neonGreen : Color.neonGreen.opacity(0.2), lineWidth: outcomeSelected == true ? 2 : 1)
                    )
                    .shadow(color: outcomeSelected == true ? Color.neonGreen.opacity(0.3) : .clear, radius: 8)
                }

                // I Gave In
                Button {
                    outcomeSelected = false
                    didResist = false
                } label: {
                    VStack(spacing: 14) {
                        Image(systemName: "heart.circle")
                            .font(.system(size: 40))
                        Text("I Gave In")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(outcomeSelected == false ? .neonOrange : .neonOrange.opacity(0.7))
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .background(outcomeSelected == false ? Color.neonOrange.opacity(0.12) : Color.neonOrange.opacity(0.04))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(outcomeSelected == false ? Color.neonOrange : Color.neonOrange.opacity(0.2), lineWidth: outcomeSelected == false ? 2 : 1)
                    )
                    .shadow(color: outcomeSelected == false ? Color.neonOrange.opacity(0.3) : .clear, radius: 8)
                }
            }
            .padding(.horizontal)

            // Contextual message
            if let selected = outcomeSelected {
                VStack(spacing: 8) {
                    if selected {
                        Text("You're stronger than the urge")
                            .font(Typography.headline)
                            .foregroundColor(.neonGreen)
                        Text("Every craving you beat makes the next one weaker. You just proved you can do this.")
                            .font(Typography.callout)
                            .foregroundColor(.subtleText)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("That takes real courage to admit")
                            .font(Typography.headline)
                            .foregroundColor(.neonOrange)
                        Text("A setback is not the end — it's a lesson. Your streak resets, but your courage doesn't. Every time you try again, you get stronger.")
                            .font(Typography.callout)
                            .foregroundColor(.subtleText)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background((selected ? Color.neonGreen : Color.neonOrange).opacity(0.06))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke((selected ? Color.neonGreen : Color.neonOrange).opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                .transition(.opacity)
            }
        }
        .padding()
    }

    private var canProceed: Bool {
        switch currentStep {
        case .reassurance: return true
        case .intensity: return true
        case .triggers: return !selectedTriggers.isEmpty || isOtherSelected
        case .chooseTool: return toolCompleted
        case .outcome: return outcomeSelected != nil
        }
    }

    // MARK: - Persistent Bottom Button

    private var bottomButtonLabel: String {
        switch currentStep {
        case .reassurance:  return "I'm Ready"
        case .intensity:    return "Next"
        case .triggers:     return "Next"
        case .chooseTool:   return toolCompleted ? "Continue" : "Choose a tool above"
        case .outcome:      return "Save & Close"
        }
    }

    private func handleBottomButtonAction() {
        switch currentStep {
        case .reassurance, .intensity, .triggers:
            advanceStep()
        case .chooseTool:
            if toolCompleted {
                withAnimation { currentStep = .outcome }
            }
        case .outcome:
            saveCravingEntry()
            presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Actions

    private func advanceStep() {
        withAnimation {
            switch currentStep {
            case .reassurance:
                currentStep = .intensity
            case .intensity:
                currentStep = .triggers
            case .triggers:
                currentStep = .chooseTool
            case .chooseTool:
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

        // Only save journal if user actually used the quick journal tool
        if selectedTool == .journaling && !journalNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
