import SwiftUI
import CoreData

struct ApproachBiasSwipeView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("biasSwipeHighScore") private var highScore: Int = 0

    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var bestStreak: Int = 0
    @State private var timeRemaining: Int = 180
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var showResistPopup = false
    @State private var didResistResult: Bool? = nil

    // Card state
    @State private var currentCard: BiasCard?
    @State private var dragOffset: CGSize = .zero
    @State private var cardOpacity: Double = 1.0
    @State private var shakeOffset: CGFloat = 0
    @State private var flashColor: Color = .clear
    @State private var flashOpacity: Double = 0

    private let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let triggerCards: [BiasCard] = [
        BiasCard(icon: "smoke.fill", isTrigger: true),
        BiasCard(icon: "wineglass.fill", isTrigger: true),
        BiasCard(icon: "dice.fill", isTrigger: true),
        BiasCard(icon: "cart.fill", isTrigger: true),
        BiasCard(icon: "gamecontroller.fill", isTrigger: true),
        BiasCard(icon: "iphone", isTrigger: true)
    ]

    private let positiveCards: [BiasCard] = [
        BiasCard(icon: "heart.fill", isTrigger: false),
        BiasCard(icon: "figure.run", isTrigger: false),
        BiasCard(icon: "lungs.fill", isTrigger: false),
        BiasCard(icon: "brain.head.profile", isTrigger: false),
        BiasCard(icon: "sun.max.fill", isTrigger: false),
        BiasCard(icon: "leaf.fill", isTrigger: false)
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            // Flash overlay
            flashColor
                .ignoresSafeArea()
                .opacity(flashOpacity)
                .allowsHitTesting(false)

            if isComplete {
                completionView
            } else {
                gameView
            }
        }
        .navigationTitle("Approach Bias")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Did this help?", isPresented: $showResistPopup) {
            Button("Yes, I resisted") {
                trackToolCompletion(toolId: "biasTraining", didResist: true, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
            Button("No, I gave in") {
                trackToolCompletion(toolId: "biasTraining", didResist: false, context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Did completing this tool help you resist your craving?")
        }
        .onAppear { nextCard() }
        .onReceive(gameTimer) { _ in
            guard !isComplete, timeRemaining > 0 else { return }
            timeRemaining -= 1
            if timeRemaining <= 0 {
                finishGame()
            }
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: AppStyle.spacing) {
            Spacer().frame(height: 8)

            // Timer bar
            timerBar

            // Score + Streak
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                    Text("\(score)")
                        .font(Typography.statValue)
                        .foregroundColor(.neonCyan)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("STREAK")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                    Text("\(streak)")
                        .font(Typography.statValue)
                        .foregroundColor(.neonGold)
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            // Instructions
            HStack(spacing: AppStyle.largeSpacing) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.neonGreen)
                    Text("Pull good")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }

                VStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.neonMagenta)
                    Text("Push bad")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
            }

            Spacer().frame(height: AppStyle.spacing)

            // Card
            if let card = currentCard {
                cardView(card: card)
            }

            Spacer()

            // Timer text
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
            Text(String(format: "%d:%02d", minutes, seconds))
                .font(Typography.timer)
                .foregroundColor(.appText)
                .opacity(0.5)

            Spacer().frame(height: AppStyle.largeSpacing)
        }
    }

    // MARK: - Timer Bar

    private var timerBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.cardBackground)
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: timeRemaining < 30 ? [.neonOrange, .neonMagenta] : [.neonCyan, .neonBlue, .neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(timeRemaining) / 180.0, height: 6)
                    .animation(.linear(duration: 1), value: timeRemaining)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, AppStyle.screenPadding)
    }

    // MARK: - Card View

    private func cardView(card: BiasCard) -> some View {
        let tintColor: Color = card.isTrigger ? .neonMagenta : .neonGreen

        return ZStack {
            Circle()
                .fill(tintColor.opacity(0.12))
                .frame(width: 160, height: 160)

            Circle()
                .stroke(tintColor.opacity(0.3), lineWidth: 2)
                .frame(width: 160, height: 160)

            Image(systemName: card.icon)
                .font(.system(size: 80))
                .foregroundColor(tintColor)
                .shadow(color: tintColor.opacity(0.5), radius: 12, x: 0, y: 0)
        }
        .offset(x: shakeOffset, y: dragOffset.height)
        .opacity(cardOpacity)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = CGSize(width: 0, height: value.translation.height)
                }
                .onEnded { value in
                    handleSwipe(translation: value.translation.height, card: card)
                }
        )
    }

    // MARK: - Swipe Logic

    private func handleSwipe(translation: CGFloat, card: BiasCard) {
        let swipedDown = translation > 100
        let swipedUp = translation < -100

        guard swipedDown || swipedUp else {
            // Not enough movement, snap back
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dragOffset = .zero
            }
            return
        }

        let isCorrect: Bool
        if card.isTrigger {
            isCorrect = swipedDown // Push away
        } else {
            isCorrect = swipedUp // Pull toward
        }

        if isCorrect {
            score += 10
            streak += 1
            if streak > bestStreak { bestStreak = streak }

            // Green flash
            flashColor = .neonGreen
            withAnimation(.easeOut(duration: 0.15)) { flashOpacity = 0.2 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.2)) { flashOpacity = 0 }
            }

            // Fly off
            withAnimation(.easeIn(duration: 0.2)) {
                dragOffset = CGSize(width: 0, height: swipedUp ? -600 : 600)
                cardOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                nextCard()
            }
        } else {
            score = max(0, score - 5)
            streak = 0

            // Red flash
            flashColor = .neonMagenta
            withAnimation(.easeOut(duration: 0.15)) { flashOpacity = 0.2 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.2)) { flashOpacity = 0 }
            }

            // Shake animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dragOffset = .zero
            }
            shakeCard()
        }
    }

    private func shakeCard() {
        let shakeSequence: [(CGFloat, Double)] = [
            (10, 0.05), (-10, 0.1), (8, 0.15), (-8, 0.2), (4, 0.25), (0, 0.3)
        ]
        for (offset, delay) in shakeSequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: 0.05)) {
                    shakeOffset = offset
                }
            }
        }
    }

    private func nextCard() {
        dragOffset = .zero
        cardOpacity = 1.0
        shakeOffset = 0

        let allCards = triggerCards + positiveCards
        currentCard = allCards.randomElement()
    }

    private func finishGame() {
        if score > highScore {
            highScore = score
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isComplete = true
            confettiVisible = true
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

            Text("Game Over!")
                .font(Typography.largeTitle)
                .rainbowText()

            // Stats
            VStack(spacing: AppStyle.spacing) {
                statRow(label: "Score", value: "\(score)", color: .neonCyan)
                statRow(label: "Best Streak", value: "\(bestStreak)", color: .neonGold)
                statRow(label: "High Score", value: "\(highScore)", color: .neonPurple)

                if score >= highScore && score > 0 {
                    Text("New High Score!")
                        .font(Typography.headline)
                        .foregroundColor(.neonGold)
                        .shadow(color: .neonGold.opacity(0.5), radius: 8, x: 0, y: 0)
                }
            }
            .rainbowCard()
            .padding(.horizontal, AppStyle.screenPadding)

            Text("You're retraining your brain to push away triggers\nand embrace what's good for you.")
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

    private func statRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(Typography.body)
                .foregroundColor(.subtleText)
            Spacer()
            Text(value)
                .font(Typography.title)
                .foregroundColor(color)
        }
    }
}

// MARK: - Bias Card Model

private struct BiasCard: Identifiable {
    let id = UUID()
    let icon: String
    let isTrigger: Bool
}

struct ApproachBiasSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ApproachBiasSwipeView()
        }
        .preferredColorScheme(.dark)
    }
}
