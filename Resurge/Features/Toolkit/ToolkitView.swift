import SwiftUI
import CoreData

struct ToolkitView: View {

    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isPremium") private var isPremium: Bool = false
    @AppStorage("selectedTheme") private var selectedTheme: String = "default"
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDHabit.createdAt, ascending: false)],
        predicate: NSPredicate(format: "isActive == YES"),
        animation: .default
    ) private var activeHabits: FetchedResults<CDHabit>
    @State private var showPremiumGate = false
    @State private var premiumFeatureName = ""
    @State private var premiumFeatureDesc = ""
    @State private var showJournalEditor = false
    @State private var journalInitialPrompt: String?
    @State private var journalEntryContext: String?
    @State private var selectedHabitForJournal: CDHabit?
    @State private var showHabitPicker = false
    @State private var pendingHabitAction: ((CDHabit) -> Void)?
    @State private var selectedCoachingHabit: CDHabit?
    @State private var showCoachingPlan = false
    @State private var selectedReasonsHabit: CDHabit?
    @State private var isNavigatingToTool = false
    @State private var toolDestination: AnyView = AnyView(EmptyView())
    @State private var showIntensitySlider = false
    @State private var toolIntensity: Double = 5
    @State private var pendingToolDestination: (() -> AnyView)?
    @State private var pendingPrompt: String?
    @State private var pendingContext: String?
    @State private var journalSheetConfig: JournalSheetConfig?

    struct JournalSheetConfig: Identifiable {
        let id = UUID()
        let prompt: String?
        let context: String?
        let habit: CDHabit?
    }

    private let columns = [
        GridItem(.flexible(), spacing: AppStyle.spacing),
        GridItem(.flexible(), spacing: AppStyle.spacing)
    ]

    // MARK: - Habit Selection Helper

    private func withHabitSelection(_ action: @escaping (CDHabit) -> Void) {
        if activeHabits.count <= 1, let habit = activeHabits.first {
            // Delay to let SwiftUI process prompt/context state changes first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action(habit)
            }
        } else {
            pendingHabitAction = action
            showHabitPicker = true
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: toolDestination, isActive: $isNavigatingToTool) { EmptyView() }
                    .hidden()

            ScrollView {
                VStack(spacing: AppStyle.largeSpacing) {

                    // SECTION 1: Workbook
                    workbookSection

                    RainbowDivider()
                        .padding(.horizontal, AppStyle.screenPadding)

                    // SECTION 2: Craving Tools
                    cravingToolsSection

                    RainbowDivider()
                        .padding(.horizontal, AppStyle.screenPadding)

                    // SECTION 3: Emergency
                    emergencySection

                    Spacer(minLength: AppStyle.largeSpacing)
                }
                .padding(.top, AppStyle.spacing)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ActivePetView()
                }
                ToolbarItem(placement: .principal) {
                    Text("Toolkit")
                        .font(Typography.title)
                        .rainbowText()
                }
            }
            } // ZStack
        }
        .navigationViewStyle(.stack)
        .premiumGate(
            isPresented: showPremiumGate,
            featureName: premiumFeatureName,
            featureDescription: premiumFeatureDesc,
            onUnlock: { showPremiumGate = false },
            onDismiss: { showPremiumGate = false }
        )
        .sheet(item: $journalSheetConfig) { config in
            JournalEditorView(initialPrompt: config.prompt, entryContext: config.context, preSelectedHabit: config.habit)
        }
        .sheet(item: $selectedCoachingHabit) { habit in
            NavigationView {
                CoachingPlanView(habit: habit)
                    .environmentObject(environment)
            }
        }
        .sheet(item: $selectedReasonsHabit) { habit in
            RememberWhyView(habitId: habit.id, habitName: habit.safeDisplayName)
        }
        .sheet(isPresented: $showHabitPicker) {
            NavigationView {
                VStack(spacing: AppStyle.largeSpacing) {
                    Spacer().frame(height: 20)
                    Text("For which habit?")
                        .font(Typography.title)
                        .rainbowText()

                    VStack(spacing: 10) {
                        ForEach(activeHabits) { habit in
                            Button {
                                showHabitPicker = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    pendingHabitAction?(habit)
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    let program = ProgramType(rawValue: habit.programType) ?? .smoking
                                    Image(systemName: program.iconName)
                                        .font(.title2)
                                        .foregroundColor(Color(hex: program.colorHex))
                                    Text(habit.safeDisplayName)
                                        .font(Typography.headline)
                                        .foregroundColor(.appText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.subtleText)
                                }
                                .padding(AppStyle.cardPadding)
                                .background(Color.cardBackground)
                                .cornerRadius(AppStyle.cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                                        .stroke(Color(hex: (ProgramType(rawValue: habit.programType) ?? .smoking).colorHex).opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                    Spacer()
                }
                .background(Color.appBackground.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showIntensitySlider) {
            NavigationView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    Text("How intense is your craving?")
                        .font(Typography.title)
                        .rainbowText()

                    Text("This helps us track which tools work best under pressure.")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Intensity value
                    Text("\(Int(toolIntensity))")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(toolIntensity >= 7 ? .neonMagenta : (toolIntensity >= 4 ? .neonOrange : .neonGreen))

                    // Slider
                    VStack(spacing: 4) {
                        Slider(value: $toolIntensity, in: 1...10, step: 1)
                            .tint(.neonCyan)
                            .padding(.horizontal, 32)

                        HStack {
                            Text("Low").font(Typography.caption).foregroundColor(.subtleText)
                            Spacer()
                            Text("High").font(Typography.caption).foregroundColor(.subtleText)
                        }
                        .padding(.horizontal, 32)
                    }

                    Spacer()

                    Button {
                        UserDefaults.standard.set(Int(toolIntensity), forKey: "lastToolIntensity")
                        showIntensitySlider = false
                        if let dest = pendingToolDestination {
                            toolDestination = dest()
                            isNavigatingToTool = true
                        }
                    } label: {
                        Text("Start Tool")
                    }
                    .buttonStyle(RainbowButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .background(Color.appBackground.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showIntensitySlider = false }
                    }
                }
            }
        }
    }

    // MARK: - Section 1: Craving Tools (Subcategorized)

    private var selectedProgramType: ProgramType {
        guard let habit = activeHabits.first else { return .smoking }
        return ProgramType(rawValue: habit.programType) ?? .smoking
    }

    private var cravingToolsSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.largeSpacing) {

            // SECTION: Recommended For You
            VStack(alignment: .leading, spacing: AppStyle.spacing) {
                let programColor = Color(hex: selectedProgramType.colorHex)
                sectionHeader(icon: "star.fill", title: "Best for Quit \(selectedProgramType.displayName)", color: programColor)

                LazyVGrid(columns: columns, spacing: AppStyle.spacing) {
                    ForEach(selectedProgramType.recommendedTools, id: \.id) { tool in
                        toolNavCard(
                            title: tool.displayName,
                            description: tool.shortDescription,
                            icon: tool.iconName,
                            color: programColor,
                            destination: { recommendedToolDestination(for: tool) }
                        )
                    }
                }
                .padding(.horizontal, AppStyle.screenPadding)
            }

            RainbowDivider()
                .padding(.horizontal, AppStyle.screenPadding)

            // SECTION: Quick Relief
            VStack(alignment: .leading, spacing: AppStyle.spacing) {
                sectionHeader(icon: "bolt.fill", title: "Quick Relief", color: .neonCyan)

                LazyVGrid(columns: columns, spacing: AppStyle.spacing) {
                    toolNavCard(
                        title: "Breathing",
                        description: "Calm your body",
                        icon: "wind",
                        color: .neonCyan,
                        destination: { AnyView(BreathingExerciseView()) }
                    )

                    premiumToolCard(
                        title: "Grounding",
                        description: "5-4-3-2-1 technique",
                        icon: "hand.raised.fill",
                        color: .neonCyan
                    ) { AnyView(GroundingExerciseView()) }

                    premiumToolCard(
                        title: "Body Override",
                        description: "Physical reset techniques",
                        icon: "figure.cooldown",
                        color: .neonCyan
                    ) { AnyView(BodyOverrideView()) }
                }
            }

            RainbowDivider()

            // SECTION: Mind Training
            VStack(alignment: .leading, spacing: AppStyle.spacing) {
                sectionHeader(icon: "brain.head.profile", title: "Mind Training", color: .neonPurple)

                LazyVGrid(columns: columns, spacing: AppStyle.spacing) {
                    toolNavCard(
                        title: "Urge Defusion",
                        description: "Unhook from thoughts",
                        icon: "brain.head.profile",
                        color: .neonPurple,
                        destination: { AnyView(UrgeDefusionView()) }
                    )

                    toolNavCard(
                        title: "Focus Shift",
                        description: "Redirect attention",
                        icon: "eye.trianglebadge.exclamationmark",
                        color: .neonPurple,
                        destination: { AnyView(FocusShiftView()) }
                    )
                }
            }

            RainbowDivider()

            // SECTION: Deep Work
            VStack(alignment: .leading, spacing: AppStyle.spacing) {
                sectionHeader(icon: "leaf.fill", title: "Deep Work", color: .neonBlue)

                LazyVGrid(columns: columns, spacing: AppStyle.spacing) {
                    premiumToolCard(
                        title: "Values Compass",
                        description: "Align with your values",
                        icon: "safari.fill",
                        color: .neonBlue
                    ) { AnyView(ValuesCompassView()) }

                    toolNavCard(
                        title: "Coping Sim",
                        description: "Practice coping skills",
                        icon: "gamecontroller.fill",
                        color: .neonBlue,
                        destination: { AnyView(CopingSimulatorView()) }
                    )

                    premiumToolCard(
                        title: "Refusal Scripts",
                        description: "Rehearse saying no",
                        icon: "text.bubble.fill",
                        color: .neonBlue
                    ) { AnyView(RefusalScriptView()) }
                }
            }

            RainbowDivider()

            // SECTION: Track & Learn
            VStack(alignment: .leading, spacing: AppStyle.spacing) {
                sectionHeader(icon: "chart.line.uptrend.xyaxis", title: "Track & Learn", color: .neonGold)

                LazyVGrid(columns: columns, spacing: AppStyle.spacing) {
                    toolNavCard(
                        title: "Time Portal",
                        description: "See your future self",
                        icon: "hourglass",
                        color: .neonGold,
                        destination: { AnyView(TimePortalView()) }
                    )

                    toolNavCard(
                        title: "Puzzle Games",
                        description: "Distract your mind",
                        icon: "puzzlepiece.fill",
                        color: .neonGold,
                        destination: { AnyView(PuzzleGameView()) }
                    )
                }
            }
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    private func recommendedToolDestination(for tool: CravingToolKind) -> AnyView {
        switch tool {
        case .breathing:        return AnyView(BreathingExerciseView())
        case .bodyOverride:     return AnyView(BodyOverrideView())
        case .futureThinking:   return AnyView(TimePortalView())
        case .valuesCompass:    return AnyView(ValuesCompassView())
        case .copingSimulator:  return AnyView(CopingSimulatorView())
        case .focusShift:       return AnyView(FocusShiftView())
        case .urgeDefusion:     return AnyView(UrgeDefusionView())
        case .puzzle:           return AnyView(NumberPuzzleView())
        default:                return AnyView(BreathingExerciseView())
        }
    }

    // MARK: - Tool Navigation Card Helper

    private func toolNavCard(title: String, description: String, icon: String, color: Color, destination: @escaping () -> AnyView) -> some View {
        Button {
            withHabitSelection { habit in
                UserDefaults.standard.set(habit.id.uuidString, forKey: "selectedToolHabitId")
                pendingToolDestination = destination
                toolIntensity = 5
                showIntensitySlider = true
            }
        } label: {
            toolCardContent(
                title: title,
                description: description,
                icon: icon,
                color: color,
                locked: false
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Premium Tool Card Helper

    private func premiumToolCard(title: String, description: String, icon: String, color: Color, destination: @escaping () -> AnyView) -> some View {
        Button {
            if isPremium {
                withHabitSelection { habit in
                    UserDefaults.standard.set(habit.id.uuidString, forKey: "selectedToolHabitId")
                    pendingToolDestination = destination
                    toolIntensity = 5
                    showIntensitySlider = true
                }
            } else {
                premiumFeatureName = title
                premiumFeatureDesc = description
                showPremiumGate = true
            }
        } label: {
            toolCardContent(
                title: title,
                description: description,
                icon: icon,
                color: color,
                locked: !isPremium
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section 2: Workbook

    private var workbookSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            sectionHeader(icon: "book.fill", title: "Workbook", color: .neonBlue)

            VStack(spacing: 10) {
                workbookRow(
                    title: "Journal Entry",
                    icon: "pencil.line",
                    color: .neonBlue,
                    prompt: nil,
                    context: nil
                )

                workbookRow(
                    title: "Gratitude Log",
                    icon: "heart.fill",
                    color: .neonOrange,
                    prompt: "Three things I'm grateful for today:\n1. \n2. \n3. ",
                    context: "gratitude"
                )

                // Daily Coaching
                Button {
                    if isPremium {
                        withHabitSelection { habit in
                            selectedCoachingHabit = habit
                        }
                    } else {
                        premiumFeatureName = "Daily Coaching"
                        premiumFeatureDesc = "Daily recovery tasks with streak tracking"
                        showPremiumGate = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.neonGold.opacity(0.15))
                                .frame(width: 36, height: 36)

                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.neonGold)
                        }

                        Text("Daily Coaching")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.appText)

                        Spacer()

                        if !isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.neonGold)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)
                        }
                    }
                    .padding(AppStyle.cardPadding)
                    .background(Color.cardBackground)
                    .cornerRadius(AppStyle.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                            .stroke(Color.neonGold.opacity(0.15), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Section 3: Reasons Vault

    private var reasonsVaultSection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            sectionHeader(icon: "heart.text.square.fill", title: "Reasons Vault", color: .neonGold)

            Button {
                withHabitSelection { habit in
                    selectedReasonsHabit = habit
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.neonGold.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.neonGold)
                            .shadow(color: Color.neonGold.opacity(0.5), radius: 6, x: 0, y: 0)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remember Your Reasons")
                            .font(Typography.headline)
                            .foregroundColor(.appText)

                        Text("Your motivation vault")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .padding(AppStyle.cardPadding)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Section 4: Emergency

    private var emergencySection: some View {
        VStack(alignment: .leading, spacing: AppStyle.spacing) {
            sectionHeader(icon: "sos.circle.fill", title: "Crisis", color: .red)

            VStack(spacing: 10) {
                emergencyRow(
                    title: "Crisis Helplines",
                    icon: "phone.fill",
                    color: .red,
                    destination: AnyView(EmergencyContactsView()),
                    isPremiumOnly: false
                )
            }
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Section Header

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

    // MARK: - Tool Card Content

    private func toolCardContent(title: String, description: String, icon: String, color: Color, locked: Bool) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 0)
            }

            Text(title)
                .font(Typography.headline)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(description)
                .font(Typography.caption)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100)
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .overlay(
            Group {
                if locked {
                    ZStack {
                        Color.black.opacity(0.3)
                            .cornerRadius(AppStyle.cornerRadius)

                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.neonGold)
                            .shadow(color: Color.neonGold.opacity(0.6), radius: 8, x: 0, y: 0)
                    }
                }
            }
        )
    }

    // MARK: - Workbook Row

    private func workbookRow(title: String, icon: String, color: Color, prompt: String?, context: String? = nil) -> some View {
        Button {
            pendingPrompt = prompt
            pendingContext = context
            if activeHabits.count <= 1, let habit = activeHabits.first {
                journalSheetConfig = JournalSheetConfig(prompt: prompt, context: context, habit: habit)
            } else {
                pendingHabitAction = { habit in
                    journalSheetConfig = JournalSheetConfig(prompt: self.pendingPrompt, context: self.pendingContext, habit: habit)
                }
                showHabitPicker = true
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.appText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }
            .padding(AppStyle.cardPadding)
            .background(Color.cardBackground)
            .cornerRadius(AppStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Emergency Row

    private func emergencyRow(title: String, icon: String, color: Color, destination: AnyView, isPremiumOnly: Bool) -> some View {
        NavigationLink(destination: destination) {
            emergencyRowContent(title: title, icon: icon, color: color, locked: false)
        }
        .buttonStyle(.plain)
    }

    private func emergencyRowContent(title: String, icon: String, color: Color, locked: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.appText)

            Spacer()

            if locked {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.neonGold)
            } else {
                Image(systemName: "chevron.right")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ToolkitView_Previews: PreviewProvider {
    static var previews: some View {
        ToolkitView()
            .environmentObject(AppEnvironment.preview)
            .preferredColorScheme(.dark)
    }
}
