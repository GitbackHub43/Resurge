import SwiftUI

struct BreathingExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPattern: BreathingPattern = .relaxing
    @State private var isActive = false
    @State private var isExpanded = false
    @State private var breathText = "Tap Start to begin"
    @State private var cycleCount = 0
    @State private var isComplete = false

    enum BreathingPattern: String, CaseIterable {
        case relaxing = "Relaxing (4-7-8)"
        case box = "Box Breathing (4-4-4-4)"
        case calm = "Calming (4-4)"
        case energizing = "Energizing (2-2)"

        var inhale: Double {
            switch self { case .relaxing: return 4; case .box: return 4; case .calm: return 4; case .energizing: return 2 }
        }
        var hold: Double {
            switch self { case .relaxing: return 7; case .box: return 4; case .calm: return 0; case .energizing: return 0 }
        }
        var exhale: Double {
            switch self { case .relaxing: return 8; case .box: return 4; case .calm: return 4; case .energizing: return 2 }
        }
        var holdAfter: Double {
            switch self { case .box: return 4; default: return 0 }
        }
        var color: Color {
            switch self { case .relaxing: return .neonCyan; case .box: return .neonPurple; case .calm: return .neonBlue; case .energizing: return .neonGold }
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                exerciseView
            }
        }
        .navigationTitle("Breathing Exercise")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Exercise View

    private var exerciseView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            // Pattern picker
            VStack(spacing: 8) {
                Text("Choose a pattern")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                            Button {
                                selectedPattern = pattern
                            } label: {
                                Text(pattern.rawValue)
                                    .font(Typography.caption)
                                    .foregroundColor(selectedPattern == pattern ? .white : .subtleText)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedPattern == pattern ? pattern.color : Color.cardBackground)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(selectedPattern == pattern ? Color.clear : Color.cardBorder, lineWidth: 1)
                                    )
                            }
                            .disabled(isActive)
                        }
                    }
                    .padding(.horizontal, AppStyle.screenPadding)
                }
            }

            Spacer()

            // Breathing circle
            VStack(spacing: 16) {
                Text(breathText)
                    .font(Typography.title)
                    .foregroundColor(selectedPattern.color)
                    .animation(.easeInOut(duration: 0.3), value: breathText)

                ZStack {
                    // Outer ring
                    Circle()
                        .fill(selectedPattern.color.opacity(0.05))
                        .frame(width: 240, height: 240)

                    // Animated circle
                    Circle()
                        .fill(selectedPattern.color.opacity(0.15))
                        .frame(width: isExpanded ? 200 : 80, height: isExpanded ? 200 : 80)
                        .shadow(color: selectedPattern.color.opacity(0.5), radius: isExpanded ? 30 : 10)

                    // Border ring
                    Circle()
                        .stroke(selectedPattern.color.opacity(0.3), lineWidth: 2)
                        .frame(width: isExpanded ? 220 : 100, height: isExpanded ? 220 : 100)

                    // Cycle counter
                    if isActive {
                        Text("\(cycleCount)")
                            .font(Typography.counter)
                            .foregroundColor(selectedPattern.color.opacity(0.3))
                    }
                }
                .animation(.easeInOut(duration: selectedPattern.inhale), value: isExpanded)

                Text("Cycle \(cycleCount) of 5")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }

            Spacer()

            // Start/Stop button
            if !isActive {
                Button {
                    startBreathing()
                } label: {
                    Text("Start")
                }
                .buttonStyle(RainbowButtonStyle())
                .padding(.horizontal, AppStyle.screenPadding)
            } else {
                Button {
                    isActive = false
                    breathText = "Tap Start to begin"
                    isExpanded = false
                } label: {
                    Text("Stop")
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonOrange))
                .padding(.horizontal, AppStyle.screenPadding)
            }

            // Disclaimer
            Text("This exercise is for general wellness. If you experience dizziness, stop immediately.")
                .font(Typography.footnote)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.bottom, AppStyle.spacing)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()
            SparkleParticlesView(count: 20, colors: [selectedPattern.color, .neonGold])
                .frame(height: 100)

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(.neonGreen)
                .shadow(color: .neonGreen.opacity(0.4), radius: 12)

            Text("Well Done!")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("You completed 5 breathing cycles.")
                .font(Typography.body)
                .foregroundColor(.subtleText)

            Spacer()

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Done")
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
    }

    // MARK: - Breathing Logic

    private func startBreathing() {
        isActive = true
        cycleCount = 0
        runCycle()
    }

    private func runCycle() {
        guard isActive else { return }
        cycleCount += 1

        if cycleCount > 5 {
            isActive = false
            isComplete = true
            return
        }

        let pattern = selectedPattern

        // Inhale
        breathText = "Breathe in..."
        isExpanded = true

        DispatchQueue.main.asyncAfter(deadline: .now() + pattern.inhale) {
            guard isActive else { return }

            if pattern.hold > 0 {
                // Hold
                breathText = "Hold..."
                DispatchQueue.main.asyncAfter(deadline: .now() + pattern.hold) {
                    guard isActive else { return }
                    exhalePhase(pattern: pattern)
                }
            } else {
                exhalePhase(pattern: pattern)
            }
        }
    }

    private func exhalePhase(pattern: BreathingPattern) {
        breathText = "Breathe out..."
        isExpanded = false

        DispatchQueue.main.asyncAfter(deadline: .now() + pattern.exhale) {
            guard isActive else { return }

            if pattern.holdAfter > 0 {
                breathText = "Hold..."
                DispatchQueue.main.asyncAfter(deadline: .now() + pattern.holdAfter) {
                    guard isActive else { return }
                    runCycle()
                }
            } else {
                runCycle()
            }
        }
    }
}

struct BreathingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BreathingExerciseView()
        }
        .preferredColorScheme(.dark)
    }
}
