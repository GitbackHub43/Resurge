import SwiftUI
import Combine

// MARK: - Sleep Tools View

struct SleepToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Wind-Down").tag(0)
                    Text("Countdown").tag(1)
                    Text("Blue Light").tag(2)
                    Text("Environment").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: WindDownRitualCard()
                case 1: BedtimeCountdownCard()
                case 2: BlueLightReminderCard()
                default: SleepEnvironmentCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Sleep Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Wind-Down Ritual

private struct RitualItem: Identifiable {
    let id = UUID()
    var label: String
    var subtitle: String
    var icon: String
    var durationMinutes: Int
    var isChecked: Bool = false
    var isCustom: Bool = false
}

private struct WindDownRitualCard: View {
    @State private var items: [RitualItem] = [
        RitualItem(label: "Dim the Lights", subtitle: "Lower overhead lights and switch to warm lamps.", icon: "lightbulb.fill", durationMinutes: 1),
        RitualItem(label: "Put Away Screens", subtitle: "Set your phone on the charger away from bed.", icon: "iphone.slash", durationMinutes: 1),
        RitualItem(label: "Light Stretch", subtitle: "Gentle stretching to release tension from the day.", icon: "figure.cooldown", durationMinutes: 5),
        RitualItem(label: "Gratitude Journal", subtitle: "Write 3 things you are grateful for today.", icon: "pencil.and.list.clipboard", durationMinutes: 5),
        RitualItem(label: "Deep Breathing", subtitle: "4-7-8 breathing: inhale 4s, hold 7s, exhale 8s.", icon: "lungs.fill", durationMinutes: 5),
        RitualItem(label: "Read a Book", subtitle: "Read something calming (no screens).", icon: "book.fill", durationMinutes: 15),
        RitualItem(label: "Herbal Tea", subtitle: "Chamomile or another caffeine-free tea.", icon: "cup.and.saucer.fill", durationMinutes: 5),
    ]
    @State private var newItemText = ""
    @State private var allComplete = false

    private var completedCount: Int {
        items.filter(\.isChecked).count
    }

    private var totalMinutes: Int {
        items.reduce(0) { $0 + $1.durationMinutes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Wind-Down Ritual", systemImage: "moon.stars.fill")
                    .font(.headline)
                    .foregroundColor(Color.neonCyan)
                Spacer()
                Text("\(completedCount)/\(items.count)")
                    .font(Font.caption.weight(.bold))
                    .foregroundColor(Color.neonCyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.neonCyan.opacity(0.15))
                    .cornerRadius(8)
            }

            Text("Follow these steps each night to signal your body that it is time to sleep.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Progress bar with time estimate
            VStack(spacing: 6) {
                HStack {
                    Text("\(completedCount) of \(items.count) completed")
                        .font(Font.caption.weight(.medium))
                        .foregroundColor(Color.appText)
                    Spacer()
                    Text("~\(totalMinutes) min total")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.15))
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color.neonCyan, Color.neonGold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: items.isEmpty ? 0 : geo.size.width * CGFloat(completedCount) / CGFloat(items.count))
                            .animation(.easeInOut(duration: 0.3), value: completedCount)
                    }
                }
                .frame(height: 8)
            }

            if allComplete {
                VStack(spacing: 12) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.neonCyan)
                    Text("Your wind-down ritual is complete. Time for sleep.")
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Color.neonCyan)
                        .multilineTextAlignment(.center)
                    Text("Sweet dreams.")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)

                    Button("Reset Ritual") {
                        withAnimation {
                            for i in items.indices { items[i].isChecked = false }
                            allComplete = false
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach($items) { $item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            item.isChecked.toggle()
                            if completedCount == items.count {
                                allComplete = true
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundColor(item.isChecked ? Color.neonCyan : Color.gray.opacity(0.4))

                            Image(systemName: item.icon)
                                .foregroundColor(item.isChecked ? Color.neonCyan : Color.subtleText)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.label)
                                    .font(Font.subheadline.weight(.medium))
                                    .foregroundColor(item.isChecked ? Color.subtleText : Color.appText)
                                    .strikethrough(item.isChecked)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundColor(Color.subtleText)
                            }

                            Spacer()

                            Text("\(item.durationMinutes)m")
                                .font(Font.caption.weight(.bold))
                                .foregroundColor(Color.subtleText)
                        }
                        .padding(12)
                        .background(item.isChecked ? Color.neonCyan.opacity(0.06) : Color.appBackground)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }

                // Add custom step
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Color.neonCyan)
                    TextField("Add a custom step...", text: $newItemText)
                        .font(.subheadline)
                        .onSubmit { addCustomItem() }
                    if !newItemText.isEmpty {
                        Button {
                            addCustomItem()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color.neonCyan)
                        }
                    }
                }
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    private func addCustomItem() {
        guard !newItemText.isEmpty else { return }
        withAnimation {
            items.append(RitualItem(label: newItemText, subtitle: "Custom step", icon: "star.fill", durationMinutes: 5, isCustom: true))
            newItemText = ""
        }
    }
}

// MARK: - Bedtime Countdown

private struct BedtimeCountdownCard: View {
    @State private var targetHour: Int = 22
    @State private var targetMinute: Int = 30
    @State private var isActive = false
    @State private var remainingSeconds: Int = 0
    @State private var timerCancellable: AnyCancellable?

    private var targetDate: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = targetHour
        components.minute = targetMinute
        var date = calendar.date(from: components) ?? Date()
        if date < Date() {
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return date
    }

    private var statusColor: Color {
        if remainingSeconds < 900 { return .red }
        if remainingSeconds < 1800 { return Color.neonOrange }
        if remainingSeconds < 3600 { return Color.neonGold }
        return Color.neonCyan
    }

    private var statusMessage: String {
        if remainingSeconds <= 0 { return "It is past your bedtime. Go to sleep now." }
        if remainingSeconds < 900 { return "Bedtime is very close. Get into bed." }
        if remainingSeconds < 1800 { return "Start your wind-down ritual now." }
        if remainingSeconds < 3600 { return "Bedtime approaching. Begin winding down." }
        return "You have time. Plan to start winding down 30 minutes before bed."
    }

    var body: some View {
        VStack(spacing: 16) {
            Label("Bedtime Countdown", systemImage: "bed.double.fill")
                .font(.headline)
                .foregroundColor(Color.neonBlue)

            if isActive {
                VStack(spacing: 16) {
                    Text("Bedtime at \(String(format: "%02d:%02d", targetHour, targetMinute))")
                        .font(.subheadline)
                        .foregroundColor(Color.subtleText)

                    // Large countdown
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                            .frame(width: 200, height: 200)

                        Circle()
                            .trim(from: 0, to: min(1 - CGFloat(remainingSeconds) / 14400.0, 1.0))
                            .stroke(statusColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 4) {
                            if remainingSeconds > 0 {
                                Text(formatTime(remainingSeconds))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(statusColor)
                                Text("until bedtime")
                                    .font(.caption)
                                    .foregroundColor(Color.subtleText)
                            } else {
                                Image(systemName: "moon.zzz.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.red)
                                Text("Past bedtime")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(statusColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(12)

                    Button("Deactivate Countdown") {
                        withAnimation {
                            isActive = false
                            timerCancellable?.cancel()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
                }
            } else {
                Text("Set your target bedtime and the countdown will change color as it approaches, reminding you to wind down.")
                    .font(.subheadline)
                    .foregroundColor(Color.subtleText)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Picker("Hour", selection: $targetHour) {
                        ForEach(20..<28, id: \.self) { h in
                            Text(String(format: "%02d", h % 24)).tag(h % 24)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 120)
                    .clipped()

                    Text(":")
                        .font(Font.title2.weight(.bold))

                    Picker("Minute", selection: $targetMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text(String(format: "%02d", m)).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60, height: 120)
                    .clipped()
                }

                // Color legend
                HStack(spacing: 16) {
                    LegendDot(color: Color.neonCyan, label: "> 1 hr")
                    LegendDot(color: Color.neonGold, label: "< 1 hr")
                    LegendDot(color: Color.neonOrange, label: "< 30 min")
                    LegendDot(color: .red, label: "< 15 min")
                }

                Button {
                    startCountdown()
                } label: {
                    HStack {
                        Image(systemName: "moon.fill")
                        Text("Start Countdown")
                            .font(Font.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    private func startCountdown() {
        remainingSeconds = max(Int(targetDate.timeIntervalSince(Date())), 0)
        isActive = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                remainingSeconds = max(Int(targetDate.timeIntervalSince(Date())), 0)
            }
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Color.subtleText)
        }
    }
}

// MARK: - Blue Light Reminder

private struct BlueLightReminderCard: View {
    @State private var screenFreeMinutes: Int = 60

    private let screenFreeTips: [(icon: String, title: String, detail: String)] = [
        ("iphone.slash", "Put Phone Away", "Place it on a charger in another room or across the room from your bed."),
        ("tv.slash", "No TV in Bed", "If you watch TV, stop at least 30 minutes before you want to sleep."),
        ("laptopcomputer", "Close the Laptop", "Set a hard stop time for work and browsing."),
        ("eyeglasses", "Blue Light Glasses", "If you must use screens, wear blue-light-blocking glasses."),
        ("moon.fill", "Night Shift / Dark Mode", "Enable Night Shift on iOS and use dark mode to reduce blue light."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Blue Light Reminder", systemImage: "eye.trianglebadge.exclamationmark")
                .font(.headline)
                .foregroundColor(Color.neonMagenta)

            Text("Blue light from screens suppresses melatonin and makes it harder to fall asleep.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Screen-free zone setting
            VStack(alignment: .leading, spacing: 8) {
                Text("Screen-Free Zone Before Bed")
                    .font(Font.caption.weight(.medium))
                    .foregroundColor(Color.subtleText)

                HStack(spacing: 12) {
                    ForEach([30, 45, 60, 90, 120], id: \.self) { minutes in
                        Button {
                            screenFreeMinutes = minutes
                        } label: {
                            Text("\(minutes)m")
                                .font(Font.caption.weight(screenFreeMinutes == minutes ? .bold : .regular))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(screenFreeMinutes == minutes ? Color.neonOrange : Color.appBackground)
                                .foregroundColor(screenFreeMinutes == minutes ? .white : Color.appText)
                                .cornerRadius(8)
                        }
                    }
                }

                Text("Goal: No screens \(screenFreeMinutes) minutes before bedtime.")
                    .font(Font.caption.weight(.medium))
                    .foregroundColor(Color.neonCyan)
            }
            .padding()
            .background(Color.appBackground)
            .cornerRadius(12)

            // Science note
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(Color.neonOrange)
                    Text("Why It Matters")
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Color.appText)
                }
                Text("Blue light (450-490nm) suppresses melatonin production by up to 50%. Even 30 minutes of screen-free time before bed can significantly improve sleep quality.")
                    .font(.caption)
                    .foregroundColor(Color.appText)
                    .lineSpacing(2)
            }
            .padding()
            .background(Color.neonOrange.opacity(0.06))
            .cornerRadius(12)

            // Tips
            let tipRainbowColors: [Color] = [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange]
            ForEach(Array(screenFreeTips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(tipRainbowColors[index % tipRainbowColors.count].opacity(0.1))
                            .frame(width: 36, height: 36)
                        Image(systemName: tip.icon)
                            .font(.caption)
                            .foregroundColor(tipRainbowColors[index % tipRainbowColors.count])
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.title)
                            .font(Font.subheadline.weight(.medium))
                        Text(tip.detail)
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                    }
                }
                .padding(10)
                .background(Color.appBackground)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Sleep Environment Checklist

private struct EnvironmentItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let icon: String
    var isChecked: Bool = false
}

private struct SleepEnvironmentCard: View {
    @State private var items: [EnvironmentItem] = [
        EnvironmentItem(title: "Room Temperature", detail: "Keep bedroom between 60-67 F (15-19 C) for optimal sleep.", icon: "thermometer.medium"),
        EnvironmentItem(title: "Darkness", detail: "Use blackout curtains or a sleep mask to block all light.", icon: "moon.fill"),
        EnvironmentItem(title: "Quiet", detail: "Use earplugs or a white noise machine to block disturbances.", icon: "speaker.slash.fill"),
        EnvironmentItem(title: "Comfortable Bedding", detail: "Ensure your mattress and pillows properly support you.", icon: "bed.double.fill"),
        EnvironmentItem(title: "No Clutter", detail: "A tidy room promotes a calm mind. Clear your nightstand.", icon: "sparkles"),
        EnvironmentItem(title: "No Screens in Bed", detail: "Keep phones and tablets away from your sleeping area.", icon: "iphone.slash"),
        EnvironmentItem(title: "Calming Scent", detail: "Lavender or chamomile can promote relaxation.", icon: "leaf.fill"),
        EnvironmentItem(title: "Alarm Set", detail: "Set your alarm so you stop worrying about oversleeping.", icon: "alarm.fill"),
    ]

    private var checkedCount: Int {
        items.filter(\.isChecked).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Sleep Environment", systemImage: "house.fill")
                .font(.headline)
                .foregroundColor(Color.neonPurple)

            Text("Optimize your bedroom for sleep. Check off each item before bed.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Score
            VStack(spacing: 6) {
                HStack {
                    Text("Environment Score")
                        .font(Font.caption.weight(.medium))
                        .foregroundColor(Color.appText)
                    Spacer()
                    Text("\(checkedCount)/\(items.count)")
                        .font(Font.caption.weight(.bold))
                        .foregroundColor(Color.neonCyan)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(scoreColor)
                            .frame(width: items.isEmpty ? 0 : geo.size.width * CGFloat(checkedCount) / CGFloat(items.count), height: 10)
                    }
                }
                .frame(height: 10)

                Text(scoreMessage)
                    .font(Font.caption.weight(.medium))
                    .foregroundColor(scoreColor)
            }
            .padding()
            .background(Color.appBackground)
            .cornerRadius(12)

            // Checklist
            ForEach($items) { $item in
                Button {
                    withAnimation { item.isChecked.toggle() }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(item.isChecked ? Color.neonCyan : Color.subtleText)

                        Image(systemName: item.icon)
                            .foregroundColor(Color.neonCyan)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(Font.subheadline.weight(.medium))
                                .foregroundColor(Color.appText)
                                .strikethrough(item.isChecked, color: Color.subtleText)
                            Text(item.detail)
                                .font(.caption)
                                .foregroundColor(Color.subtleText)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(item.isChecked ? Color.neonCyan.opacity(0.06) : Color.appBackground)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }

            // Reset
            Button {
                withAnimation {
                    for i in items.indices {
                        items[i].isChecked = false
                    }
                }
            } label: {
                Text("Reset Checklist")
                    .font(Font.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.appBackground)
                    .foregroundColor(Color.subtleText)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    private var scoreColor: Color {
        let ratio = Double(checkedCount) / Double(items.count)
        if ratio >= 0.8 { return Color.neonCyan }
        if ratio >= 0.5 { return Color.neonGold }
        return Color.neonOrange
    }

    private var scoreMessage: String {
        let ratio = Double(checkedCount) / Double(items.count)
        if ratio >= 1.0 { return "Perfect sleep environment!" }
        if ratio >= 0.8 { return "Great setup. Almost perfect." }
        if ratio >= 0.5 { return "Good start. A few more tweaks will help." }
        return "Several items to improve for better sleep."
    }
}

// MARK: - Preview

struct SleepToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SleepToolsView()
        }
    }
}
