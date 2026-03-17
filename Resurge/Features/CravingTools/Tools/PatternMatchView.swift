import SwiftUI

struct PatternMatchCard: Identifiable, Equatable {
    let id = UUID()
    let symbolName: String
    var isFaceUp = false
    var isMatched = false
}

struct PatternMatchView: View {
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage("patternMatchBestMoves") private var bestMoves: Int = 0

    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var columns: Int {
            switch self {
            case .easy: return 3
            case .medium: return 4
            case .hard: return 4
            }
        }

        var rows: Int {
            switch self {
            case .easy: return 2
            case .medium: return 3
            case .hard: return 4
            }
        }

        var pairCount: Int { (columns * rows) / 2 }
    }

    private let allSymbols = [
        "heart.fill", "star.fill", "moon.fill", "leaf.fill", "flame.fill", "bolt.fill",
        "diamond.fill", "drop.fill"
    ]

    private let symbolColors: [String: Color] = [
        "heart.fill": .neonMagenta,
        "star.fill": .neonGold,
        "moon.fill": .neonPurple,
        "leaf.fill": .neonGreen,
        "flame.fill": .neonOrange,
        "bolt.fill": .neonCyan,
        "diamond.fill": .neonBlue,
        "drop.fill": .neonCyan
    ]

    private let rainbowColors: [Color] = [
        .neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold
    ]

    @State private var difficulty: Difficulty = .medium
    @State private var cards: [PatternMatchCard] = []
    @State private var firstFlippedIndex: Int? = nil
    @State private var secondFlippedIndex: Int? = nil
    @State private var moves = 0
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?
    @State private var gameStarted = false
    @State private var gameComplete = false
    @State private var isProcessing = false
    @State private var trophyScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if gameComplete {
                completionView
            } else if !gameStarted {
                difficultyPicker
            } else {
                gameView
            }
        }
        .navigationTitle("Pattern Match")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Difficulty Picker

    private var difficultyPicker: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 56))
                .foregroundColor(.neonGold)

            Text("Pattern Match")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("Train your focus by matching pairs")
                .font(Typography.body)
                .foregroundColor(.subtleText)

            VStack(spacing: 12) {
                ForEach(Difficulty.allCases, id: \.rawValue) { diff in
                    Button {
                        difficulty = diff
                        startGame()
                    } label: {
                        HStack {
                            Text(diff.rawValue)
                            Spacer()
                            Text("\(diff.columns)x\(diff.rows) (\(diff.pairCount) pairs)")
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(color: difficultyColor(for: diff)))
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)

            if bestMoves > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(Typography.caption)
                        .foregroundColor(.neonGold)
                    Text("Best: \(bestMoves) moves")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: 20) {
            // Stats
            HStack(spacing: 24) {
                statBadge(icon: "hand.tap.fill", value: "\(moves)", label: "Moves", color: .neonCyan)
                statBadge(icon: "clock.fill", value: formattedTime, label: "Time", color: .neonPurple)
                statBadge(icon: "checkmark.circle.fill", value: "\(matchedCount)/\(difficulty.pairCount)", label: "Matched", color: .neonGreen)
            }
            .padding(.horizontal)

            // Card Grid
            let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: difficulty.columns)

            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    cardView(card: card, index: index)
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer()
        }
        .padding(.top)
    }

    // MARK: - Card View

    private func cardView(card: PatternMatchCard, index: Int) -> some View {
        Button {
            cardTapped(index: index)
        } label: {
            ZStack {
                if card.isFaceUp || card.isMatched {
                    // Face up
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    (symbolColors[card.symbolName] ?? .neonCyan).opacity(0.6),
                                    lineWidth: 2
                                )
                        )

                    Image(systemName: card.symbolName)
                        .font(.system(size: cardIconSize))
                        .foregroundColor(symbolColors[card.symbolName] ?? .neonCyan)
                        .shadow(color: (symbolColors[card.symbolName] ?? .neonCyan).opacity(0.5), radius: 4)
                } else {
                    // Face down — rainbow back
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: rainbowColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "questionmark")
                                .font(.system(size: cardIconSize * 0.6).weight(.bold))
                                .foregroundColor(.white.opacity(0.4))
                        )
                }
            }
            .frame(height: cardHeight)
            .opacity(card.isMatched ? 0.5 : 1.0)
        }
        .disabled(card.isFaceUp || card.isMatched || isProcessing)
        .buttonStyle(.plain)
    }

    // MARK: - Completion View

    private var completionView: some View {
        ZStack {
            SparkleParticlesView(count: 30)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("All Matched!")
                    .font(Typography.largeTitle)
                    .rainbowText()

                ZStack {
                    Circle()
                        .fill(Color.neonGold.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.neonGold)
                        .shadow(color: .neonGold.opacity(0.6), radius: 12)
                }
                .scaleEffect(trophyScale)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                        trophyScale = 1.0
                    }
                }

                VStack(spacing: 8) {
                    Text("\(moves) moves")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.neonCyan)

                    Text("Completed in \(formattedTime)")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)

                    if bestMoves == 0 || moves < bestMoves {
                        Text("New Best!")
                            .font(Typography.headline)
                            .foregroundColor(.neonGold)
                            .padding(.top, 4)
                    }
                }

                Text(difficulty.rawValue)
                    .font(Typography.badge)
                    .foregroundColor(.neonPurple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.neonPurple.opacity(0.15))
                    .cornerRadius(8)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        resetGame()
                    } label: {
                        Text("Play Again")
                    }
                    .buttonStyle(RainbowButtonStyle())

                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Helpers

    private var cardHeight: CGFloat {
        switch difficulty {
        case .easy: return 100
        case .medium: return 85
        case .hard: return 72
        }
    }

    private var cardIconSize: CGFloat {
        switch difficulty {
        case .easy: return 32
        case .medium: return 26
        case .hard: return 22
        }
    }

    private var matchedCount: Int {
        cards.filter { $0.isMatched }.count / 2
    }

    private var formattedTime: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func startGame() {
        let symbols = Array(allSymbols.prefix(difficulty.pairCount))
        let paired = (symbols + symbols).shuffled()
        cards = paired.map { PatternMatchCard(symbolName: $0) }
        moves = 0
        elapsedSeconds = 0
        gameStarted = true
        gameComplete = false
        trophyScale = 0.5

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func cardTapped(index: Int) {
        guard !cards[index].isFaceUp, !cards[index].isMatched else { return }

        cards[index].isFaceUp = true

        if firstFlippedIndex == nil {
            firstFlippedIndex = index
        } else if secondFlippedIndex == nil {
            secondFlippedIndex = index
            moves += 1
            isProcessing = true

            let first = firstFlippedIndex!
            let second = index

            if cards[first].symbolName == cards[second].symbolName {
                // Match
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cards[first].isMatched = true
                    cards[second].isMatched = true
                    firstFlippedIndex = nil
                    secondFlippedIndex = nil
                    isProcessing = false

                    // Check completion
                    if cards.allSatisfy({ $0.isMatched }) {
                        timer?.invalidate()
                        if bestMoves == 0 || moves < bestMoves {
                            bestMoves = moves
                        }
                        gameComplete = true
                    }
                }
            } else {
                // No match — flip back
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    cards[first].isFaceUp = false
                    cards[second].isFaceUp = false
                    firstFlippedIndex = nil
                    secondFlippedIndex = nil
                    isProcessing = false
                }
            }
        }
    }

    private func resetGame() {
        timer?.invalidate()
        gameStarted = false
        gameComplete = false
        cards = []
        firstFlippedIndex = nil
        secondFlippedIndex = nil
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(Typography.body)
                .foregroundColor(color)
            Text(value)
                .font(Typography.headline)
                .foregroundColor(.appText)
            Text(label)
                .font(Typography.caption)
                .foregroundColor(.subtleText)
        }
        .frame(maxWidth: .infinity)
    }

    private func difficultyColor(for diff: Difficulty) -> Color {
        switch diff {
        case .easy: return .neonGreen
        case .medium: return .neonCyan
        case .hard: return .neonMagenta
        }
    }
}

// MARK: - Preview

struct PatternMatchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatternMatchView()
        }
    }
}
