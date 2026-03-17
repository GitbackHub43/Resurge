import SwiftUI

// MARK: - Badge Unlock Manager

/// Manages a queue of newly unlocked badges and shows them one at a time.
final class BadgeUnlockManager: ObservableObject {
    static let shared = BadgeUnlockManager()

    @Published var currentBadge: MilestoneBadge?
    @Published var isShowing = false

    private var queue: [MilestoneBadge] = []

    private init() {}

    /// Add a badge to the unlock queue. Shows immediately if nothing is showing.
    func enqueue(_ badge: MilestoneBadge) {
        DispatchQueue.main.async {
            self.queue.append(badge)
            if !self.isShowing {
                self.showNext()
            }
        }
    }

    /// Add multiple badges at once.
    func enqueueAll(_ badges: [MilestoneBadge]) {
        for badge in badges {
            enqueue(badge)
        }
    }

    /// Called when user taps "Claim" — shows next badge or dismisses.
    func claim() {
        isShowing = false
        currentBadge = nil
        // Small delay before showing the next one
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.showNext()
        }
    }

    private func showNext() {
        guard !queue.isEmpty else { return }
        let next = queue.removeFirst()
        currentBadge = next
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isShowing = true
        }
    }
}

// MARK: - Badge Unlock Popup View

/// Full-screen overlay that shows a newly unlocked badge.
/// Add this to the root of the app (MainTabView).
struct BadgeUnlockPopupView: View {
    @ObservedObject var manager = BadgeUnlockManager.shared

    var body: some View {
        ZStack {
            if manager.isShowing, let badge = manager.currentBadge {
                // Dimmed background
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { } // Block taps behind

                // Popup card
                VStack(spacing: 20) {
                    // Title
                    Text("New Badge!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.neonGold)
                        .tracking(2)
                        .textCase(.uppercase)

                    // Badge emblem — large
                    BadgeEmblemView(badge: badge, isUnlocked: true, size: 100)
                        .shadow(color: .neonGold.opacity(0.4), radius: 20)

                    // Badge name
                    Text(badge.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    // Description
                    Text(badge.description)
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Claim button
                    Button {
                        HapticManager.tap()
                        manager.claim()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Claim")
                        }
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 16)
                .frame(maxWidth: 320)
                .background(Color.cardBackground)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: .neonPurple.opacity(0.3), radius: 30)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: manager.isShowing)
    }
}
