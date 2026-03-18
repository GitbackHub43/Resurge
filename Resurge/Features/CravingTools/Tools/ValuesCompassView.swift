import SwiftUI
import CoreData

// MARK: - Value Action Model

struct ValueAction: Codable, Identifiable {
    var id: UUID = UUID()
    var value: String
    var action: String
    var completedAt: Date
}

struct ValuesCompassView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("userValues") private var userValuesData: String = "[]"
    @AppStorage("valueActions") private var valueActionsData: String = "[]"

    @State private var currentStep: Int = 0
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    // Step 0: Value selection
    @State private var selectedValues: [String] = []

    // Step 1: Choice point
    @State private var chosenValue: String = ""

    // Step 2: Tiny action
    @State private var actionText: String = ""

    // Step 3: Timer
    @State private var selectedDuration: Int = 120 // seconds
    @State private var timerRemaining: Int = 0
    @State private var timerRunning: Bool = false

    private let actionTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let stepTitles = ["YOUR VALUES", "CHOICE POINT", "TINY ACTION", "DO IT", "COMPLETE"]
    private let stepColors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonGold]

    private let allValues = [
        "Health", "Family", "Freedom", "Honesty",
        "Growth", "Connection", "Peace", "Courage",
        "Purpose", "Joy", "Self-respect", "Independence"
    ]

    private let valueIcons: [String: String] = [
        "Health": "heart.fill",
        "Family": "house.fill",
        "Freedom": "bird.fill",
        "Honesty": "shield.fill",
        "Growth": "leaf.fill",
        "Connection": "person.2.fill",
        "Peace": "wind",
        "Courage": "flame.fill",
        "Purpose": "star.fill",
        "Joy": "sun.max.fill",
        "Self-respect": "crown.fill",
        "Independence": "figure.walk"
    ]

    private var savedValues: [String] {
        guard let data = userValuesData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return decoded
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                stepContentView
            }
        }
        .navigationTitle("Values Compass")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "valuesCompass", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "valuesCompass", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
        .onAppear {
            let saved = savedValues
            if !saved.isEmpty {
                selectedValues = saved
            }
        }
        .onReceive(actionTimer) { _ in
            guard timerRunning, timerRemaining > 0 else { return }
            timerRemaining -= 1
        }
    }

    // MARK: - Step Content

    private var stepContentView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer().frame(height: 8)

            progressBar
            stepDots

            Spacer()

            Group {
                switch currentStep {
                case 0: valuesStep
                case 1: choicePointStep
                case 2: tinyActionStep
                case 3: doItStep
                default: EmptyView()
                }
            }

            Spacer()

            navigationButtons

            Spacer().frame(height: 8)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.cardBackground)
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(currentStep + 1) / 4.0, height: 8)
                    .animation(.easeInOut(duration: 0.4), value: currentStep)
            }
        }
        .frame(height: 8)
    }

    private var stepDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(index <= currentStep ? stepColors[index] : Color.cardBackground)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(stepColors[index].opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: index <= currentStep ? stepColors[index].opacity(0.4) : .clear, radius: 4, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    // MARK: - Step 0: Your Values

    private var valuesStep: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("YOUR VALUES")
                .font(Typography.headline)
                .foregroundColor(.neonCyan)

            if savedValues.isEmpty {
                Text("Pick your top 3 values")
                    .font(Typography.title)
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(allValues, id: \.self) { value in
                        let isSelected = selectedValues.contains(value)
                        Button {
                            toggleValue(value)
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: valueIcons[value] ?? "circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(isSelected ? .neonCyan : .subtleText)

                                Text(value)
                                    .font(Typography.caption)
                                    .foregroundColor(isSelected ? .appText : .subtleText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSelected ? Color.neonCyan.opacity(0.12) : Color.cardBackground)
                            .cornerRadius(AppStyle.smallCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                    .stroke(isSelected ? Color.neonCyan.opacity(0.5) : Color.cardBorder, lineWidth: isSelected ? 2 : 1)
                            )
                        }
                    }
                }

                Text("\(selectedValues.count)/3 selected")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            } else {
                Text("Your values")
                    .font(Typography.title)
                    .foregroundColor(.appText)

                VStack(spacing: AppStyle.spacing) {
                    ForEach(selectedValues, id: \.self) { value in
                        HStack(spacing: AppStyle.spacing) {
                            Image(systemName: valueIcons[value] ?? "circle")
                                .font(.system(size: 28))
                                .foregroundColor(.neonCyan)
                                .frame(width: 36)

                            Text(value)
                                .font(Typography.headline)
                                .foregroundColor(.appText)

                            Spacer()
                        }
                        .neonCard(glow: .neonCyan)
                    }
                }
            }
        }
    }

    private func toggleValue(_ value: String) {
        if let index = selectedValues.firstIndex(of: value) {
            selectedValues.remove(at: index)
        } else if selectedValues.count < 3 {
            selectedValues.append(value)
        }
    }

    // MARK: - Step 1: Choice Point

    private var choicePointStep: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Text("CHOICE POINT")
                .font(Typography.headline)
                .foregroundColor(.neonBlue)

            Text("Right now, you're at a choice point.\nWhich value matters most?")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            VStack(spacing: AppStyle.spacing) {
                ForEach(selectedValues, id: \.self) { value in
                    Button {
                        chosenValue = value
                    } label: {
                        HStack(spacing: AppStyle.spacing) {
                            Image(systemName: valueIcons[value] ?? "circle")
                                .font(.system(size: 32))
                                .foregroundColor(chosenValue == value ? .neonBlue : .subtleText)
                                .frame(width: 40)

                            Text(value)
                                .font(Typography.title)
                                .foregroundColor(chosenValue == value ? .appText : .subtleText)

                            Spacer()

                            if chosenValue == value {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.neonBlue)
                            }
                        }
                        .padding(AppStyle.cardPadding)
                        .background(chosenValue == value ? Color.neonBlue.opacity(0.12) : Color.cardBackground)
                        .cornerRadius(AppStyle.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                                .stroke(chosenValue == value ? Color.neonBlue.opacity(0.5) : Color.cardBorder, lineWidth: chosenValue == value ? 2 : 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Tiny Action

    private var tinyActionStep: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("TINY ACTION")
                .font(Typography.headline)
                .foregroundColor(.neonPurple)

            Text("What's one tiny action you can take\nRIGHT NOW toward \(chosenValue)?")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            TextEditor(text: $actionText)
                .font(Typography.body)
                .foregroundColor(.appText)
                .onAppear { UITextView.appearance().backgroundColor = .clear }
                .padding(AppStyle.cardPadding)
                .frame(minHeight: 100)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.neonPurple.opacity(0.3), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Examples:")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText.opacity(0.5))
                Text(actionExamples)
                    .font(Typography.caption)
                    .foregroundColor(.subtleText.opacity(0.7))
            }
        }
    }

    private var actionExamples: String {
        switch chosenValue {
        case "Health": return "\"Do 10 pushups\" or \"Drink a glass of water\""
        case "Family": return "\"Call my mom\" or \"Text my sibling\""
        case "Freedom": return "\"Take a walk outside\" or \"Write in my journal\""
        case "Connection": return "\"Message a friend\" or \"Compliment someone\""
        case "Peace": return "\"Take 5 deep breaths\" or \"Sit in silence for 1 minute\""
        case "Growth": return "\"Read one page\" or \"Learn one new thing\""
        default: return "\"Take one small step toward this value\""
        }
    }

    // MARK: - Step 3: Do It

    private var doItStep: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Text("DO IT")
                .font(Typography.headline)
                .foregroundColor(.neonMagenta)

            // Show chosen value + action
            VStack(spacing: AppStyle.spacing) {
                HStack(spacing: 8) {
                    Image(systemName: valueIcons[chosenValue] ?? "circle")
                        .font(.system(size: 28))
                        .foregroundColor(.neonMagenta)
                    Text(chosenValue)
                        .font(Typography.title)
                        .foregroundColor(.appText)
                }

                Text("\"\(actionText)\"")
                    .font(Typography.body)
                    .foregroundColor(.subtleText)
                    .italic()
                    .multilineTextAlignment(.center)
            }
            .rainbowCard()

            if !timerRunning && timerRemaining == 0 {
                // Duration picker
                Text("Set a timer:")
                    .font(Typography.body)
                    .foregroundColor(.subtleText)

                HStack(spacing: AppStyle.spacing) {
                    durationButton(label: "2 min", seconds: 120)
                    durationButton(label: "5 min", seconds: 300)
                    durationButton(label: "10 min", seconds: 600)
                }

                Button {
                    timerRemaining = selectedDuration
                    timerRunning = true
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Timer")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(color: .neonMagenta))
            } else if timerRunning {
                // Timer running
                let minutes = timerRemaining / 60
                let seconds = timerRemaining % 60
                Text(String(format: "%d:%02d", minutes, seconds))
                    .font(Typography.timer)
                    .foregroundColor(.appText)
                    .shadow(color: .neonMagenta.opacity(0.3), radius: 8, x: 0, y: 0)

                if timerRemaining <= 0 {
                    Text("Time's up!")
                        .font(Typography.headline)
                        .foregroundColor(.neonGreen)
                }
            }

            Button {
                saveValueAction()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isComplete = true
                    confettiVisible = true
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("I Did It!")
                }
            }
            .buttonStyle(RainbowButtonStyle())
        }
    }

    private func durationButton(label: String, seconds: Int) -> some View {
        Button {
            selectedDuration = seconds
        } label: {
            Text(label)
                .font(Typography.body.weight(.medium))
                .foregroundColor(selectedDuration == seconds ? .appText : .subtleText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedDuration == seconds ? Color.neonMagenta.opacity(0.2) : Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(selectedDuration == seconds ? Color.neonMagenta.opacity(0.5) : Color.cardBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: AppStyle.spacing) {
            if currentStep > 0 && currentStep < 3 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: stepColors[currentStep]))
            }

            if currentStep < 3 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if currentStep == 0 {
                            saveValues()
                        }
                        currentStep += 1
                    }
                } label: {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
                .disabled(nextDisabled)
                .opacity(nextDisabled ? 0.5 : 1.0)
            }
        }
    }

    private var nextDisabled: Bool {
        switch currentStep {
        case 0: return selectedValues.count < 3
        case 1: return chosenValue.isEmpty
        case 2: return actionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default: return false
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            if confettiVisible {
                SparkleParticlesView(count: 40, colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold])
                    .frame(height: 200)
                    .transition(.opacity)
            }

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.neonGreen)
                .shadow(color: .neonGreen.opacity(0.5), radius: 16, x: 0, y: 0)
                .scaleEffect(confettiVisible ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: confettiVisible)

            Text("Values Over Cravings")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("You chose \(chosenValue) over your craving.\nThat's who you are.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            Button {
                showResistPopup = true
            } label: {
                Text("Done")
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
    }

    // MARK: - Helpers

    private func saveValues() {
        if let encoded = try? JSONEncoder().encode(selectedValues),
           let json = String(data: encoded, encoding: .utf8) {
            userValuesData = json
        }
    }

    private func saveValueAction() {
        timerRunning = false
        let entry = ValueAction(
            value: chosenValue,
            action: actionText.trimmingCharacters(in: .whitespacesAndNewlines),
            completedAt: Date()
        )
        var actions: [ValueAction] = []
        if let data = valueActionsData.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([ValueAction].self, from: data) {
            actions = decoded
        }
        actions.append(entry)
        if let encoded = try? JSONEncoder().encode(actions),
           let json = String(data: encoded, encoding: .utf8) {
            valueActionsData = json
        }
    }
}

struct ValuesCompassView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ValuesCompassView()
        }
        .preferredColorScheme(.dark)
    }
}
