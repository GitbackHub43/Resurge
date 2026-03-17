import SwiftUI
import LocalAuthentication

struct ModuleLockSettingsView: View {
    @AppStorage("lock_journal") private var lockJournal = false
    @AppStorage("lock_cravings") private var lockCravings = false
    @AppStorage("lock_analytics") private var lockAnalytics = false
    @AppStorage("lock_community") private var lockCommunity = false
    @AppStorage("lock_companion") private var lockCompanion = false

    @State private var biometricsAvailable = false

    private let modules: [(key: String, name: String, icon: String)] = [
        ("journal", "Journal", "book.fill"),
        ("cravings", "Cravings", "flame.fill"),
        ("analytics", "Analytics", "chart.bar.fill"),
        ("community", "Community", "person.3.fill"),
        ("companion", "Companion", "heart.fill")
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            List {
                if !biometricsAvailable {
                    Section {
                        HStack(spacing: AppStyle.spacing) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.accentOrange)
                            Text("Biometric authentication is not available on this device.")
                                .font(Typography.caption)
                                .foregroundColor(.subtleText)
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.cardBackground)
                }

                Section {
                    moduleLockRow(
                        icon: "book.fill",
                        name: "Journal",
                        isOn: $lockJournal
                    )
                    moduleLockRow(
                        icon: "flame.fill",
                        name: "Cravings",
                        isOn: $lockCravings
                    )
                    moduleLockRow(
                        icon: "chart.bar.fill",
                        name: "Analytics",
                        isOn: $lockAnalytics
                    )
                    moduleLockRow(
                        icon: "person.3.fill",
                        name: "Community",
                        isOn: $lockCommunity
                    )
                    moduleLockRow(
                        icon: "heart.fill",
                        name: "Companion",
                        isOn: $lockCompanion
                    )
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Module Locks")
                            .font(Typography.headline)
                            .foregroundColor(.appText)
                        Text("Require Face ID or Touch Code to access specific features.")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }
                    .textCase(nil)
                    .padding(.bottom, 4)
                }
                .listRowBackground(Color.cardBackground)
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Privacy Locks")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkBiometricAvailability()
        }
    }

    // MARK: - Module Lock Row

    private func moduleLockRow(icon: String, name: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: AppStyle.spacing) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryTeal)
                .frame(width: AppStyle.iconSize)
            Text(name)
                .font(Typography.body)
                .foregroundColor(.appText)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.primaryTeal)
                .disabled(!biometricsAvailable)
        }
    }

    // MARK: - Biometric Check

    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        biometricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}

// MARK: - Preview

struct ModuleLockSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ModuleLockSettingsView()
        }
    }
}
