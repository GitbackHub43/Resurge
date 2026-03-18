import SwiftUI
import CoreData

// MARK: - Future Scene Model

struct FutureScene: Codable, Identifiable {
    var id: UUID = UUID()
    var description: String
    var emoji: String
    var createdAt: Date
}

struct TimePortalView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("futureScenes") private var futureSceneData: String = "[]"

    @State private var isCreating: Bool = false
    @State private var currentStep: Int = 0
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false

    // Create mode state
    @State private var sceneDescription: String = ""
    @State private var selectedEmoji: String = ""
    @State private var pauseCountdown: Int = 5
    @State private var pauseActive: Bool = false

    // View mode state
    @State private var displayedScene: FutureScene?

    @State private var pulseScale: CGFloat = 1.0
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    private let emojiGrid: [String] = [
        "\u{1F31F}", "\u{2B50}", "\u{1F3C6}", "\u{1F3AF}", "\u{1F4AA}", "\u{1F9D8}\u{200D}\u{2642}\u{FE0F}",
        "\u{1F3C3}\u{200D}\u{2642}\u{FE0F}", "\u{1F3A8}", "\u{1F308}", "\u{1F3E1}", "\u{2764}\u{FE0F}", "\u{1F305}"
    ]

    private let stepTitles = ["IMAGINE", "DESCRIBE", "SYMBOLIZE", "SAVED"]
    private let stepColors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonGold]

    private let pauseTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var scenes: [FutureScene] {
        guard let data = futureSceneData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([FutureScene].self, from: data) else {
            return []
        }
        return decoded
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else if isCreating {
                createModeView
            } else {
                viewModeView
            }
        }
        .navigationTitle("Time Portal")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "futureThinking", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "futureThinking", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
        .onAppear {
            if scenes.isEmpty {
                isCreating = true
                pauseActive = true
            } else {
                shuffleScene()
            }
        }
        .onReceive(pauseTimer) { _ in
            guard pauseActive, pauseCountdown > 0 else { return }
            pauseCountdown -= 1
        }
    }

    // MARK: - View Mode

    private var viewModeView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            Text("A Postcard From Your Future")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            if let scene = displayedScene {
                postcardCard(scene: scene)
            }

            Spacer()

            HStack(spacing: AppStyle.spacing) {
                Button {
                    shuffleScene()
                } label: {
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Shuffle")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonCyan))

                Button {
                    isCreating = true
                    currentStep = 0
                    sceneDescription = ""
                    selectedEmoji = ""
                    pauseCountdown = 5
                    pauseActive = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Postcard")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
            }
            .padding(.horizontal, AppStyle.screenPadding)

            Button {
                showResistPopup = true
            } label: {
                Text("Done")
            }
            .buttonStyle(SecondaryButtonStyle(color: .subtleText))
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
    }

    private func postcardCard(scene: FutureScene) -> some View {
        VStack(spacing: AppStyle.spacing) {
            Text(scene.emoji)
                .font(.system(size: 60))

            Text(scene.description)
                .font(Typography.body)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            let formatter: DateFormatter = {
                let f = DateFormatter()
                f.dateStyle = .medium
                return f
            }()
            Text("Created \(formatter.string(from: scene.createdAt))")
                .font(Typography.caption)
                .foregroundColor(.subtleText.opacity(0.6))
        }
        .padding(AppStyle.largeSpacing)
        .rainbowCard()
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Create Mode

    private var createModeView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer().frame(height: 8)

            createProgressBar
            createStepDots

            Spacer()

            Group {
                switch currentStep {
                case 0:
                    imagineStep
                case 1:
                    describeStep
                case 2:
                    symbolizeStep
                default:
                    EmptyView()
                }
            }

            Spacer()

            createNavigationButtons

            Spacer().frame(height: 8)
        }
        .padding(.horizontal, AppStyle.screenPadding)
    }

    private var createProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.cardBackground)
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.neonCyan, .neonBlue, .neonPurple, .neonGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(currentStep + 1) / 3.0, height: 8)
                    .animation(.easeInOut(duration: 0.4), value: currentStep)
            }
        }
        .frame(height: 8)
    }

    private var createStepDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<3) { index in
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

    // MARK: - Steps

    private var imagineStep: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Text("IMAGINE")
                .font(Typography.headline)
                .foregroundColor(.neonCyan)

            ZStack {
                Circle()
                    .fill(Color.neonCyan.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseScale)

                Image(systemName: "hourglass")
                    .font(.system(size: 44))
                    .foregroundColor(.neonCyan)
                    .shadow(color: .neonCyan.opacity(0.5), radius: 8, x: 0, y: 0)
                    .scaleEffect(pulseScale)
            }
            .onAppear { startPulse() }

            Text("Close your eyes. Imagine yourself\n1 year from now, free and healthy.")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            if pauseCountdown > 0 {
                Text("Take a moment... \(pauseCountdown)s")
                    .font(Typography.body)
                    .foregroundColor(.subtleText)
            } else {
                Text("When you're ready, continue.")
                    .font(Typography.body)
                    .foregroundColor(.neonGreen)
            }
        }
    }

    private var describeStep: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("DESCRIBE")
                .font(Typography.headline)
                .foregroundColor(.neonBlue)

            Text("What do you see in your future?")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            TextEditor(text: $sceneDescription)
                .font(Typography.body)
                .foregroundColor(.appText)
                .onAppear { UITextView.appearance().backgroundColor = .clear }
                .padding(AppStyle.cardPadding)
                .frame(minHeight: 140)
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
                )

            Text("Describe what you see, hear, and feel.")
                .font(Typography.caption)
                .foregroundColor(.subtleText.opacity(0.7))
        }
    }

    private var symbolizeStep: some View {
        VStack(spacing: AppStyle.spacing) {
            Text("SYMBOLIZE")
                .font(Typography.headline)
                .foregroundColor(.neonPurple)

            Text("Pick an emoji that represents\nthis future")
                .font(Typography.title)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(emojiGrid, id: \.self) { emoji in
                    Button {
                        selectedEmoji = emoji
                    } label: {
                        Text(emoji)
                            .font(.system(size: 36))
                            .frame(width: 60, height: 60)
                            .background(selectedEmoji == emoji ? Color.neonPurple.opacity(0.25) : Color.cardBackground)
                            .cornerRadius(AppStyle.smallCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                                    .stroke(selectedEmoji == emoji ? Color.neonPurple : Color.cardBorder, lineWidth: selectedEmoji == emoji ? 2 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }

    // MARK: - Navigation

    private var createNavigationButtons: some View {
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
                    if currentStep < 2 {
                        currentStep += 1
                    } else {
                        saveScene()
                        isComplete = true
                        confettiVisible = true
                    }
                }
            } label: {
                HStack {
                    Text(currentStep < 2 ? "Next" : "Save Postcard")
                    if currentStep < 2 {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .buttonStyle(RainbowButtonStyle())
            .disabled(currentStep == 0 && pauseCountdown > 0)
            .opacity(currentStep == 0 && pauseCountdown > 0 ? 0.5 : 1.0)
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

            Text("Postcard Saved")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("Your future self is waiting for you.\nEvery moment of resistance brings you closer.")
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

    private func saveScene() {
        let scene = FutureScene(
            description: sceneDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: selectedEmoji.isEmpty ? "\u{1F31F}" : selectedEmoji,
            createdAt: Date()
        )
        var current = scenes
        current.append(scene)
        if let encoded = try? JSONEncoder().encode(current),
           let json = String(data: encoded, encoding: .utf8) {
            futureSceneData = json
        }
    }

    private func shuffleScene() {
        let allScenes = scenes
        guard !allScenes.isEmpty else { return }
        if allScenes.count == 1 {
            displayedScene = allScenes.first
        } else {
            var next = allScenes.randomElement()
            while next?.id == displayedScene?.id {
                next = allScenes.randomElement()
            }
            displayedScene = next
        }
    }

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

struct TimePortalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimePortalView()
        }
        .preferredColorScheme(.dark)
    }
}
