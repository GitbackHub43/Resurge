import SwiftUI

struct PuzzleGameView: View {
    @AppStorage("isPremium") private var isPremium = false
    @State private var showPremiumGate = false
    @State private var gatedFeatureName = ""
    @State private var gatedFeatureDescription = ""

    private let rainbowColors: [Color] = [
        .neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Choose a puzzle to distract your mind")
                        .font(.subheadline)
                        .foregroundColor(.subtleText)
                        .padding(.top, 4)

                    LazyVGrid(columns: columns, spacing: 14) {
                        // Word Scramble — FREE
                        NavigationLink {
                            WordScrambleView()
                        } label: {
                            gameCard(
                                icon: "textformat.abc",
                                title: "Word Scramble",
                                description: "Unscramble recovery-themed words",
                                accentColor: .neonCyan,
                                tag: "FREE",
                                tagColor: .neonCyan,
                                isLocked: false
                            )
                        }

                        // Number Puzzle — PREMIUM
                        if isPremium {
                            NavigationLink {
                                NumberPuzzleView()
                            } label: {
                                gameCard(
                                    icon: "number.square.fill",
                                    title: "Number Puzzle",
                                    description: "Solve number challenges",
                                    accentColor: .neonPurple,
                                    tag: "PREMIUM",
                                    tagColor: .neonPurple,
                                    isLocked: false
                                )
                            }
                        } else {
                            Button {
                                gatedFeatureName = "Number Puzzle"
                                gatedFeatureDescription = "Challenge your brain with number-based puzzles to redirect cravings."
                                showPremiumGate = true
                            } label: {
                                gameCard(
                                    icon: "number.square.fill",
                                    title: "Number Puzzle",
                                    description: "Solve number challenges",
                                    accentColor: .neonPurple,
                                    tag: "PREMIUM",
                                    tagColor: .neonPurple,
                                    isLocked: true
                                )
                            }
                        }

                        // Pattern Match — PREMIUM
                        if isPremium {
                            NavigationLink {
                                PatternMatchView()
                            } label: {
                                gameCard(
                                    icon: "square.grid.3x3.fill",
                                    title: "Pattern Match",
                                    description: "Match visual patterns",
                                    accentColor: .neonGold,
                                    tag: "PREMIUM",
                                    tagColor: .neonGold,
                                    isLocked: false
                                )
                            }
                        } else {
                            Button {
                                gatedFeatureName = "Pattern Match"
                                gatedFeatureDescription = "Train your visual memory with pattern matching to redirect your focus."
                                showPremiumGate = true
                            } label: {
                                gameCard(
                                    icon: "square.grid.3x3.fill",
                                    title: "Pattern Match",
                                    description: "Match visual patterns",
                                    accentColor: .neonGold,
                                    tag: "PREMIUM",
                                    tagColor: .neonGold,
                                    isLocked: true
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }

            // Premium gate overlay
            if showPremiumGate {
                PremiumGateView(
                    featureName: gatedFeatureName,
                    featureDescription: gatedFeatureDescription,
                    onUnlock: {
                        showPremiumGate = false
                    },
                    onDismiss: {
                        showPremiumGate = false
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showPremiumGate)
            }
        }
        .navigationTitle("Puzzle Games")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Game Card

    private func gameCard(
        icon: String,
        title: String,
        description: String,
        accentColor: Color,
        tag: String,
        tagColor: Color,
        isLocked: Bool
    ) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 56, height: 56)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(accentColor.opacity(0.6))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(accentColor)
                }
            }

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(description)
                .font(.caption2)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            // Tag
            Text(tag)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(tag == "FREE" ? .appBackground : tagColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(tag == "FREE" ? tagColor : tagColor.opacity(0.2))
                .cornerRadius(4)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: rainbowColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .opacity(isLocked ? 0.2 : 0.4)
        )
        .shadow(color: accentColor.opacity(isLocked ? 0.06 : 0.12), radius: 12)
        .opacity(isLocked ? 0.75 : 1.0)
    }
}

// MARK: - Preview

struct PuzzleGameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PuzzleGameView()
                .environmentObject(AppEnvironment.preview)
        }
    }
}
