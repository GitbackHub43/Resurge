import SwiftUI

struct GroundingExerciseView: View {

    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep: Int = 0
    @State private var isComplete: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var confettiVisible: Bool = false

    private let steps: [GroundingStep] = [
        GroundingStep(number: 5, sense: "SEE", prompt: "Name 5 things you can SEE", icon: "eye.fill", color: .neonCyan),
        GroundingStep(number: 4, sense: "HEAR", prompt: "Name 4 things you can HEAR", icon: "ear.fill", color: .neonBlue),
        GroundingStep(number: 3, sense: "TOUCH", prompt: "Name 3 things you can TOUCH", icon: "hand.raised.fill", color: .neonPurple),
        GroundingStep(number: 2, sense: "SMELL", prompt: "Name 2 things you can SMELL", icon: "nose.fill", color: .neonMagenta),
        GroundingStep(number: 1, sense: "TASTE", prompt: "Name 1 thing you can TASTE", icon: "mouth.fill", color: .neonGold)
    ]

    private let rainbowColors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonGold]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                stepView
            }
        }
        .navigationTitle("Grounding")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Step View

    private var stepView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer().frame(height: 8)

            // Progress bar
            progressBar

            // Step indicator dots
            stepDots

            Spacer()

            // Large number + sense
            VStack(spacing: 4) {
                Text("\(steps[currentStep].number)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(steps[currentStep].color)
                    .shadow(color: steps[currentStep].color.opacity(0.4), radius: 12, x: 0, y: 0)

                Text("things you can \(steps[currentStep].sense)")
                    .font(Typography.title)
                    .foregroundColor(.appText)
            }

            // Animated icon
            ZStack {
                Circle()
                    .fill(steps[currentStep].color.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseScale)

                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 44))
                    .foregroundColor(steps[currentStep].color)
                    .shadow(color: steps[currentStep].color.opacity(0.5), radius: 8, x: 0, y: 0)
                    .scaleEffect(pulseScale)
            }
            .onAppear { startPulse() }
            .onChange(of: currentStep) { _ in startPulse() }

            // Prompt
            Text(steps[currentStep].prompt)
                .font(Typography.headline)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Text("Look around and notice them. No need to type \u{2014} just observe.")
                .font(Typography.caption)
                .foregroundColor(.subtleText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            // Navigation buttons
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
                    .frame(width: geo.size.width * CGFloat(currentStep + 1) / 5.0, height: 8)
                    .animation(.easeInOut(duration: 0.4), value: currentStep)
            }
        }
        .frame(height: 8)
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index <= currentStep ? rainbowColors[index] : Color.cardBackground)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(rainbowColors[index].opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: index <= currentStep ? rainbowColors[index].opacity(0.4) : .clear, radius: 4, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: AppStyle.spacing) {
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
                }
                .buttonStyle(SecondaryButtonStyle(color: steps[currentStep].color))
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentStep < 4 {
                        currentStep += 1
                    } else {
                        isComplete = true
                        confettiVisible = true
                    }
                }
            } label: {
                HStack {
                    Text(currentStep < 4 ? "Done \u{2014} Next" : "Finish")
                    if currentStep < 4 {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .buttonStyle(RainbowButtonStyle())
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

            Text("You're Grounded")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("You brought yourself back to the present moment.\nYour awareness is your strength.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

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

    // MARK: - Helpers

    private func startPulse() {
        pulseScale = 1.0
        withAnimation(
            Animation.easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.1
        }
    }
}

// MARK: - Grounding Step Model

private struct GroundingStep {
    let number: Int
    let sense: String
    let prompt: String
    let icon: String
    let color: Color
}

struct GroundingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroundingExerciseView()
        }
        .preferredColorScheme(.dark)
    }
}
