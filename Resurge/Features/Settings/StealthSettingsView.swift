import SwiftUI

struct StealthSettingsView: View {
    @AppStorage("stealth_notifications") private var stealthNotifications = false
    @AppStorage("stealth_app_name") private var stealthAppName = false
    @AppStorage("quick_hide_enabled") private var quickHideEnabled = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            List {
                // MARK: - Notification Privacy

                Section {
                    VStack(alignment: .leading, spacing: AppStyle.spacing) {
                        Toggle(isOn: $stealthNotifications) {
                            HStack(spacing: AppStyle.spacing) {
                                Image(systemName: "bell.slash.fill")
                                    .font(.title3)
                                    .foregroundColor(.primaryTeal)
                                    .frame(width: AppStyle.iconSize)
                                Text("Redact Notification Content")
                                    .font(Typography.body)
                                    .foregroundColor(.appText)
                            }
                        }
                        .tint(.primaryTeal)

                        Text("Notifications will show 'Reminder' instead of habit-specific text.")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Notification Privacy")
                        .font(Typography.headline)
                        .foregroundColor(.appText)
                        .textCase(nil)
                }
                .listRowBackground(Color.cardBackground)

                // MARK: - Quick Hide

                Section {
                    VStack(alignment: .leading, spacing: AppStyle.spacing) {
                        Toggle(isOn: $quickHideEnabled) {
                            HStack(spacing: AppStyle.spacing) {
                                Image(systemName: "eye.slash.fill")
                                    .font(.title3)
                                    .foregroundColor(.primaryTeal)
                                    .frame(width: AppStyle.iconSize)
                                Text("Enable Quick Hide")
                                    .font(Typography.body)
                                    .foregroundColor(.appText)
                            }
                        }
                        .tint(.primaryTeal)

                        Text("Triple-tap anywhere to instantly return to home screen.")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Quick Hide")
                        .font(Typography.headline)
                        .foregroundColor(.appText)
                        .textCase(nil)
                }
                .listRowBackground(Color.cardBackground)

            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Stealth Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct StealthSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StealthSettingsView()
        }
    }
}
