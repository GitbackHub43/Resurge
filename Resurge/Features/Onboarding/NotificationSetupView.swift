import SwiftUI

struct NotificationSetupView: View {

    let notificationManager: NotificationManager
    let onNext: () -> Void

    @State private var hasResponded = false
    @State private var permissionGranted = false

    private func requestAndWait() {
        notificationManager.requestPermissionIfNeeded { granted in
            DispatchQueue.main.async {
                permissionGranted = granted
                hasResponded = true
            }
        }
    }

    var body: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(Color.neonGold.opacity(0.1))
                    .frame(width: 160, height: 160)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundColor(.neonGold)
            }

            // Title
            Text("Stay on Track")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("Notifications help you build consistency and stay accountable.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            // Notification types
            VStack(spacing: AppStyle.spacing) {
                notificationRow(
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    iconColor: .neonCyan,
                    title: "Daily Loop Reminders",
                    subtitle: "Get reminded for all 3 daily check-ins."
                )

                VStack(spacing: 0) {
                    let wakeHour = UserDefaults.standard.integer(forKey: "wakeUpHour")
                    let afternoonHour = (wakeHour + 8) % 24
                    let eveningHour = min(wakeHour + 16, 23)

                    dailyLoopSubRow(icon: "sunrise.fill", color: .neonGold, title: "Morning Plan", time: formatHour(wakeHour))
                    Divider().background(Color.cardBorder)
                    dailyLoopSubRow(icon: "sun.max.fill", color: .neonCyan, title: "Afternoon Check-In", time: formatHour(afternoonHour))
                    Divider().background(Color.cardBorder)
                    dailyLoopSubRow(icon: "moon.stars.fill", color: .neonPurple, title: "Evening Review", time: formatHour(eveningHour))
                }
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )

                notificationRow(
                    icon: "heart.fill",
                    iconColor: .neonMagenta,
                    title: "Motivational Boosts",
                    subtitle: "Receive encouragement when you need it most."
                )
            }
            .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            // Enable Notifications button
            VStack(spacing: AppStyle.spacing) {
                if hasResponded {
                    // After they've made their choice, show status
                    HStack(spacing: 8) {
                        Image(systemName: permissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(permissionGranted ? .neonGreen : .neonOrange)
                        Text(permissionGranted ? "Notifications enabled!" : "Notifications skipped")
                            .font(Typography.headline)
                            .foregroundColor(permissionGranted ? .neonGreen : .neonOrange)
                    }
                } else {
                    Button {
                        requestAndWait()
                    } label: {
                        Text("Enable Notifications")
                    }
                    .buttonStyle(RainbowButtonStyle())

                    Button {
                        hasResponded = true
                        permissionGranted = false
                    } label: {
                        Text("Skip for now")
                            .font(Typography.callout)
                            .foregroundColor(.subtleText)
                    }
                }
            }
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    private func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour >= 12 ? "PM" : "AM"
        return "\(h):00 \(ampm)"
    }

    // MARK: - Daily Loop Sub Row

    private func dailyLoopSubRow(icon: String, color: Color, title: String, time: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 24)

            Text(title)
                .font(Typography.caption)
                .foregroundColor(.appText)

            Spacer()

            Text(time)
                .font(.system(size: 10))
                .foregroundColor(.subtleText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Notification Row

    private func notificationRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: AppStyle.spacing) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(.appText)

                Text(subtitle)
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }

            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.smallCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Preview

struct NotificationSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSetupView(
            notificationManager: NotificationManager(),
            onNext: {}
        )
    }
}
