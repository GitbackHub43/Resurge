import SwiftUI

struct RestorePurchasesView: View {
    @EnvironmentObject var environment: AppEnvironment

    enum RestoreStatus {
        case idle
        case restoring
        case success
        case noSubscription
        case error(String)
    }

    @State private var status: RestoreStatus = .idle

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // MARK: - Icon
                Group {
                    switch status {
                    case .idle:
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.neonPurple)
                    case .restoring:
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .neonCyan))
                    case .success:
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.green)
                    case .noSubscription:
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.neonOrange)
                    case .error:
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.neonMagenta)
                    }
                }

                // MARK: - Status Text
                Group {
                    switch status {
                    case .idle:
                        VStack(spacing: 8) {
                            Text("Restore Purchases")
                                .font(.title2.weight(.bold))
                                .rainbowText()
                            Text("If you have previously purchased a subscription, you can restore it here.")
                                .font(.subheadline)
                                .foregroundColor(.subtleText)
                                .multilineTextAlignment(.center)
                        }
                    case .restoring:
                        Text("Restoring...")
                            .font(.title3)
                            .foregroundColor(.subtleText)
                    case .success:
                        VStack(spacing: 8) {
                            Text("Restored!")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.appText)
                            Text("Your premium subscription has been restored successfully.")
                                .font(.subheadline)
                                .foregroundColor(.subtleText)
                                .multilineTextAlignment(.center)
                        }
                    case .noSubscription:
                        VStack(spacing: 8) {
                            Text("No Subscription Found")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.appText)
                            Text("No active subscription was found for your account. You can subscribe from the Subscription page.")
                                .font(.subheadline)
                                .foregroundColor(.subtleText)
                                .multilineTextAlignment(.center)
                        }
                    case .error(let message):
                        VStack(spacing: 8) {
                            Text("Error")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.appText)
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(.subtleText)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                // MARK: - Restore Button
                Button {
                    restore()
                } label: {
                    Text("Restore Purchases")
                }
                .buttonStyle(RainbowButtonStyle())
                .padding(.horizontal)
                .disabled(isRestoring)

                // MARK: - Help
                Text("If you continue to have issues, contact support at support@resurgeapp.com")
                    .font(.caption)
                    .foregroundColor(.subtleText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
            }
        }
        .navigationTitle("Restore Purchases")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isRestoring: Bool {
        if case .restoring = status { return true }
        return false
    }

    private func restore() {
        status = .restoring
        Task {
            await environment.entitlementManager.restorePurchases()
            if environment.entitlementManager.isPremium {
                status = .success
            } else {
                status = .noSubscription
            }
        }
    }
}

// MARK: - Preview

struct RestorePurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            RestorePurchasesView()
                .environmentObject(env)
        }
    }
}
