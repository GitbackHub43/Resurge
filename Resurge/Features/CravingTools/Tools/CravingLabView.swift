import SwiftUI
import CoreData

struct CravingLabView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var currentStep: Int = 0
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    // Step 0: Body region
    @State private var selectedRegion: String = ""

    // Step 1: Description
    @State private var sensationDescription: String = ""

    // Step 2: Observe
    @State private var observeTimeRemaining: Int = 180
    @State private var wavePhase: CGFloat = 0
    @State private var breatheIn: Bool = true
    @State private var breatheOpacity: Double = 1.0

    // Step 3: Rate
    @State private var intensityBefore: Double = 5
    @State private var intensityAfter: Double = 5

    private let observeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let waveTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let breatheTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    private let stepTitles = ["NOTICE", "LABEL", "OBSERVE", "RATE", "REFLECT"]
    private let stepColors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonGold]

    private let bodyRegions: [(name: String, icon: String)] = [
        ("Head", "brain.head.profile"),
        ("Chest", "heart.fill"),
        ("Stomach", "bolt.heart.fill"),
        ("Hands", "hand.raised.fill"),
        ("Legs", "figure.walk")
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                stepContentView
            }
        }
        .navigationTitle("Craving Lab")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "cravingLab", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "cravingLab", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
        .onReceive(observeTimer) { _ in
            guard currentStep == 2, observeTimeRemaining > 0 else { return }
            observeTimeRemaining -= 1
        }
        .onReceive(waveTimer) { _ in
            guard currentStep == 2 else { return }
            wavePhase += 0.02
        }
        .onReceive(breatheTimer) { _ in
            guard currentStep == 2 else { return }
            withAnimation(.easeInOut(duration: 3.8)) {
                breatheIn.toggle()
                breatheOpacity = breatheIn ? 1.0 : 0.4
            }
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
                case 0: noticeStep
                case 1: labelStep
                case 2: observeStep
                case 3: rateStep
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

    // MARK: - Step 0: Notice

    private var noticeStep: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Text("NOTICE")
                .font(Typography.headline)
                .foregroundColor(.neonCyan)

            Text("Close your eyes.\nWhere in your body do you\nfeel the craving?")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            VStack(spacing: AppStyle.spacing) {
                ForEach(bodyRegions, id: \.name) { region in
                    Button {
                        selectedRegion = region.name
                    } label: {
                        HStack(spacing: AppStyle.spacing) {
                            Image(systemName: region.icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedRegion == region.name ? .neonCyan : .subtleText)
                                .frame(width: 32)

                            Text(region.name)
                                .font(Typography.headline)
                                .foregroundColor(selectedRegion == region.name ? .appText : .subtleText)

                            Spacer()

                            if selectedRegion == region.name {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.neonCyan)
                            }
                        }
                        .padding(AppStyle.cardPadding)
                        .background(selectedRegion == region.name ? Color.neonCyan.opacity(0.1) : Color.cardBackground)
                        .cornerRadius(AppStyle.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                                .stroke(selectedRegion == region.name ? Color.neonCyan.opacity(0.4) : Color.cardBorder, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Step 1: Label

    private var labelStep: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("LABEL")
                .font(Typography.headline)
                .foregroundColor(.neonBlue)

            Text("Describe what you feel\nin your \(selectedRegion.lowercased())")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            TextEditor(text: $sensationDescription)
                .font(Typography.body)
                .foregroundColor(.appText)
                .onAppear { UITextView.appearance().backgroundColor = .clear }
                .padding(AppStyle.cardPadding)
                .frame(minHeight: 120)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
                )

            Text("e.g., \"tightness\", \"restless\", \"warmth\", \"tingling\"")
                .font(Typography.caption)
                .foregroundColor(.subtleText.opacity(0.7))
        }
    }

    // MARK: - Step 2: Observe

    private var observeStep: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("OBSERVE")
                .font(Typography.headline)
                .foregroundColor(.neonPurple)

            Text("Watch the sensation like a scientist.\nIt's data, not danger.")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            // Wave animation
            sineWaveView
                .frame(height: 120)
                .padding(.vertical, AppStyle.spacing)

            // Breathing cue
            Text(breatheIn ? "Breathe in..." : "Breathe out...")
                .font(Typography.body.weight(.medium))
                .foregroundColor(.subtleText)
                .opacity(breatheOpacity)

            // Timer
            let minutes = observeTimeRemaining / 60
            let seconds = observeTimeRemaining % 60
            Text(String(format: "%d:%02d", minutes, seconds))
                .font(Typography.timer)
                .foregroundColor(.appText)
                .shadow(color: .neonPurple.opacity(0.3), radius: 8, x: 0, y: 0)

            if observeTimeRemaining <= 0 {
                Text("Time's up. How do you feel now?")
                    .font(Typography.body)
                    .foregroundColor(.neonGreen)
            }
        }
    }

    private var sineWaveView: some View {
        GeometryReader { geo in
            ZStack {
                // Background wave
                sineWavePath(in: geo.size, amplitude: 20, phaseOffset: wavePhase + 1.5)
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan.opacity(0.15), .neonPurple.opacity(0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )

                // Main wave
                sineWavePath(in: geo.size, amplitude: 35, phaseOffset: wavePhase)
                    .stroke(
                        LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .shadow(color: .neonPurple.opacity(0.4), radius: 8, x: 0, y: 0)

                // Foreground wave
                sineWavePath(in: geo.size, amplitude: 15, phaseOffset: wavePhase + 3.0)
                    .stroke(
                        LinearGradient(
                            colors: [.neonGold.opacity(0.2), .neonMagenta.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            }
        }
    }

    private func sineWavePath(in size: CGSize, amplitude: CGFloat, phaseOffset: CGFloat) -> Path {
        Path { path in
            let centerY = size.height / 2.0
            for x in stride(from: 0, to: size.width, by: 2) {
                let y = centerY + sin(Double(x) / 30.0 + Double(phaseOffset)) * Double(amplitude)
                if x == 0 {
                    path.move(to: CGPoint(x: Double(x), y: y))
                } else {
                    path.addLine(to: CGPoint(x: Double(x), y: y))
                }
            }
        }
    }

    // MARK: - Step 3: Rate

    private var rateStep: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Text("RATE")
                .font(Typography.headline)
                .foregroundColor(.neonMagenta)

            Text("How intense is it now compared\nto when you started?")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            VStack(spacing: AppStyle.spacing) {
                sliderRow(label: "Before", value: $intensityBefore, color: .neonMagenta)
                sliderRow(label: "After", value: $intensityAfter, color: .neonCyan)
            }
            .rainbowCard()

            let change = Int(intensityBefore) - Int(intensityAfter)
            if change > 0 {
                Text("Intensity dropped from \(Int(intensityBefore)) to \(Int(intensityAfter))")
                    .font(Typography.headline)
                    .foregroundColor(.neonGreen)
                    .shadow(color: .neonGreen.opacity(0.3), radius: 6, x: 0, y: 0)
            } else if change < 0 {
                Text("Intensity rose from \(Int(intensityBefore)) to \(Int(intensityAfter)) \u{2014} that's okay. You stayed present.")
                    .font(Typography.body)
                    .foregroundColor(.neonOrange)
                    .multilineTextAlignment(.center)
            } else {
                Text("Intensity held steady at \(Int(intensityBefore)). You observed without reacting.")
                    .font(Typography.body)
                    .foregroundColor(.neonCyan)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func sliderRow(label: String, value: Binding<Double>, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(Typography.body)
                    .foregroundColor(.subtleText)
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .font(Typography.headline)
                    .foregroundColor(color)
            }

            Slider(value: value, in: 1...10, step: 1)
                .accentColor(color)
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
                .buttonStyle(SecondaryButtonStyle(color: stepColors[currentStep]))
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentStep < 3 {
                        currentStep += 1
                    } else {
                        isComplete = true
                        confettiVisible = true
                    }
                }
            } label: {
                HStack {
                    Text(currentStep < 3 ? "Next" : "Complete")
                    if currentStep < 3 {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .buttonStyle(RainbowButtonStyle())
            .disabled(currentStep == 0 && selectedRegion.isEmpty)
            .opacity(currentStep == 0 && selectedRegion.isEmpty ? 0.5 : 1.0)
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

            Text("Observation Complete")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("You observed your craving without acting on it.\nThat's real strength.")
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
}

struct CravingLabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CravingLabView()
        }
        .preferredColorScheme(.dark)
    }
}
