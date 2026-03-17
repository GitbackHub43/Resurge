import SwiftUI

// MARK: - Emotional Eating Tools View

struct EmotionalEatingToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("HALT Check").tag(0)
                    Text("Self-Compassion").tag(1)
                    Text("Mood Journal").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: HALTCheckCard()
                case 1: SelfCompassionCard()
                default: MoodFoodJournalCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Emotional Eating Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - HALT Check

private struct HALTState: Identifiable {
    let id = UUID()
    let letter: String
    let label: String
    let question: String
    let icon: String
    let copingActions: [String]
    var isChecked: Bool = false
}

private struct HALTCheckCard: View {
    @State private var states: [HALTState] = [
        HALTState(
            letter: "H", label: "Hungry", question: "Am I physically hungry?",
            icon: "fork.knife",
            copingActions: [
                "Eat a balanced meal with protein, fat, and fiber",
                "Have a healthy snack you prepared in advance",
                "Drink a glass of water first - thirst mimics hunger",
            ]
        ),
        HALTState(
            letter: "A", label: "Angry", question: "Am I feeling angry or frustrated?",
            icon: "flame.fill",
            copingActions: [
                "Write down what is making you angry",
                "Take a brisk 10-minute walk",
                "Practice box breathing: 4 in, 4 hold, 4 out, 4 hold",
            ]
        ),
        HALTState(
            letter: "L", label: "Lonely", question: "Am I feeling lonely or disconnected?",
            icon: "person.2.slash.fill",
            copingActions: [
                "Call or text a friend or family member",
                "Go to a public place (coffee shop, park)",
                "Write in your journal about what you need",
            ]
        ),
        HALTState(
            letter: "T", label: "Tired", question: "Am I tired or exhausted?",
            icon: "moon.zzz.fill",
            copingActions: [
                "Take a 20-minute power nap if possible",
                "Do gentle stretching for 5 minutes",
                "Step outside for fresh air and sunlight",
            ]
        ),
    ]
    @State private var showResults = false

    private var checkedStates: [HALTState] {
        states.filter(\.isChecked)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("HALT Check", systemImage: "hand.raised.fill")
                .font(.headline)
                .foregroundColor(Color.neonOrange)

            Text("Before you eat, check in with yourself. Are you truly hungry, or is something else going on?")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            if showResults {
                resultsView
            } else {
                checklistView
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    private var checklistView: some View {
        VStack(spacing: 12) {
            ForEach($states) { $state in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        state.isChecked.toggle()
                    }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(state.isChecked ? Color.neonOrange : Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Text(state.letter)
                                .font(Font.title2.weight(.bold))
                                .foregroundColor(state.isChecked ? .white : Color.subtleText)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(state.label)
                                .font(Font.subheadline.weight(.semibold))
                                .foregroundColor(Color.appText)
                            Text(state.question)
                                .font(.caption)
                                .foregroundColor(Color.subtleText)
                        }

                        Spacer()

                        Image(systemName: state.isChecked ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(state.isChecked ? Color.neonOrange : Color.gray.opacity(0.3))
                    }
                    .padding(12)
                    .background(state.isChecked ? Color.neonOrange.opacity(0.08) : Color.appBackground)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }

            Button {
                withAnimation(.spring(response: 0.3)) {
                    showResults = true
                }
            } label: {
                Text("See My Results")
                    .font(Font.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient(colors: [.neonOrange, .neonMagenta, .neonPurple], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }

    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if checkedStates.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 40))
                        .foregroundColor(Color.neonCyan)
                    Text("You are not Hungry, Angry, Lonely, or Tired.")
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Color.neonCyan)
                    Text("If you still want to eat, ask yourself: what am I really looking for right now?")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else {
                Text("You identified: \(checkedStates.map(\.label).joined(separator: ", "))")
                    .font(Font.subheadline.weight(.semibold))
                    .foregroundColor(Color.neonOrange)

                Text("Here is what to do instead of eating:")
                    .font(.subheadline)
                    .foregroundColor(Color.subtleText)

                ForEach(checkedStates) { state in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: state.icon)
                                .foregroundColor(Color.neonOrange)
                            Text("For \(state.label):")
                                .font(Font.subheadline.weight(.semibold))
                        }

                        ForEach(state.copingActions, id: \.self) { action in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(Color.neonCyan)
                                    .padding(.top, 2)
                                Text(action)
                                    .font(.caption)
                                    .foregroundColor(Color.appText)
                            }
                        }
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(10)
                }
            }

            Button {
                withAnimation {
                    showResults = false
                    for i in states.indices { states[i].isChecked = false }
                }
            } label: {
                Text("Check Again")
                    .font(Font.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Self-Compassion Script

private struct CompassionStep: Identifiable {
    let id = UUID()
    let step: Int
    let title: String
    let script: String
    let icon: String
}

private struct SelfCompassionCard: View {
    @State private var currentStep = 0

    private let steps: [CompassionStep] = [
        CompassionStep(step: 1, title: "Acknowledge the Feeling", script: "Right now, I am feeling the urge to eat for comfort. This is a moment of suffering, and that is okay. I notice this feeling without judging myself.", icon: "eye.fill"),
        CompassionStep(step: 2, title: "Common Humanity", script: "I am not alone in this. Millions of people struggle with emotional eating. This does not make me weak - it makes me human. Everyone has coping patterns.", icon: "person.3.fill"),
        CompassionStep(step: 3, title: "Speak Kindly", script: "I am doing my best. I deserve the same kindness I would give a good friend. I do not need to be perfect. I just need to be aware.", icon: "heart.fill"),
        CompassionStep(step: 4, title: "Choose Gently", script: "I have the power to choose what happens next. Whatever I decide is not a failure. I am learning and growing with each moment of awareness.", icon: "sparkles"),
        CompassionStep(step: 5, title: "Breathe and Release", script: "Take three slow breaths. With each exhale, release the tension. I am safe. I am enough. This moment will pass, and I will be okay.", icon: "wind"),
    ]

    var body: some View {
        VStack(spacing: 16) {
            Label("Self-Compassion Script", systemImage: "heart.fill")
                .font(.headline)
                .foregroundColor(Color.neonMagenta)

            Text("Step \(currentStep + 1) of \(steps.count)")
                .font(.caption)
                .foregroundColor(Color.subtleText)

            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Color.neonCyan : Color.gray.opacity(0.2))
                        .frame(width: 10, height: 10)
                }
            }

            let step = steps[currentStep]

            VStack(spacing: 12) {
                Image(systemName: step.icon)
                    .font(.system(size: 36))
                    .foregroundColor(Color.neonCyan)

                Text(step.title)
                    .font(Font.title3.weight(.semibold))
                    .foregroundColor(Color.appText)

                Text(step.script)
                    .font(.subheadline)
                    .foregroundColor(Color.appText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding()
                    .background(Color.neonCyan.opacity(0.05))
                    .cornerRadius(12)
            }
            .padding(.vertical, 8)

            HStack(spacing: 12) {
                if currentStep > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep -= 1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appBackground)
                        .foregroundColor(Color.subtleText)
                        .cornerRadius(12)
                    }
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if currentStep < steps.count - 1 {
                            currentStep += 1
                        } else {
                            currentStep = 0
                        }
                    }
                } label: {
                    HStack {
                        Text(currentStep < steps.count - 1 ? "Next" : "Start Over")
                        if currentStep < steps.count - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(Font.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Mood-Food Journal

private struct MoodFoodEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    var mood: String
    var moodIntensity: Int
    var food: String
    var wasEmotional: Bool
}

private struct MoodFoodJournalCard: View {
    @State private var entries: [MoodFoodEntry] = [
        MoodFoodEntry(timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(), mood: "Stressed", moodIntensity: 4, food: "Chocolate bar", wasEmotional: true),
        MoodFoodEntry(timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(), mood: "Content", moodIntensity: 2, food: "Salad with chicken", wasEmotional: false),
    ]
    @State private var newMood = ""
    @State private var newFood = ""
    @State private var newIntensity = 3
    @State private var newWasEmotional = false
    @State private var showForm = false

    private let moods = ["Happy", "Sad", "Stressed", "Anxious", "Bored", "Angry", "Content", "Lonely"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Mood-Food Journal", systemImage: "book.fill")
                .font(.headline)
                .foregroundColor(Color.neonPurple)

            Text("Track the connection between what you feel and what you eat.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            Button {
                withAnimation { showForm.toggle() }
            } label: {
                HStack {
                    Image(systemName: showForm ? "chevron.up" : "plus.circle.fill")
                    Text(showForm ? "Hide Form" : "Log Mood + Food")
                        .font(Font.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.neonGold)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            if showForm {
                VStack(spacing: 12) {
                    // Mood selector
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How are you feeling?")
                            .font(Font.caption.weight(.medium))
                            .foregroundColor(Color.subtleText)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(moods, id: \.self) { mood in
                                    Button {
                                        newMood = mood
                                    } label: {
                                        Text(mood)
                                            .font(Font.caption.weight(newMood == mood ? .bold : .regular))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(newMood == mood ? Color.neonGold.opacity(0.2) : Color.appBackground)
                                            .foregroundColor(newMood == mood ? Color.neonGold : Color.subtleText)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(newMood == mood ? Color.neonGold : Color.clear, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Intensity
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mood Intensity: \(newIntensity)/5")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                        HStack {
                            ForEach(1...5, id: \.self) { level in
                                Button {
                                    newIntensity = level
                                } label: {
                                    Circle()
                                        .fill(level <= newIntensity ? Color.neonGold : Color.gray.opacity(0.2))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Text("\(level)")
                                                .font(Font.caption2.weight(.bold))
                                                .foregroundColor(level <= newIntensity ? .white : Color.subtleText)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Food
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(Color.neonGold)
                        TextField("What did you eat?", text: $newFood)
                            .font(.subheadline)
                    }
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)

                    Toggle(isOn: $newWasEmotional) {
                        Text("Was this emotional eating?")
                            .font(.subheadline)
                    }
                    .tint(Color.neonOrange)

                    Button {
                        guard !newMood.isEmpty, !newFood.isEmpty else { return }
                        let entry = MoodFoodEntry(
                            timestamp: Date(),
                            mood: newMood,
                            moodIntensity: newIntensity,
                            food: newFood,
                            wasEmotional: newWasEmotional
                        )
                        withAnimation {
                            entries.insert(entry, at: 0)
                            newMood = ""
                            newFood = ""
                            newIntensity = 3
                            newWasEmotional = false
                            showForm = false
                        }
                    } label: {
                        Text("Save Entry")
                            .font(Font.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(newMood.isEmpty || newFood.isEmpty ? Color.gray.opacity(0.3) : Color.neonGold)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(newMood.isEmpty || newFood.isEmpty)
                }
                .padding()
                .background(Color.neonGold.opacity(0.05))
                .cornerRadius(12)
            }

            // Entry list
            if !entries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Entries")
                        .font(Font.subheadline.weight(.semibold))

                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(entry.mood)
                                    .font(Font.subheadline.weight(.medium))
                                    .foregroundColor(entry.wasEmotional ? Color.neonOrange : Color.neonCyan)

                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { i in
                                        Circle()
                                            .fill(i <= entry.moodIntensity ? Color.neonGold : Color.gray.opacity(0.2))
                                            .frame(width: 6, height: 6)
                                    }
                                }

                                Spacer()

                                Text(entry.timestamp, style: .time)
                                    .font(.caption2)
                                    .foregroundColor(Color.subtleText)
                            }

                            HStack {
                                Image(systemName: "fork.knife")
                                    .font(.caption2)
                                    .foregroundColor(Color.subtleText)
                                Text(entry.food)
                                    .font(.caption)
                                    .foregroundColor(Color.subtleText)

                                if entry.wasEmotional {
                                    Spacer()
                                    Text("Emotional")
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.neonOrange.opacity(0.15))
                                        .foregroundColor(Color.neonOrange)
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.appBackground)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Preview

struct EmotionalEatingToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmotionalEatingToolsView()
        }
    }
}
