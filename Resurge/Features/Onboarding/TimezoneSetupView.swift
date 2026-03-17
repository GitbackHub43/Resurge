import SwiftUI

struct TimezoneSetupView: View {

    @State private var wakeTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var detectedTimezone = TimeZone.current.identifier

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                Spacer().frame(height: 20)

                // Header
                VStack(spacing: 8) {
                    Image(systemName: "globe")
                        .font(.system(size: 48))
                        .foregroundColor(.neonCyan)
                        .shadow(color: .neonCyan.opacity(0.5), radius: 8)

                    Text("Your Schedule")
                        .font(Typography.largeTitle)
                        .rainbowText()

                    Text("We'll schedule your daily reminders based on when you wake up.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppStyle.screenPadding)
                }

                // Timezone section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "globe").foregroundColor(.neonBlue)
                        Text("Your Timezone").font(Typography.headline).foregroundColor(.textPrimary)
                    }

                    Text(detectedTimezone)
                        .font(Typography.title)
                        .foregroundColor(.neonCyan)

                    Text("Auto-detected from your device")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .neonCard(glow: .neonBlue)
                .padding(.horizontal, AppStyle.screenPadding)

                // Wake time section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sunrise.fill").foregroundColor(.neonGold)
                        Text("When do you wake up?").font(Typography.headline).foregroundColor(.textPrimary)
                    }

                    DatePicker("Wake time", selection: $wakeTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 120)
                        .clipped()

                    Text("We'll use this to set your daily reminders.")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .neonCard(glow: .neonGold)
                .padding(.horizontal, AppStyle.screenPadding)

                Spacer().frame(height: 40)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onDisappear {
            saveSchedule()
        }
    }

    private func scheduleRow(_ title: String, hour: Int, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(color).frame(width: 24)
            Text(title).font(Typography.body).foregroundColor(.appText)
            Spacer()
            Text(formatHour(hour)).font(Typography.headline).foregroundColor(color)
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour >= 12 ? "PM" : "AM"
        return "\(h):00 \(ampm)"
    }

    private func saveSchedule() {
        let wakeHour = Calendar.current.component(.hour, from: wakeTime)
        UserDefaults.standard.set(wakeHour, forKey: "wakeUpHour")
        UserDefaults.standard.set((wakeHour + 8) % 24, forKey: "afternoonHour")
        UserDefaults.standard.set(min(wakeHour + 16, 23), forKey: "eveningHour")
        UserDefaults.standard.set(TimeZone.current.identifier, forKey: "userTimezone")
    }
}
