import SwiftUI
import Combine

struct SobrietyCounterView: View {

    let startDate: Date
    var isCompact: Bool = false

    @State private var now = DebugDate.now
    @State private var glowOpacity: Double = 0.15
    @AppStorage("equippedWatchSkin") private var equippedWatchSkin: String = ""

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var components: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(now.timeIntervalSince(startDate), 0)
        let totalSeconds = Int(interval)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return (days, hours, minutes, seconds)
    }

    var body: some View {
        let parts = components

        Group {
            if isCompact {
                compactLayout(parts: parts)
            } else {
                fullLayout(parts: parts)
            }
        }
        .onReceive(timer) { _ in
            now = DebugDate.now
        }
    }

    // MARK: - Compact Layout

    private var watchIcon: some View {
        Group {
            switch equippedWatchSkin {
            case "watch_classic":
                ZStack {
                    Circle().stroke(Color.neonCyan, lineWidth: 1.5).frame(width: 16, height: 16)
                    Rectangle().fill(Color.neonCyan).frame(width: 1, height: 5).offset(y: -2)
                    Rectangle().fill(Color.neonCyan).frame(width: 4, height: 1).offset(x: 1)
                }
                .frame(width: 18, height: 18)
            case "watch_digital":
                ZStack {
                    RoundedRectangle(cornerRadius: 2).stroke(Color.neonGreen, lineWidth: 1.5).frame(width: 16, height: 14)
                    Text("00").font(.system(size: 6, weight: .bold, design: .monospaced)).foregroundColor(.neonGreen)
                }
                .frame(width: 18, height: 18)
            case "watch_luxury":
                ZStack {
                    Circle().fill(Color.neonGold.opacity(0.15)).frame(width: 18, height: 18)
                    Circle().stroke(Color.neonGold, lineWidth: 1.5).frame(width: 16, height: 16)
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.neonGold)
                }
                .frame(width: 18, height: 18)
            case "watch_holographic":
                Image(systemName: "clock.fill")
                    .font(Typography.caption)
                    .foregroundStyle(
                        LinearGradient(colors: [.neonCyan, .neonPurple, .neonMagenta, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            default:
                Image(systemName: "clock.fill")
                    .font(Typography.caption)
                    .foregroundColor(.neonCyan)
            }
        }
    }

    private func compactLayout(parts: (days: Int, hours: Int, minutes: Int, seconds: Int)) -> some View {
        HStack(spacing: 6) {
            watchIcon

            Text("\(parts.days)d \(parts.hours)h \(parts.minutes)m")
                .font(Typography.headline)
                .foregroundColor(.neonCyan)
                .monospacedDigit()
                .shadow(color: .neonCyan.opacity(0.4), radius: 4, x: 0, y: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.neonCyan.opacity(0.5), .neonPurple.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .neonCyan.opacity(0.2), radius: 8, x: 0, y: 0)
    }

    // MARK: - Full Layout

    private func fullLayout(parts: (days: Int, hours: Int, minutes: Int, seconds: Int)) -> some View {
        ZStack {
            // Multi-color glow pulse behind counter
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.neonCyan.opacity(glowOpacity),
                            Color.neonPurple.opacity(glowOpacity * 0.6),
                            Color.neonMagenta.opacity(glowOpacity * 0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 30)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                        glowOpacity = 0.35
                    }
                }

            HStack(spacing: 4) {
                counterUnit(value: parts.days, label: "days", color: .neonCyan)
                separatorDot
                counterUnit(value: parts.hours, label: "hours", color: .neonBlue)
                separatorDot
                counterUnit(value: parts.minutes, label: "min", color: .neonPurple)
                separatorDot
                counterUnit(value: parts.seconds, label: "sec", color: .neonMagenta)
            }
        }
    }

    private func counterUnit(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(Typography.counter)
                .foregroundColor(color)
                .monospacedDigit()
                .shadow(color: color.opacity(0.6), radius: 6, x: 0, y: 0)

            Text(label)
                .font(Typography.statLabel)
                .foregroundColor(.textSecondary)
        }
    }

    private var separatorDot: some View {
        Text(":")
            .font(Typography.counter)
            .foregroundColor(.neonPurple.opacity(0.3))
            .offset(y: -8)
    }
}

struct SobrietyCounterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            SobrietyCounterView(
                startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()
            )

            SobrietyCounterView(
                startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
                isCompact: true
            )
        }
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
