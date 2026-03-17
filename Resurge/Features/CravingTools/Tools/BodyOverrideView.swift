import SwiftUI

struct BodyOverrideView: View {

    @Environment(\.presentationMode) var presentationMode

    // MARK: - State

    @State private var currentStep: Int = 0
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var urgeMeter: Double = 1.0

    // Timers
    @State private var coldTimeRemaining: Int = 30
    @State private var moveTimeRemaining: Int = 60
    @State private var timerActive: Bool = false
    @State private var activeTimer: Timer?

    // Breathing (step 2)
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathCyclesCompleted: Int = 0
    @State private var breathCircleScale: CGFloat = 0.4
    @State private var breathLabel: String = "Inhale"

    // Relaxation (step 3)
    @State private var relaxRegionIndex: Int = 0
    @State private var relaxPhase: RelaxPhase = .tense
    @State private var relaxTimeRemaining: Int = 5

    private enum BreathPhase {
        case inhale, hold, exhale
    }

    private enum RelaxPhase: String {
        case tense = "Tense"
        case hold = "Hold"
        case release = "Release"
    }

    private let steps: [OverrideStep] = [
        OverrideStep(label: "COLD", prompt: "Splash cold water on your face or hold ice", icon: "snowflake", color: .neonCyan),
        OverrideStep(label: "MOVE", prompt: "Intense movement for 60 seconds \u{2014} jumping jacks, running in place", icon: "figure.run", color: .neonOrange),
        OverrideStep(label: "BREATHE", prompt: "4-7-8 breathing \u{2014} inhale 4s, hold 7s, exhale 8s", icon: "wind", color: .neonPurple),
        OverrideStep(label: "RELAX", prompt: "Progressive muscle relaxation \u{2014} tense, hold, release", icon: "figure.mind.and.body", color: .neonGreen)
    ]

    private let relaxRegions: [String] = [
        "fists", "shoulders", "jaw", "stomach", "feet"
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                stepView
            }
        }
        .navigationTitle("Body Override")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            activeTimer?.invalidate()
        }
    }

    // MARK: - Step View

    private var stepView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer().frame(height: 8)

            progressBar

            stepDots

            // Urge meter
            urgeMeterView

            Spacer()

            // Step content
            VStack(spacing: 12) {
                Text(steps[currentStep].label)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(steps[currentStep].color)
                    .shadow(color: steps[currentStep].color.opacity(0.4), radius: 12, x: 0, y: 0)

                ZStack {
                    Circle()
                        .fill(steps[currentStep].color.opacity(0.12))
                        .frame(width: 100, height: 100)

                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 44))
                        .foregroundColor(steps[currentStep].color)
                        .shadow(color: steps[currentStep].color.opacity(0.5), radius: 8, x: 0, y: 0)
                }
            }

            // Step-specific content
            stepSpecificContent

            Spacer()

            navigationButtons

            Spacer().frame(height: 8)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Step-Specific Content

    @ViewBuilder
    private var stepSpecificContent: some View {
        switch currentStep {
        case 0:
            coldStepContent
        case 1:
            moveStepContent
        case 2:
            breatheStepContent
        case 3:
            relaxStepContent
        default:
            EmptyView()
        }
    }

    private var coldStepContent: some View {
        VStack(spacing: 12) {
            Text(steps[0].prompt)
                .font(Typography.headline)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            if timerActive && currentStep == 0 {
                Text("\(coldTimeRemaining)s")
                    .font(Typography.timer)
                    .foregroundColor(.neonCyan)
            } else if coldTimeRemaining > 0 && !timerActive {
                Button {
                    startColdTimer()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start 30s Timer")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonCyan))
            } else {
                Label("Timer Complete", systemImage: "checkmark.circle.fill")
                    .font(Typography.headline)
                    .foregroundColor(.neonGreen)
            }
        }
    }

    private var moveStepContent: some View {
        VStack(spacing: 12) {
            Text(steps[1].prompt)
                .font(Typography.headline)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            if timerActive && currentStep == 1 {
                Text("\(moveTimeRemaining)s")
                    .font(Typography.timer)
                    .foregroundColor(.neonOrange)
            } else if moveTimeRemaining > 0 && !timerActive {
                Button {
                    startMoveTimer()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start 60s Timer")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonOrange))
            } else {
                Label("Timer Complete", systemImage: "checkmark.circle.fill")
                    .font(Typography.headline)
                    .foregroundColor(.neonGreen)
            }
        }
    }

    private var breatheStepContent: some View {
        VStack(spacing: 16) {
            Text(steps[2].prompt)
                .font(Typography.caption)
                .foregroundColor(.subtleText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            ZStack {
                Circle()
                    .fill(Color.neonPurple.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .scaleEffect(breathCircleScale)

                Circle()
                    .stroke(Color.neonPurple.opacity(0.3), lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .scaleEffect(breathCircleScale)

                Text(breathLabel)
                    .font(Typography.headline)
                    .foregroundColor(.neonPurple)
            }

            Text("Cycle \(min(breathCyclesCompleted + 1, 3)) of 3")
                .font(Typography.caption)
                .foregroundColor(.subtleText)

            if !timerActive && breathCyclesCompleted == 0 {
                Button {
                    startBreathingCycle()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Breathing")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonPurple))
            } else if breathCyclesCompleted >= 3 {
                Label("Breathing Complete", systemImage: "checkmark.circle.fill")
                    .font(Typography.headline)
                    .foregroundColor(.neonGreen)
            }
        }
    }

    private var relaxStepContent: some View {
        VStack(spacing: 16) {
            if relaxRegionIndex < relaxRegions.count {
                let region = relaxRegions[relaxRegionIndex]

                Text(relaxPhasePrompt(for: region))
                    .font(Typography.title)
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: relaxPhase)

                Text("\(relaxTimeRemaining)s")
                    .font(Typography.timer)
                    .foregroundColor(.neonGreen)

                Text("Region \(relaxRegionIndex + 1) of \(relaxRegions.count)")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)

                if !timerActive && relaxRegionIndex == 0 && relaxPhase == .tense && relaxTimeRemaining == 5 {
                    Button {
                        startRelaxation()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Relaxation")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle(color: .neonGreen))
                }
            } else {
                Label("Relaxation Complete", systemImage: "checkmark.circle.fill")
                    .font(Typography.headline)
                    .foregroundColor(.neonGreen)
            }
        }
    }

    // MARK: - Urge Meter

    private var urgeMeterView: some View {
        HStack(spacing: 12) {
            Text("URGE")
                .font(Typography.badge)
                .foregroundColor(.subtleText)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cardBackground)
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(urgeMeterColor)
                        .frame(width: geo.size.width * CGFloat(urgeMeter), height: 12)
                        .animation(.easeInOut(duration: 0.6), value: urgeMeter)
                }
            }
            .frame(height: 12)

            Text("\(Int(urgeMeter * 100))%")
                .font(Typography.badge)
                .foregroundColor(urgeMeterColor)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, 8)
    }

    private var urgeMeterColor: Color {
        if urgeMeter <= 0.25 { return .neonGreen }
        if urgeMeter <= 0.5 { return .yellow }
        if urgeMeter <= 0.75 { return .orange }
        return .red
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
                            colors: [.neonCyan, .neonOrange, .neonPurple, .neonGreen],
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

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(index <= currentStep ? steps[index].color : Color.cardBackground)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(steps[index].color.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: index <= currentStep ? steps[index].color.opacity(0.4) : .clear, radius: 4, x: 0, y: 0)
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
                completeCurrentStep()
            } label: {
                HStack {
                    Text(currentStep < 3 ? "Done \u{2014} Next" : "Finish")
                    if currentStep < 3 {
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

            Text("Override Complete")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("You took control of your body and beat the urge.\nYour nervous system is on your side.")
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

    // MARK: - Timer Helpers

    private func completeCurrentStep() {
        activeTimer?.invalidate()
        timerActive = false

        withAnimation(.easeInOut(duration: 0.6)) {
            urgeMeter = max(0.0, urgeMeter - 0.25)
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep < 3 {
                currentStep += 1
            } else {
                isComplete = true
                confettiVisible = true
            }
        }
    }

    private func startColdTimer() {
        coldTimeRemaining = 30
        timerActive = true
        activeTimer?.invalidate()
        activeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if coldTimeRemaining > 0 {
                coldTimeRemaining -= 1
            } else {
                activeTimer?.invalidate()
                timerActive = false
            }
        }
    }

    private func startMoveTimer() {
        moveTimeRemaining = 60
        timerActive = true
        activeTimer?.invalidate()
        activeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if moveTimeRemaining > 0 {
                moveTimeRemaining -= 1
            } else {
                activeTimer?.invalidate()
                timerActive = false
            }
        }
    }

    private func startBreathingCycle() {
        breathCyclesCompleted = 0
        runBreathCycle()
    }

    private func runBreathCycle() {
        guard breathCyclesCompleted < 3 else {
            timerActive = false
            return
        }
        timerActive = true

        // Inhale 4s
        breathPhase = .inhale
        breathLabel = "Inhale"
        withAnimation(.easeInOut(duration: 4.0)) {
            breathCircleScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            // Hold 7s
            breathPhase = .hold
            breathLabel = "Hold"

            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                // Exhale 8s
                breathPhase = .exhale
                breathLabel = "Exhale"
                withAnimation(.easeInOut(duration: 8.0)) {
                    breathCircleScale = 0.4
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                    breathCyclesCompleted += 1
                    if breathCyclesCompleted < 3 {
                        runBreathCycle()
                    } else {
                        timerActive = false
                    }
                }
            }
        }
    }

    private func startRelaxation() {
        relaxRegionIndex = 0
        relaxPhase = .tense
        relaxTimeRemaining = 5
        runRelaxCycle()
    }

    private func runRelaxCycle() {
        guard relaxRegionIndex < relaxRegions.count else {
            timerActive = false
            return
        }
        timerActive = true
        relaxPhase = .tense
        relaxTimeRemaining = 5

        activeTimer?.invalidate()
        activeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if relaxTimeRemaining > 1 {
                relaxTimeRemaining -= 1
            } else {
                activeTimer?.invalidate()
                switch relaxPhase {
                case .tense:
                    relaxPhase = .hold
                    relaxTimeRemaining = 5
                    restartRelaxTimer()
                case .hold:
                    relaxPhase = .release
                    relaxTimeRemaining = 5
                    restartRelaxTimer()
                case .release:
                    relaxRegionIndex += 1
                    if relaxRegionIndex < relaxRegions.count {
                        runRelaxCycle()
                    } else {
                        timerActive = false
                    }
                }
            }
        }
    }

    private func restartRelaxTimer() {
        activeTimer?.invalidate()
        activeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if relaxTimeRemaining > 1 {
                relaxTimeRemaining -= 1
            } else {
                activeTimer?.invalidate()
                switch relaxPhase {
                case .tense:
                    relaxPhase = .hold
                    relaxTimeRemaining = 5
                    restartRelaxTimer()
                case .hold:
                    relaxPhase = .release
                    relaxTimeRemaining = 5
                    restartRelaxTimer()
                case .release:
                    relaxRegionIndex += 1
                    if relaxRegionIndex < relaxRegions.count {
                        runRelaxCycle()
                    } else {
                        timerActive = false
                    }
                }
            }
        }
    }

    private func relaxPhasePrompt(for region: String) -> String {
        switch relaxPhase {
        case .tense:   return "Tense your \(region)..."
        case .hold:    return "Hold..."
        case .release: return "Release..."
        }
    }
}

// MARK: - Override Step Model

private struct OverrideStep {
    let label: String
    let prompt: String
    let icon: String
    let color: Color
}

struct BodyOverrideView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BodyOverrideView()
        }
        .preferredColorScheme(.dark)
    }
}
