import SwiftUI
import CoreData

@main
struct ResurgeApp: App {
    @StateObject private var environment = AppEnvironment()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @State private var isUnlocked = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if biometricLockEnabled && !isUnlocked {
                    BiometricLockScreen(onUnlock: { isUnlocked = true })
                        .environmentObject(environment)
                } else if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingContainerView(onComplete: {
                        hasCompletedOnboarding = true
                    })
                }
            }
            .environmentObject(environment)
            .environment(\.managedObjectContext, environment.viewContext)
            .preferredColorScheme(.dark)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    // Refresh entitlement status when app comes to foreground
                    environment.entitlementManager.refresh()

                    // Evaluate achievements for all active habits
                    let habitRequest = NSFetchRequest<CDHabit>(entityName: "CDHabit")
                    habitRequest.predicate = NSPredicate(format: "isActive == YES")
                    if let habits = try? environment.viewContext.fetch(habitRequest) {
                        for habit in habits {
                            environment.achievementService.evaluate(for: habit)
                        }
                    }

                    // Surges are awarded directly in each daily loop view (5+5+5=15/day)
                    // No backup award needed here
                }
            }
        }
    }
}

// MARK: - Biometric Lock Screen

struct BiometricLockScreen: View {
    @EnvironmentObject var environment: AppEnvironment
    let onUnlock: () -> Void

    @State private var authFailed = false
    @State private var glowOpacity: Double = 0.2

    private var biometricName: String {
        switch environment.biometricManager.biometricType() {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        case .none:    return "Passcode"
        }
    }

    private var biometricIcon: String {
        switch environment.biometricManager.biometricType() {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .none:    return "lock.fill"
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.neonCyan.opacity(glowOpacity))
                        .frame(width: 160, height: 160)
                        .blur(radius: 40)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                glowOpacity = 0.4
                            }
                        }

                    Image(systemName: biometricIcon)
                        .font(.system(size: 64))
                        .foregroundColor(.neonCyan)
                        .shadow(color: .neonCyan.opacity(0.5), radius: 8, x: 0, y: 0)
                }

                VStack(spacing: 8) {
                    Text("Resurge")
                        .font(Typography.largeTitle)
                        .foregroundColor(.textPrimary)

                    Text("Unlock with \(biometricName)")
                        .font(Typography.body)
                        .foregroundColor(.textSecondary)
                }

                if authFailed {
                    Text("Authentication failed. Tap to try again.")
                        .font(Typography.caption)
                        .foregroundColor(.neonOrange)
                }

                Button {
                    authenticate()
                } label: {
                    Text("Unlock")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 60)

                Spacer()
            }
        }
        .onAppear {
            authenticate()
        }
    }

    private func authenticate() {
        Task {
            let success = await environment.biometricManager.authenticate()
            await MainActor.run {
                if success {
                    onUnlock()
                } else {
                    authFailed = true
                }
            }
        }
    }
}
