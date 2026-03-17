import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var environment: AppEnvironment

    @AppStorage("dailyLoopEnabled") private var dailyLoopEnabled = true
    @AppStorage("dailyQuoteEnabled") private var dailyQuoteEnabled = true
    @AppStorage("quoteSlot1Hour") private var quoteSlot1Hour = 8
    @AppStorage("quoteSlot1Minute") private var quoteSlot1Minute = 0
    @AppStorage("quoteSlot2Hour") private var quoteSlot2Hour = 12
    @AppStorage("quoteSlot2Minute") private var quoteSlot2Minute = 0
    @AppStorage("quoteSlot3Hour") private var quoteSlot3Hour = 17
    @AppStorage("quoteSlot3Minute") private var quoteSlot3Minute = 0
    @AppStorage("quoteSlot4Hour") private var quoteSlot4Hour = 21
    @AppStorage("quoteSlot4Minute") private var quoteSlot4Minute = 0
    @AppStorage("quoteSlot5Hour") private var quoteSlot5Hour = 14
    @AppStorage("quoteSlot5Minute") private var quoteSlot5Minute = 0

    @State private var quoteTime1 = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @State private var quoteTime2 = Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
    @State private var quoteTime3 = Calendar.current.date(from: DateComponents(hour: 17, minute: 0)) ?? Date()
    @State private var quoteTime4 = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    @State private var quoteTime5 = Calendar.current.date(from: DateComponents(hour: 14, minute: 0)) ?? Date()

    @State private var notificationPermissionDenied = false

    private var isPremium: Bool {
        environment.entitlementManager.isPremium
    }

    private var settingsViewModel: SettingsViewModel {
        SettingsViewModel(
            notificationManager: environment.notificationManager,
            biometricManager: environment.biometricManager
        )
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            List {
                // MARK: - Permission Denied Banner
                if notificationPermissionDenied {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.slash.fill")
                                .foregroundColor(.neonOrange)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notifications Disabled")
                                    .font(Font.subheadline.weight(.bold))
                                    .foregroundColor(.textPrimary)
                                Text("Enable notifications in Settings to receive reminders.")
                                    .font(Font.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            Spacer()
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(Font.caption.weight(.bold))
                            .foregroundColor(.neonCyan)
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.neonOrange.opacity(0.1))
                }

                // MARK: - Daily Loop Reminders
                Section {
                    Toggle(isOn: $dailyLoopEnabled) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.neonCyan)
                            Text("Daily Loop Reminders")
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .tint(.neonCyan)

                    if dailyLoopEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            notificationTimeRow("Morning Plan/Review",
                                                hour: UserDefaults.standard.integer(forKey: "wakeUpHour"),
                                                icon: "sunrise.fill",
                                                color: .neonGold)
                            notificationTimeRow("Afternoon Check-In",
                                                hour: UserDefaults.standard.integer(forKey: "afternoonHour"),
                                                icon: "sun.max.fill",
                                                color: .neonOrange)
                            notificationTimeRow("Evening Review/Reflection",
                                                hour: UserDefaults.standard.integer(forKey: "eveningHour"),
                                                icon: "moon.fill",
                                                color: .neonPurple)
                        }

                        Text("Reminders will include your habit name for each active habit.")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)
                    }
                } header: {
                    Text("Daily Loop")
                } footer: {
                    Text("Three reminders per day based on your wake time, 8 hours apart.")
                        .foregroundColor(.textSecondary)
                }
                .listRowBackground(Color.cardBackground)

                // MARK: - Motivational Quotes
                Section {
                    Toggle(isOn: $dailyQuoteEnabled) {
                        HStack(spacing: 10) {
                            Image(systemName: "quote.bubble.fill")
                                .foregroundColor(.neonGold)
                            Text("Motivational Boosts")
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .tint(.neonCyan)

                    if dailyQuoteEnabled {
                        quoteTimeRow(label: "Morning", time: $quoteTime1, locked: false)

                        quoteTimeRow(label: "Midday", time: $quoteTime2, locked: !isPremium)
                        quoteTimeRow(label: "Afternoon", time: $quoteTime3, locked: !isPremium)
                        quoteTimeRow(label: "Evening", time: $quoteTime4, locked: !isPremium)
                        quoteTimeRow(label: "Night", time: $quoteTime5, locked: !isPremium)
                    }
                } footer: {
                    if isPremium {
                        Text("You get 5 daily motivational quotes tailored to your recovery.")
                            .foregroundColor(.textSecondary)
                    } else {
                        Text("Free: 1 daily quote. Upgrade to Premium for 5 daily quotes.")
                            .foregroundColor(.textSecondary)
                    }
                }
                .listRowBackground(Color.cardBackground)
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkNotificationPermission()
            quoteTime1 = Calendar.current.date(from: DateComponents(hour: quoteSlot1Hour, minute: quoteSlot1Minute)) ?? Date()
            quoteTime2 = Calendar.current.date(from: DateComponents(hour: quoteSlot2Hour, minute: quoteSlot2Minute)) ?? Date()
            quoteTime3 = Calendar.current.date(from: DateComponents(hour: quoteSlot3Hour, minute: quoteSlot3Minute)) ?? Date()
            quoteTime4 = Calendar.current.date(from: DateComponents(hour: quoteSlot4Hour, minute: quoteSlot4Minute)) ?? Date()
            quoteTime5 = Calendar.current.date(from: DateComponents(hour: quoteSlot5Hour, minute: quoteSlot5Minute)) ?? Date()
        }
        .onChange(of: dailyQuoteEnabled) { newValue in
            if newValue {
                ensurePermissionThenScheduleQuotes()
            } else {
                scheduleQuoteNotifications()
            }
        }
        .onChange(of: dailyLoopEnabled) { newValue in
            if newValue {
                ensurePermissionThenScheduleDailyLoop()
            }
        }
        .onChange(of: quoteTime1) { newValue in
            let cal = Calendar.current
            quoteSlot1Hour = cal.component(.hour, from: newValue)
            quoteSlot1Minute = cal.component(.minute, from: newValue)
            ensurePermissionThenScheduleQuotes()
        }
        .onChange(of: quoteTime2) { newValue in
            let cal = Calendar.current
            quoteSlot2Hour = cal.component(.hour, from: newValue)
            quoteSlot2Minute = cal.component(.minute, from: newValue)
            ensurePermissionThenScheduleQuotes()
        }
        .onChange(of: quoteTime3) { newValue in
            let cal = Calendar.current
            quoteSlot3Hour = cal.component(.hour, from: newValue)
            quoteSlot3Minute = cal.component(.minute, from: newValue)
            ensurePermissionThenScheduleQuotes()
        }
        .onChange(of: quoteTime4) { newValue in
            let cal = Calendar.current
            quoteSlot4Hour = cal.component(.hour, from: newValue)
            quoteSlot4Minute = cal.component(.minute, from: newValue)
            ensurePermissionThenScheduleQuotes()
        }
        .onChange(of: quoteTime5) { newValue in
            let cal = Calendar.current
            quoteSlot5Hour = cal.component(.hour, from: newValue)
            quoteSlot5Minute = cal.component(.minute, from: newValue)
            ensurePermissionThenScheduleQuotes()
        }
    }

    // MARK: - Permission Handling

    private func checkNotificationPermission() {
        environment.notificationManager.checkAuthorizationStatus { status in
            notificationPermissionDenied = (status == .denied)
        }
    }

    private func ensurePermissionThenScheduleQuotes() {
        environment.notificationManager.requestPermissionIfNeeded { granted in
            notificationPermissionDenied = !granted
            if granted {
                scheduleQuoteNotifications()
            }
        }
    }

    private func ensurePermissionThenScheduleDailyLoop() {
        environment.notificationManager.requestPermissionIfNeeded { granted in
            notificationPermissionDenied = !granted
        }
    }

    private func scheduleQuoteNotifications() {
        settingsViewModel.updateQuoteNotifications(isPremium: isPremium)
    }

    // MARK: - Notification Time Row

    private func notificationTimeRow(_ title: String, hour: Int, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(color)
            Text(title).font(Typography.body).foregroundColor(.textPrimary)
            Spacer()
            Text(formatHour(hour)).font(Typography.caption).foregroundColor(.subtleText)
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour >= 12 ? "PM" : "AM"
        return "\(h):00 \(ampm)"
    }

    // MARK: - Quote Time Row

    @ViewBuilder
    private func quoteTimeRow(label: String, time: Binding<Date>, locked: Bool) -> some View {
        if locked {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.neonGold)
                    .font(.caption)
                Text(label)
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("Premium")
                    .font(Typography.badge)
                    .foregroundColor(.neonGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.neonGold.opacity(0.15))
                    .cornerRadius(6)
            }
        } else {
            DatePicker(
                label,
                selection: time,
                displayedComponents: .hourAndMinute
            )
            .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Preview

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            NotificationSettingsView()
                .environmentObject(env)
        }
    }
}
