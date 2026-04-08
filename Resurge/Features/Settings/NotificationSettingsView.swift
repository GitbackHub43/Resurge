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

    @State private var quoteTime1 = Calendar.current.date(from: DateComponents(hour: (UserDefaults.standard.integer(forKey: "wakeUpHour") > 0 ? UserDefaults.standard.integer(forKey: "wakeUpHour") : 7) + 1, minute: 0)) ?? Date()
    @State private var quoteTime2 = Calendar.current.date(from: DateComponents(hour: (UserDefaults.standard.integer(forKey: "wakeUpHour") > 0 ? UserDefaults.standard.integer(forKey: "wakeUpHour") : 7) + 4, minute: 0)) ?? Date()
    @State private var quoteTime3 = Calendar.current.date(from: DateComponents(hour: (UserDefaults.standard.integer(forKey: "wakeUpHour") > 0 ? UserDefaults.standard.integer(forKey: "wakeUpHour") : 7) + 7, minute: 0)) ?? Date()
    @State private var quoteTime4 = Calendar.current.date(from: DateComponents(hour: (UserDefaults.standard.integer(forKey: "wakeUpHour") > 0 ? UserDefaults.standard.integer(forKey: "wakeUpHour") : 7) + 10, minute: 0)) ?? Date()
    @State private var quoteTime5 = Calendar.current.date(from: DateComponents(hour: (UserDefaults.standard.integer(forKey: "wakeUpHour") > 0 ? UserDefaults.standard.integer(forKey: "wakeUpHour") : 7) + 13, minute: 0)) ?? Date()

    @State private var notificationPermissionDenied = false
    @AppStorage("morningLoopHour") private var morningLoopHour = 7
    @AppStorage("morningLoopMinute") private var morningLoopMinute = 0
    @AppStorage("afternoonLoopHour") private var afternoonLoopHour = 13
    @AppStorage("afternoonLoopMinute") private var afternoonLoopMinute = 0
    @AppStorage("eveningLoopHour") private var eveningLoopHour = 19
    @AppStorage("eveningLoopMinute") private var eveningLoopMinute = 0

    @State private var morningTime: Date = Date()
    @State private var afternoonTime: Date = Date()
    @State private var eveningTime: Date = Date()

    @State private var wakeTime: Date = {
        let hour = UserDefaults.standard.integer(forKey: "wakeUpHour")
        return Calendar.current.date(from: DateComponents(hour: hour > 0 ? hour : 7, minute: 0)) ?? Date()
    }()

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
                        HStack(spacing: 10) {
                            Image(systemName: "sunrise.fill").foregroundColor(.neonGold)
                            DatePicker("Morning Plan", selection: $morningTime, displayedComponents: .hourAndMinute)
                                .foregroundColor(.textPrimary)
                        }

                        HStack(spacing: 10) {
                            Image(systemName: "sun.max.fill").foregroundColor(.neonOrange)
                            DatePicker("Afternoon Check-In", selection: $afternoonTime, displayedComponents: .hourAndMinute)
                                .foregroundColor(.textPrimary)
                        }

                        HStack(spacing: 10) {
                            Image(systemName: "moon.fill").foregroundColor(.neonPurple)
                            DatePicker("Evening Review", selection: $eveningTime, displayedComponents: .hourAndMinute)
                                .foregroundColor(.textPrimary)
                        }

                        Text("Set when you'd like each daily loop reminder.")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)

                    }
                } header: {
                    Text("Daily Loop")
                } footer: {
                    Text("Three reminders per day based on your wake time, 6 hours apart.")
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
            let cal = Calendar.current
            let wake = UserDefaults.standard.integer(forKey: "wakeUpHour")
            let w = wake > 0 ? wake : 7

            // Daily loop: wake, wake+6, wake+12
            if morningLoopHour == 7 && wake > 0 { morningLoopHour = w }
            if afternoonLoopHour == 13 || afternoonLoopHour == 15 { afternoonLoopHour = (w + 6) % 24 }
            if eveningLoopHour == 19 || eveningLoopHour == 23 { eveningLoopHour = (w + 12) % 24 }

            morningTime = cal.date(from: DateComponents(hour: morningLoopHour, minute: morningLoopMinute)) ?? Date()
            afternoonTime = cal.date(from: DateComponents(hour: afternoonLoopHour, minute: afternoonLoopMinute)) ?? Date()
            eveningTime = cal.date(from: DateComponents(hour: eveningLoopHour, minute: eveningLoopMinute)) ?? Date()

            // Quotes: wake+1, wake+4, wake+7, wake+10, wake+13
            if !UserDefaults.standard.bool(forKey: "quoteTimesCustomized") {
                quoteSlot1Hour = (w + 1) % 24
                quoteSlot2Hour = (w + 4) % 24
                quoteSlot3Hour = (w + 7) % 24
                quoteSlot4Hour = (w + 10) % 24
                quoteSlot5Hour = (w + 13) % 24
            }

            quoteTime1 = cal.date(from: DateComponents(hour: quoteSlot1Hour, minute: quoteSlot1Minute)) ?? Date()
            quoteTime2 = cal.date(from: DateComponents(hour: quoteSlot2Hour, minute: quoteSlot2Minute)) ?? Date()
            quoteTime3 = cal.date(from: DateComponents(hour: quoteSlot3Hour, minute: quoteSlot3Minute)) ?? Date()
            quoteTime4 = cal.date(from: DateComponents(hour: quoteSlot4Hour, minute: quoteSlot4Minute)) ?? Date()
            quoteTime5 = cal.date(from: DateComponents(hour: quoteSlot5Hour, minute: quoteSlot5Minute)) ?? Date()
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
        .onChange(of: morningTime) { newValue in
            let cal = Calendar.current
            morningLoopHour = cal.component(.hour, from: newValue)
            morningLoopMinute = cal.component(.minute, from: newValue)
            UserDefaults.standard.set(morningLoopHour, forKey: "wakeUpHour")
            NotificationScheduler.scheduleAll(context: environment.viewContext)
        }
        .onChange(of: afternoonTime) { newValue in
            let cal = Calendar.current
            afternoonLoopHour = cal.component(.hour, from: newValue)
            afternoonLoopMinute = cal.component(.minute, from: newValue)
            UserDefaults.standard.set(afternoonLoopHour, forKey: "afternoonHour")
            NotificationScheduler.scheduleAll(context: environment.viewContext)
        }
        .onChange(of: eveningTime) { newValue in
            let cal = Calendar.current
            eveningLoopHour = cal.component(.hour, from: newValue)
            eveningLoopMinute = cal.component(.minute, from: newValue)
            UserDefaults.standard.set(eveningLoopHour, forKey: "eveningHour")
            NotificationScheduler.scheduleAll(context: environment.viewContext)
        }
        .onChange(of: quoteTime1) { newValue in
            let cal = Calendar.current
            quoteSlot1Hour = cal.component(.hour, from: newValue)
            quoteSlot1Minute = cal.component(.minute, from: newValue)
            UserDefaults.standard.set(true, forKey: "quoteTimesCustomized")
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
            if granted {
                NotificationScheduler.scheduleAll(context: environment.viewContext)
            }
        }
    }

    private func scheduleQuoteNotifications() {
        NotificationScheduler.scheduleAll(context: environment.viewContext)
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
