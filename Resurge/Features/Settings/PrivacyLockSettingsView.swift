import SwiftUI

struct PrivacyLockSettingsView: View {
    @EnvironmentObject var environment: AppEnvironment

    @AppStorage("biometricLockEnabled") private var biometricEnabled = false

    private var biometricTypeName: String {
        switch environment.biometricManager.biometricType() {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        case .none:    return "Biometrics"
        }
    }

    private var biometricIconName: String {
        switch environment.biometricManager.biometricType() {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .none:    return "lock.fill"
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            List {
                Section {
                    Toggle(isOn: $biometricEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: biometricIconName)
                                .font(.title2)
                                .foregroundColor(.neonCyan)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Require \(biometricTypeName)")
                                    .font(.body)
                                    .foregroundColor(.appText)
                                Text("Lock the app when you leave")
                                    .font(.caption)
                                    .foregroundColor(.subtleText)
                            }
                        }
                    }
                    .tint(.neonCyan)
                } footer: {
                    Text("When enabled, \(biometricTypeName) will be required each time you open Resurge. Your data stays private.")
                        .foregroundColor(.subtleText)
                }
                .listRowBackground(Color.cardBackground)

                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "shield.checkered")
                            .font(.title3)
                            .foregroundColor(.neonPurple)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Privacy Matters")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.appText)
                            Text("All your data is stored locally on your device. Biometric lock adds an extra layer of protection so that even if someone has your phone, they cannot access your recovery data.")
                                .font(.caption)
                                .foregroundColor(.subtleText)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.cardBackground)

                if !environment.biometricManager.canUseBiometrics() {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.neonOrange)
                            Text("Biometrics are not available on this device. Please enable Face ID or Touch ID in Settings.")
                                .font(.caption)
                                .foregroundColor(.subtleText)
                        }
                    }
                    .listRowBackground(Color.cardBackground)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Privacy Lock")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct PrivacyLockSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            PrivacyLockSettingsView()
                .environmentObject(env)
        }
    }
}
