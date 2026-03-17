import SwiftUI
import Combine

// MARK: - Porn Tools View

struct PornToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Late-Night Shield").tag(0)
                    Text("Emergency Mode").tag(1)
                    Text("Risk Map").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: LateNightShieldCard()
                case 1: EmergencyModeCard()
                default: RiskIndicatorCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Recovery Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Late-Night Shield

private struct ShieldCheckItem: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    var isChecked: Bool = false
}

private struct LateNightShieldCard: View {
    @State private var items: [ShieldCheckItem] = [
        ShieldCheckItem(label: "Put your phone across the room", icon: "iphone.slash"),
        ShieldCheckItem(label: "Turn on blue light filter", icon: "moon.fill"),
        ShieldCheckItem(label: "Open a calming playlist or podcast", icon: "headphones"),
        ShieldCheckItem(label: "Set a sleep timer for 15 minutes", icon: "timer"),
        ShieldCheckItem(label: "Write down what you are feeling", icon: "pencil.and.outline"),
        ShieldCheckItem(label: "Take 5 deep breaths", icon: "wind"),
    ]
    @State private var allComplete = false

    private var completedCount: Int {
        items.filter(\.isChecked).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Late-Night Shield", systemImage: "shield.lefthalf.filled")
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

            Text("It is late and you are feeling pulled. Work through this checklist to redirect your energy.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            if allComplete {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.neonCyan)
                    Text("Shield activated. You are safe tonight.")
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Color.neonCyan)
                    Text("Go to sleep knowing you chose your best self.")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)

                    Button("Reset Shield") {
                        withAnimation {
                            for i in items.indices { items[i].isChecked = false }
                            allComplete = false
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
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
                                .foregroundColor(Color.neonCyan)
                                .frame(width: 24)

                            Text(item.label)
                                .font(.subheadline)
                                .foregroundColor(item.isChecked ? Color.subtleText : Color.appText)
                                .strikethrough(item.isChecked)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Calming quote
            VStack(spacing: 8) {
                Divider()
                Text("\"The urge is a wave. You do not have to ride it. Just let it pass.\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(Color.subtleText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
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

// MARK: - Emergency Mode

private struct EmergencyStep: Identifiable {
    let id = UUID()
    let step: Int
    let action: String
    let icon: String
    var completed: Bool = false
}

private struct EmergencyModeCard: View {
    @State private var steps: [EmergencyStep] = [
        EmergencyStep(step: 1, action: "Close the browser or app right now", icon: "xmark.circle.fill"),
        EmergencyStep(step: 2, action: "Stand up and leave the room", icon: "figure.walk"),
        EmergencyStep(step: 3, action: "Splash cold water on your face", icon: "drop.fill"),
        EmergencyStep(step: 4, action: "Call or text your accountability partner", icon: "phone.fill"),
        EmergencyStep(step: 5, action: "Do 20 push-ups or jumping jacks", icon: "bolt.heart.fill"),
        EmergencyStep(step: 6, action: "Write in your journal what triggered this", icon: "pencil.line"),
    ]
    @State private var currentStep = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Emergency Mode", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundColor(Color.neonMagenta)
                Spacer()
                if currentStep > 0 {
                    Text("Step \(min(currentStep, steps.count))/\(steps.count)")
                        .font(Font.caption.weight(.bold))
                        .foregroundColor(Color.neonOrange)
                }
            }

            if currentStep >= steps.count {
                VStack(spacing: 12) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.neonCyan)
                    Text("You did it. The moment has passed.")
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Color.neonCyan)
                    Text("Every time you resist, your brain rewires a little more.")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                        .multilineTextAlignment(.center)

                    Button("Reset") {
                        withAnimation {
                            currentStep = 0
                            for i in steps.indices { steps[i].completed = false }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(index < currentStep ? Color.neonCyan : (index == currentStep ? Color.neonOrange : Color.gray.opacity(0.2)))
                                .frame(width: 32, height: 32)

                            if index < currentStep {
                                Image(systemName: "checkmark")
                                    .font(Font.caption.weight(.bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(step.step)")
                                    .font(Font.caption.weight(.bold))
                                    .foregroundColor(index == currentStep ? .white : Color.subtleText)
                            }
                        }

                        Image(systemName: step.icon)
                            .foregroundColor(index == currentStep ? Color.neonOrange : Color.subtleText)
                            .frame(width: 24)

                        Text(step.action)
                            .font(Font.subheadline.weight(index == currentStep ? .semibold : .regular))
                            .foregroundColor(index <= currentStep ? Color.appText : Color.subtleText)
                    }
                    .padding(.vertical, 4)
                    .opacity(index > currentStep ? 0.5 : 1)
                }

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        if currentStep < steps.count {
                            steps[currentStep].completed = true
                            currentStep += 1
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Done - Next Step")
                            .font(Font.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonOrange)
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
}

// MARK: - Risk Indicator

private struct RiskIndicatorCard: View {
    private let hour = Calendar.current.component(.hour, from: Date())

    private var riskLevel: (level: String, color: Color, description: String, advice: String) {
        switch hour {
        case 6..<12:
            return ("Low", Color.neonCyan, "Morning hours tend to be lower risk.", "Great time for productive activities and building positive habits.")
        case 12..<17:
            return ("Moderate", Color.neonGold, "Afternoon can bring boredom triggers.", "Stay engaged. Take a walk, work on a project, or connect with someone.")
        case 17..<21:
            return ("Elevated", Color.neonOrange, "Evening is when many people feel vulnerable.", "Have your evening routine ready. Avoid being alone with screens.")
        default:
            return ("High", Color.red, "Late night is peak risk time for most people.", "Activate your Late-Night Shield. Put your phone away and go to bed.")
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Label("Time-of-Day Risk Map", systemImage: "clock.fill")
                .font(.headline)
                .foregroundColor(Color.neonPurple)

            // Current risk
            VStack(spacing: 12) {
                Text("Current Risk Level")
                    .font(.caption)
                    .foregroundColor(Color.subtleText)

                Text(riskLevel.level)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(riskLevel.color)

                Text(riskLevel.description)
                    .font(.subheadline)
                    .foregroundColor(Color.subtleText)
                    .multilineTextAlignment(.center)

                Text(riskLevel.advice)
                    .font(.subheadline)
                    .foregroundColor(Color.appText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(riskLevel.color.opacity(0.1))
                    .cornerRadius(12)
            }

            Divider()

            // Day overview
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Risk Pattern")
                    .font(Font.subheadline.weight(.semibold))
                    .foregroundColor(Color.appText)

                ForEach(timeBlocks, id: \.label) { block in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(block.color)
                            .frame(width: 10, height: 10)
                        Text(block.label)
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(block.color.opacity(0.6))
                                .frame(width: geo.size.width * block.risk)
                        }
                        .frame(height: 12)
                    }
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

    private var timeBlocks: [(label: String, risk: CGFloat, color: Color)] {
        [
            ("Morning", 0.2, Color.neonCyan),
            ("Afternoon", 0.45, Color.neonGold),
            ("Evening", 0.7, Color.neonOrange),
            ("Late Night", 0.95, Color.red),
        ]
    }
}

// MARK: - Preview

struct PornToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PornToolsView()
        }
    }
}
