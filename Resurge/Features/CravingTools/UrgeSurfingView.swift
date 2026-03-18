import SwiftUI
import CoreData

struct UrgeSurfingView: View {

    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var elapsedSeconds: Int = 0
    @State private var timerActive: Bool = true
    @State private var breatheIn: Bool = true
    @State private var breatheOpacity: Double = 1.0
    @State private var wavePhase: CGFloat = 0
    @State private var showSurfedButton: Bool = false
    @State private var didSurfIt: Bool = false
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let breatheTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    private let waveTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if didSurfIt {
                completionView
            } else {
                surfingView
            }
        }
        .navigationTitle("Urge Surfing")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "urgeSurfing", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "urgeSurfing", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
        .onReceive(timer) { _ in
            guard timerActive else { return }
            elapsedSeconds += 1
            if elapsedSeconds >= 300 && !showSurfedButton {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSurfedButton = true
                }
            }
        }
        .onReceive(breatheTimer) { _ in
            withAnimation(.easeInOut(duration: 3.8)) {
                breatheIn.toggle()
                breatheOpacity = breatheIn ? 1.0 : 0.4
            }
        }
        .onReceive(waveTimer) { _ in
            guard timerActive else { return }
            wavePhase += 0.02
        }
    }

    // MARK: - Surfing View

    private var surfingView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: AppStyle.spacing)

            // Timer display
            timerDisplay

            Spacer().frame(height: AppStyle.spacing)

            // Phase message
            phaseMessage

            Spacer().frame(height: AppStyle.largeSpacing)

            // Wave animation
            waveView
                .frame(height: 180)

            Spacer().frame(height: AppStyle.largeSpacing)

            // Breathing cue
            breathingCue

            Spacer()

            // Info text
            Text("Urges typically peak at 20 minutes and pass within 30.")
                .font(Typography.caption)
                .foregroundColor(.subtleText.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Spacer().frame(height: AppStyle.spacing)

            // Surfed it button
            if showSurfedButton {
                Button {
                    saveCravingEntry()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        timerActive = false
                        didSurfIt = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "flag.checkered")
                        Text("I Surfed It!")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
                .padding(.horizontal, AppStyle.screenPadding)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer().frame(height: AppStyle.largeSpacing)
        }
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return Text(String(format: "%02d:%02d", minutes, seconds))
            .font(Typography.timer)
            .foregroundColor(.appText)
            .shadow(color: currentPhaseColor.opacity(0.3), radius: 8, x: 0, y: 0)
    }

    // MARK: - Phase Message

    private var phaseMessage: some View {
        let phase = currentPhase
        return VStack(spacing: 6) {
            Text(phase.title)
                .font(Typography.headline)
                .foregroundColor(phase.color)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.5), value: phaseIndex)

            Text(phase.subtitle)
                .font(Typography.caption)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.5), value: phaseIndex)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Wave View

    private var waveView: some View {
        GeometryReader { geo in
            ZStack {
                // Background wave (subtle)
                wavePath(in: geo.size, amplitude: waveAmplitude * 0.4, phaseOffset: wavePhase + 1.5)
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan.opacity(0.15), .neonPurple.opacity(0.15), .neonGold.opacity(0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )

                // Main wave
                wavePath(in: geo.size, amplitude: waveAmplitude, phaseOffset: wavePhase)
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .shadow(color: currentPhaseColor.opacity(0.4), radius: 8, x: 0, y: 0)

                // Foreground wave (subtle)
                wavePath(in: geo.size, amplitude: waveAmplitude * 0.6, phaseOffset: wavePhase + 3.0)
                    .stroke(
                        LinearGradient(
                            colors: [.neonGold.opacity(0.2), .neonMagenta.opacity(0.2), .neonCyan.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            }
        }
    }

    private func wavePath(in size: CGSize, amplitude: CGFloat, phaseOffset: CGFloat) -> Path {
        Path { path in
            let midY = size.height / 2.0
            let wavelength = size.width / 2.0
            path.move(to: CGPoint(x: 0, y: midY))
            for x in stride(from: 0, through: size.width, by: 1) {
                let relativeX = x / wavelength
                let y = midY - amplitude * sin(2 * .pi * relativeX + phaseOffset)
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
    }

    // MARK: - Breathing Cue

    private var breathingCue: some View {
        Text(breatheIn ? "Breathe in..." : "Breathe out...")
            .font(Typography.body.weight(.medium))
            .foregroundColor(.subtleText)
            .opacity(breatheOpacity)
            .animation(.easeInOut(duration: 3.8), value: breatheIn)
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            SparkleParticlesView(count: 30, colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold])
                .frame(height: 160)

            Image(systemName: "water.waves")
                .font(.system(size: 70))
                .foregroundColor(.neonGreen)
                .shadow(color: .neonGreen.opacity(0.5), radius: 16, x: 0, y: 0)

            Text("You Surfed It!")
                .font(Typography.largeTitle)
                .rainbowText()

            let minutes = elapsedSeconds / 60
            let seconds = elapsedSeconds % 60
            Text("You rode the wave for \(String(format: "%d:%02d", minutes, seconds)).\nThe urge passed. You are stronger than it.")
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

    // MARK: - Phase Logic

    private var phaseIndex: Int {
        let minutes = elapsedSeconds / 60
        if minutes < 5 { return 0 }
        if minutes < 15 { return 1 }
        if minutes < 25 { return 2 }
        if minutes < 30 { return 3 }
        return 4
    }

    private var currentPhase: (title: String, subtitle: String, color: Color) {
        switch phaseIndex {
        case 0:
            return ("The wave is building. Stay present.", "Observe the urge without judging it.", Color.neonCyan)
        case 1:
            return ("The peak is approaching. Breathe through it.", "Notice the sensations. They are temporary.", Color.neonOrange)
        case 2:
            return ("You're at the peak. This is the hardest part. You're doing it.", "Stay with it. You are in control.", Color.neonMagenta)
        case 3:
            return ("The wave is passing. Feel it decrease.", "You are proving your strength right now.", Color.neonPurple)
        default:
            return ("The wave has passed. You surfed it.", "You did it. The urge is behind you.", Color.neonGreen)
        }
    }

    private var currentPhaseColor: Color {
        currentPhase.color
    }

    /// Wave amplitude increases to a peak around 15-25 min, then decreases
    private var waveAmplitude: CGFloat {
        let minutes = Double(elapsedSeconds) / 60.0
        if minutes < 5 {
            return CGFloat(20 + minutes * 6) // 20 -> 50
        } else if minutes < 15 {
            return CGFloat(50 + (minutes - 5) * 3) // 50 -> 80
        } else if minutes < 25 {
            return 80 // peak
        } else if minutes < 35 {
            return CGFloat(80 - (minutes - 25) * 5) // 80 -> 30
        } else {
            return 20 // calm
        }
    }

    // MARK: - Save Craving Entry

    private func saveCravingEntry() {
        let habits = environment.habitRepository.fetchActive()
        guard let habit = habits.first else { return }
        environment.cravingRepository.create(
            habit: habit,
            intensity: 5,
            trigger: nil,
            tool: "Urge Surfing",
            didResist: true,
            duration: elapsedSeconds,
            mood: 3
        )
    }
}

struct UrgeSurfingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UrgeSurfingView()
                .environmentObject(AppEnvironment.preview)
        }
        .preferredColorScheme(.dark)
    }
}
