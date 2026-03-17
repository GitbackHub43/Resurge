import SwiftUI
import CoreData

struct AddEditHabitView: View {

    enum Mode {
        case add
        case edit(CDHabit)
    }

    let mode: Mode

    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedProgramType: ProgramType = .smoking
    @State private var startDate: Date = Date()
    @State private var goalDays: Int = 30
    @State private var costPerUnit: String = ""
    @State private var timePerUnit: String = ""
    @State private var dailyUnits: String = ""
    @State private var reasonToQuit: String = ""
    @State private var selectedColorHex: String = ProgramType.smoking.colorHex
    @State private var selectedIconName: String = ProgramType.smoking.iconName

    @State private var currentStep: Int = 0
    @State private var stepDirection: Int = 1 // 1 = forward, -1 = backward
    @State private var goalPeriod: GoalPeriod = .oneMonth
    @State private var programSetupValues: [String: String] = [:]

    private let totalSteps = 3

    private let rainbowDotColors: [Color] = [
        .neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold
    ]

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationView {
            Group {
                if isEditing {
                    editFormView
                } else {
                    addStepView
                }
            }
            .navigationTitle(isEditing ? "Edit Habit" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.neonCyan)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveHabit()
                        }
                        .font(Typography.headline)
                        .foregroundColor(.neonCyan)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .onAppear {
                loadExistingData()
            }
        }
    }

    // MARK: - Multi-Step Add Flow

    private var addStepView: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Step indicator dots
                stepIndicator
                    .padding(.top, 8)

                // Step content
                TabView(selection: $currentStep) {
                    step1ProgramSelection
                        .tag(0)

                    ProgramSetupView(
                        programType: selectedProgramType,
                        setupValues: $programSetupValues,
                        startDate: $startDate,
                        onNext: { }
                    )
                    .tag(1)

                    WhyGoalsView(
                        reasonToQuit: $reasonToQuit,
                        goalPeriod: $goalPeriod,
                        onNext: { }
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, AppStyle.screenPadding)
                    .padding(.bottom, AppStyle.largeSpacing)
            }
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep
                          ? rainbowDotColors[step % rainbowDotColors.count]
                          : Color.cardBorder.opacity(0.4))
                    .frame(width: step == currentStep ? 10 : 8,
                           height: step == currentStep ? 10 : 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Step 1: What are you quitting?

    private var step1ProgramSelection: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Header
                VStack(spacing: 8) {
                    Text("What are you quitting?")
                        .font(Typography.largeTitle)
                        .rainbowText()
                        .multilineTextAlignment(.center)

                    Text("Choose the habit you want to overcome.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppStyle.largeSpacing)

                // Program type list with animated illustrations
                VStack(spacing: 8) {
                    ForEach(ProgramType.allCases) { program in
                        programRow(program)
                    }
                }
                .padding(.horizontal, AppStyle.screenPadding)

                Spacer().frame(height: 80)
            }
        }
    }

    // MARK: - Program Row (reuses onboarding style)

    @ViewBuilder
    private func programRow(_ program: ProgramType) -> some View {
        let isSelected = selectedProgramType == program
        let color = Color(hex: program.colorHex)

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedProgramType = program
                name = "Quit \(program.displayName)"
                selectedColorHex = program.colorHex
                selectedIconName = program.iconName
            }
        } label: {
            HStack(spacing: 0) {
                // Left: radio + text
                HStack(spacing: 12) {
                    // Radio dot
                    ZStack {
                        Circle()
                            .stroke(isSelected ? color : Color.cardBorder, lineWidth: 2)
                            .frame(width: 20, height: 20)

                        if isSelected {
                            Circle()
                                .fill(color)
                                .frame(width: 10, height: 10)
                        }
                    }

                    Text(program.displayName)
                        .font(Typography.headline)
                        .foregroundColor(isSelected ? .textPrimary : .textSecondary)
                }

                Spacer()

                // Right: animated illustration
                ZStack {
                    illustrationView(for: program, isSelected: isSelected)
                }
                .frame(width: 70, height: 50)
                .clipped()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? color.opacity(0.08) : Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color.opacity(0.6) : Color.cardBorder.opacity(0.5), lineWidth: isSelected ? 1.5 : 0.5)
            )
            .shadow(color: isSelected ? color.opacity(0.2) : .clear, radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Illustration per Program

    @ViewBuilder
    private func illustrationView(for program: ProgramType, isSelected: Bool) -> some View {
        let color = Color(hex: program.colorHex)

        switch program {
        case .smoking:
            SmokingIllustration(isActive: isSelected, color: color)
        case .alcohol:
            AlcoholIllustration(isActive: isSelected, color: color)
        case .porn:
            ShieldIllustration(isActive: isSelected, color: color)
        case .phone:
            PhoneIllustration(isActive: isSelected, color: color)
        case .socialMedia:
            SocialMediaIllustration(isActive: isSelected, color: color)
        case .gaming:
            GamingIllustration(isActive: isSelected, color: color)
        case .sugar:
            SugarIllustration(isActive: isSelected, color: color)
        case .emotionalEating:
            EatingIllustration(isActive: isSelected, color: color)
        case .shopping:
            ShoppingIllustration(isActive: isSelected, color: color)
        case .gambling:
            DiceIllustration(isActive: isSelected, color: color)
        }
    }

    // MARK: - Step 2: When did you start?

    private var step2Timeline: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Header
                VStack(spacing: 8) {
                    Text("When did you start?")
                        .font(Typography.largeTitle)
                        .rainbowText()
                        .multilineTextAlignment(.center)

                    Text("Set your quit date and recovery goal.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppStyle.largeSpacing)

                // Timeline card
                VStack(spacing: AppStyle.largeSpacing) {
                    // Start date
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Quit Date", systemImage: "calendar")
                            .font(Typography.headline)
                            .foregroundColor(.textPrimary)

                        DatePicker("", selection: $startDate, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .accentColor(Color(hex: selectedProgramType.colorHex))
                    }

                    RainbowDivider()

                    // Goal days
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Recovery Goal", systemImage: "target")
                            .font(Typography.headline)
                            .foregroundColor(.textPrimary)

                        HStack {
                            Text("\(goalDays)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: selectedProgramType.colorHex))

                            Text("days")
                                .font(Typography.body)
                                .foregroundColor(.subtleText)

                            Spacer()
                        }

                        // Goal presets
                        HStack(spacing: 8) {
                            ForEach([7, 30, 90, 180, 365], id: \.self) { days in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        goalDays = days
                                    }
                                } label: {
                                    Text(goalDaysLabel(days))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(goalDays == days ? .white : .textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            goalDays == days
                                            ? Color(hex: selectedProgramType.colorHex)
                                            : Color.cardBorder.opacity(0.2)
                                        )
                                        .cornerRadius(8)
                                }
                            }
                        }

                        Stepper("Fine-tune: \(goalDays) days",
                                value: $goalDays,
                                in: 1...1000,
                                step: goalDays < 30 ? 1 : 10)
                            .font(Typography.callout)
                            .foregroundColor(.subtleText)
                    }
                }
                .rainbowCard()
                .padding(.horizontal, AppStyle.screenPadding)

                Spacer().frame(height: 80)
            }
        }
    }

    private func goalDaysLabel(_ days: Int) -> String {
        switch days {
        case 7: return "1W"
        case 30: return "1M"
        case 90: return "3M"
        case 180: return "6M"
        case 365: return "1Y"
        default: return "\(days)D"
        }
    }

    // MARK: - Step 3: Your usage

    private var step3Usage: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Header
                VStack(spacing: 8) {
                    Text("Your usage")
                        .font(Typography.largeTitle)
                        .rainbowText()
                        .multilineTextAlignment(.center)

                    Text("Help us track your recovery progress.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppStyle.largeSpacing)

                // Usage fields card
                VStack(spacing: 20) {
                    // Time per unit
                    usageField(
                        icon: "clock.fill",
                        label: timeLabel,
                        placeholder: "0",
                        text: $timePerUnit,
                        suffix: "min"
                    )

                    RainbowDivider()

                    // Daily usage
                    usageField(
                        icon: "chart.bar.fill",
                        label: dailyUnitsLabel,
                        placeholder: "0",
                        text: $dailyUnits,
                        suffix: selectedProgramType.unitLabel
                    )
                }
                .rainbowCard()
                .padding(.horizontal, AppStyle.screenPadding)

                // Helper hint
                Text("These numbers help track your recovery progress.")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppStyle.screenPadding)

                Spacer().frame(height: 80)
            }
        }
    }

    @ViewBuilder
    private func usageField(icon: String, label: String, placeholder: String, text: Binding<String>, suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            HStack(spacing: 8) {
                TextField(placeholder, text: text)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: selectedProgramType.colorHex))
                    .multilineTextAlignment(.leading)

                Text(suffix)
                    .font(Typography.body)
                    .foregroundColor(.subtleText)

                Spacer()
            }
        }
    }

    // Contextual labels per program
    private var timeLabel: String {
        switch selectedProgramType {
        case .smoking:          return "Minutes per cigarette"
        case .alcohol:          return "Minutes per drink"
        case .porn:             return "Minutes per session"
        case .phone:            return "Wasted hours per day"
        case .socialMedia:      return "Hours per session"
        case .gaming:           return "Hours per session"
        // procrastination removed
        case .sugar:            return "Minutes per sugary item"
        case .emotionalEating:  return "Minutes per episode"
        case .shopping:         return "Minutes per impulse purchase"
        case .gambling:         return "Minutes per betting session"
        }
    }

    private var dailyUnitsLabel: String {
        selectedProgramType.dailyLabel
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            // Back button
            if currentStep > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonCyan))
            }

            // Next / Save button
            if currentStep < totalSteps - 1 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
            } else {
                Button {
                    saveHabit()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Finish")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
            }
        }
    }

    // MARK: - Edit Form (single page for existing habits)

    private var editFormView: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Habit name
                VStack(alignment: .leading, spacing: 8) {
                    Label("Habit Name", systemImage: "pencil")
                        .font(Typography.headline)
                        .foregroundColor(.textPrimary)

                    TextField("e.g., Quit Smoking", text: $name)
                        .font(Typography.body)
                        .padding(12)
                        .background(Color.cardBorder.opacity(0.1))
                        .cornerRadius(AppStyle.smallCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                .stroke(Color.cardBorder.opacity(0.3), lineWidth: 1)
                        )
                }
                .neonCard(glow: Color(hex: selectedProgramType.colorHex))
                .padding(.horizontal, AppStyle.screenPadding)

                // Program type
                VStack(alignment: .leading, spacing: 8) {
                    Label("Category", systemImage: "square.grid.2x2")
                        .font(Typography.headline)
                        .foregroundColor(.textPrimary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ProgramType.allCases) { program in
                                let isSelected = selectedProgramType == program
                                let color = Color(hex: program.colorHex)

                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedProgramType = program
                                        selectedColorHex = program.colorHex
                                        selectedIconName = program.iconName
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: program.iconName)
                                            .font(.system(size: 14))
                                        Text(program.displayName)
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(isSelected ? .white : .textSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? color : Color.cardBorder.opacity(0.15))
                                    .cornerRadius(20)
                                }
                            }
                        }
                    }
                }
                .neonCard(glow: Color(hex: selectedProgramType.colorHex))
                .padding(.horizontal, AppStyle.screenPadding)

                // Timeline
                VStack(alignment: .leading, spacing: 12) {
                    Label("Timeline", systemImage: "calendar")
                        .font(Typography.headline)
                        .foregroundColor(.textPrimary)

                    DatePicker("Start Date", selection: $startDate, in: Date()..., displayedComponents: .date)
                        .accentColor(Color(hex: selectedProgramType.colorHex))

                    Stepper("Goal: \(goalDays) days", value: $goalDays, in: 1...1000, step: goalDays < 30 ? 1 : 10)
                }
                .neonCard(glow: Color(hex: selectedProgramType.colorHex))
                .padding(.horizontal, AppStyle.screenPadding)

                // Usage
                VStack(alignment: .leading, spacing: 12) {
                    Label("Usage Details", systemImage: "chart.bar.fill")
                        .font(Typography.headline)
                        .foregroundColor(.textPrimary)

                    editUsageRow(label: timeLabel, text: $timePerUnit, placeholder: "0")
                    editUsageRow(label: dailyUnitsLabel, text: $dailyUnits, placeholder: "0")
                }
                .neonCard(glow: Color(hex: selectedProgramType.colorHex))
                .padding(.horizontal, AppStyle.screenPadding)

                // Motivation
                VStack(alignment: .leading, spacing: 8) {
                    Label("Motivation", systemImage: "heart.text.square.fill")
                        .font(Typography.headline)
                        .foregroundColor(.textPrimary)

                    ZStack(alignment: .topLeading) {
                        if reasonToQuit.isEmpty {
                            Text("Why do you want to quit?")
                                .foregroundColor(.subtleText)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $reasonToQuit)
                            .font(Typography.body)
                            .frame(minHeight: 80)
                            .background(Color.clear)
                            .onAppear { UITextView.appearance().backgroundColor = .clear }
                    }
                    .padding(12)
                    .background(Color.cardBorder.opacity(0.1))
                    .cornerRadius(AppStyle.smallCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                            .stroke(Color.cardBorder.opacity(0.3), lineWidth: 1)
                    )
                }
                .neonCard(glow: Color(hex: selectedProgramType.colorHex))
                .padding(.horizontal, AppStyle.screenPadding)

                Spacer().frame(height: 20)
            }
            .padding(.top, AppStyle.spacing)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    @ViewBuilder
    private func editUsageRow(label: String, text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Text(label)
                .font(Typography.body)
                .foregroundColor(.textSecondary)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(Typography.body)
                .frame(width: 100)
                .padding(8)
                .background(Color.cardBorder.opacity(0.1))
                .cornerRadius(8)
        }
    }

    // MARK: - Load / Save

    private func loadExistingData() {
        guard case .edit(let habit) = mode else { return }
        name = habit.name
        selectedProgramType = ProgramType(rawValue: habit.programType) ?? .smoking
        startDate = habit.startDate
        goalDays = Int(habit.goalDays)
        costPerUnit = habit.costPerUnit > 0 ? String(format: "%.2f", habit.costPerUnit) : ""
        timePerUnit = habit.timePerUnit > 0 ? String(format: "%.0f", habit.timePerUnit) : ""
        dailyUnits = habit.dailyUnits > 0 ? String(format: "%.0f", habit.dailyUnits) : ""
        reasonToQuit = habit.reasonToQuit ?? ""
        selectedColorHex = habit.colorHex ?? selectedProgramType.colorHex
        selectedIconName = habit.iconName ?? selectedProgramType.iconName
    }

    private func saveHabit() {
        // Extract numeric values from program setup fields
        let setupKeys = programSetupValues
        let parsedCost = Double(costPerUnit) ?? 0
        let parsedTime = Double(timePerUnit) ?? 0
        let parsedUnits = Double(dailyUnits) ?? 0

        switch mode {
        case .add:
            let habit = CDHabit.create(
                in: viewContext,
                name: name.trimmingCharacters(in: .whitespaces),
                programType: selectedProgramType.rawValue,
                startDate: startDate,
                goalDays: Int32(goalPeriod.days),
                baselineCostPerDay: parsedCost * parsedUnits,
                baselineTimePerDay: parsedTime * parsedUnits,
                costPerUnit: parsedCost,
                timePerUnit: parsedTime,
                dailyUnits: parsedUnits,
                reasonToQuit: reasonToQuit.isEmpty ? nil : reasonToQuit,
                colorHex: selectedColorHex,
                iconName: selectedIconName
            )
            habit.sortOrder = 0
            try? viewContext.save()

        case .edit(let habit):
            habit.name = name.trimmingCharacters(in: .whitespaces)
            habit.programType = selectedProgramType.rawValue
            habit.startDate = startDate
            habit.goalDays = Int32(goalDays)
            habit.costPerUnit = parsedCost
            habit.timePerUnit = parsedTime
            habit.dailyUnits = parsedUnits
            habit.baselineCostPerDay = parsedCost * parsedUnits
            habit.baselineTimePerDay = parsedTime * parsedUnits
            habit.reasonToQuit = reasonToQuit.isEmpty ? nil : reasonToQuit
            habit.colorHex = selectedColorHex
            habit.iconName = selectedIconName
            habit.updatedAt = Date()
            try? viewContext.save()
        }

        dismiss()
    }
}

// MARK: - Preview

struct AddEditHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditHabitView(mode: .add)
            .environmentObject(AppEnvironment.preview)
            .environment(\.managedObjectContext, CoreDataStack.preview.viewContext)
            .preferredColorScheme(.dark)
    }
}
