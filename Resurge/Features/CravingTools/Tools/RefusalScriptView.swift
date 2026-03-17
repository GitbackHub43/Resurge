import SwiftUI

struct RefusalScriptView: View {

    @Environment(\.presentationMode) var presentationMode
    @AppStorage("practicedScripts") private var practicedScriptsRaw: String = ""

    // MARK: - State

    @State private var currentStep: Int = 0 // 0 = pick, 1 = read, 2 = practiced
    @State private var selectedScript: RefusalScript? = nil
    @State private var isComplete: Bool = false
    @State private var confettiVisible: Bool = false

    private let scripts: [RefusalScript] = [
        RefusalScript(
            id: "simple",
            title: "No thanks, I\u{2019}m good.",
            style: "Simple, direct",
            context: "When someone offers casually. A short, confident response works best for low-pressure situations.",
            fullScript: "Just smile and say: \u{201C}No thanks, I\u{2019}m good.\u{201D} No explanation needed. Keep it light and move on.",
            icon: "hand.raised.fill",
            color: .neonCyan
        ),
        RefusalScript(
            id: "break",
            title: "I\u{2019}m taking a break from that.",
            style: "Non-confrontational",
            context: "When you don\u{2019}t want to explain your full reasons. This signals a choice without inviting debate.",
            fullScript: "Say: \u{201C}I\u{2019}m taking a break from that.\u{201D} If pressed, add: \u{201C}Just seeing how I feel without it.\u{201D} People respect experiments.",
            icon: "pause.circle.fill",
            color: .neonBlue
        ),
        RefusalScript(
            id: "morning",
            title: "I\u{2019}ve got an early morning tomorrow.",
            style: "Excuse-based",
            context: "When you need a quick exit. Practical excuses are easy to deliver and hard to argue with.",
            fullScript: "Say: \u{201C}I\u{2019}ve got an early morning tomorrow, so I\u{2019}m keeping it clean tonight.\u{201D} Then redirect: \u{201C}But tell me about...\u{201D}",
            icon: "sunrise.fill",
            color: .neonPurple
        ),
        RefusalScript(
            id: "driving",
            title: "I\u{2019}m driving tonight.",
            style: "Practical reason",
            context: "A universally accepted reason. No one pushes back on safety.",
            fullScript: "Say: \u{201C}I\u{2019}m driving tonight, so I\u{2019}m passing.\u{201D} Simple, responsible, and conversation-ending.",
            icon: "car.fill",
            color: .neonMagenta
        ),
        RefusalScript(
            id: "doctor",
            title: "My doctor told me to stop.",
            style: "Authority-based",
            context: "When you need a strong, unchallengeable reason. Medical advice is rarely questioned.",
            fullScript: "Say: \u{201C}My doctor told me to cut it out for a while.\u{201D} If asked why: \u{201C}Just some health stuff \u{2014} nothing serious.\u{201D} End of discussion.",
            icon: "cross.case.fill",
            color: .neonOrange
        ),
        RefusalScript(
            id: "training",
            title: "I\u{2019}m training for something.",
            style: "Positive redirect",
            context: "Reframes your choice as a positive goal. People admire discipline.",
            fullScript: "Say: \u{201C}I\u{2019}m training for something right now, so I\u{2019}m keeping things clean.\u{201D} You don\u{2019}t have to say what \u{2014} your recovery IS the training.",
            icon: "figure.run",
            color: .neonGold
        ),
        RefusalScript(
            id: "promise",
            title: "I promised someone I wouldn\u{2019}t.",
            style: "Accountability",
            context: "Invoking a promise adds weight. It\u{2019}s harder for others to undermine a commitment to someone else.",
            fullScript: "Say: \u{201C}I promised someone important to me that I\u{2019}d stop.\u{201D} If pressed: \u{201C}And I intend to keep that promise.\u{201D} That someone can be yourself.",
            icon: "person.2.fill",
            color: .neonGreen
        ),
        RefusalScript(
            id: "boundary",
            title: "I just don\u{2019}t want to, but thanks.",
            style: "Confident boundary",
            context: "The most powerful refusal. No excuse, no justification \u{2014} just a clear boundary.",
            fullScript: "Say: \u{201C}I just don\u{2019}t want to, but thanks for offering.\u{201D} This is the hardest to say and the most liberating. You owe no one an explanation.",
            icon: "shield.fill",
            color: .neonCyan
        )
    ]

    private var practicedSet: Set<String> {
        Set(practicedScriptsRaw.split(separator: ",").map { String($0) })
    }

    private var practicedCount: Int {
        practicedSet.filter { id in scripts.contains { $0.id == id } }.count
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                mainContent
            }
        }
        .navigationTitle("Refusal Scripts")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Counter
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.neonGreen)
                    Text("\(practicedCount)/8 practiced")
                        .font(Typography.headline)
                        .foregroundColor(.appText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.neonGreen.opacity(0.12))
                .cornerRadius(20)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.horizontal, AppStyle.screenPadding)

            switch currentStep {
            case 0:
                scriptPickerStep
            case 1:
                scriptDetailStep
            default:
                practicedStep
            }
        }
    }

    // MARK: - Step 0: Script Picker

    private var scriptPickerStep: some View {
        ScrollView {
            VStack(spacing: AppStyle.spacing) {
                Spacer().frame(height: 12)

                Text("Choose a script to practice")
                    .font(Typography.title)
                    .foregroundColor(.appText)

                Text("Tap any card to learn and rehearse the refusal.")
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)

                ForEach(scripts) { script in
                    Button {
                        selectedScript = script
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = 1
                        }
                    } label: {
                        scriptCard(script: script)
                    }
                }

                // Finish button if all practiced
                if practicedCount == 8 {
                    Button {
                        withAnimation {
                            isComplete = true
                            confettiVisible = true
                        }
                    } label: {
                        Text("All Scripts Practiced!")
                    }
                    .buttonStyle(RainbowButtonStyle())
                    .padding(.top, 8)
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, AppStyle.screenPadding)
        }
    }

    private func scriptCard(script: RefusalScript) -> some View {
        let isPracticed = practicedSet.contains(script.id)
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(script.color.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: script.icon)
                    .font(.title3)
                    .foregroundColor(script.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(script.title)
                    .font(Typography.headline)
                    .foregroundColor(.appText)
                    .multilineTextAlignment(.leading)

                Text(script.style)
                    .font(Typography.caption)
                    .foregroundColor(.subtleText)
            }

            Spacer()

            if isPracticed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.neonGreen)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.subtleText.opacity(0.5))
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(isPracticed ? Color.neonGreen.opacity(0.3) : script.color.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: script.color.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Step 1: Script Detail

    private var scriptDetailStep: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                Spacer().frame(height: 20)

                if let script = selectedScript {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(script.color.opacity(0.12))
                            .frame(width: 80, height: 80)

                        Image(systemName: script.icon)
                            .font(.system(size: 36))
                            .foregroundColor(script.color)
                            .shadow(color: script.color.opacity(0.5), radius: 8, x: 0, y: 0)
                    }

                    // Title
                    Text(script.title)
                        .font(Typography.largeTitle)
                        .foregroundColor(.appText)
                        .multilineTextAlignment(.center)

                    Text(script.style)
                        .font(Typography.headline)
                        .foregroundColor(script.color)

                    // Context
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When to use this")
                            .font(Typography.headline)
                            .foregroundColor(.appText)

                        Text(script.context)
                            .font(Typography.body)
                            .foregroundColor(.subtleText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .neonCard(glow: script.color)

                    // Full script
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The Script")
                            .font(Typography.headline)
                            .foregroundColor(.appText)

                        Text(script.fullScript)
                            .font(Typography.body)
                            .foregroundColor(.appText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .rainbowCard()

                    // Practice button
                    Button {
                        markAsPracticed(script.id)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = 2
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("I\u{2019}ve practiced this")
                        }
                    }
                    .buttonStyle(RainbowButtonStyle())

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = 0
                            selectedScript = nil
                        }
                    } label: {
                        Text("Back to scripts")
                    }
                    .buttonStyle(SecondaryButtonStyle(color: script.color))
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, AppStyle.screenPadding)
        }
    }

    // MARK: - Step 2: Practiced Confirmation

    private var practicedStep: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            if let script = selectedScript {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.neonGreen)
                    .shadow(color: .neonGreen.opacity(0.4), radius: 12, x: 0, y: 0)

                Text("Script Practiced!")
                    .font(Typography.title)
                    .foregroundColor(.appText)

                Text("\u{201C}\(script.title)\u{201D}")
                    .font(Typography.headline)
                    .foregroundColor(script.color)

                Text("You\u{2019}ve rehearsed \(practicedCount) of 8 scripts.\nEach one makes saying no easier.")
                    .font(Typography.body)
                    .foregroundColor(.subtleText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = 0
                    selectedScript = nil
                }
            } label: {
                Text("Practice Another")
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.horizontal, AppStyle.screenPadding)

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Done")
            }
            .buttonStyle(SecondaryButtonStyle(color: .neonCyan))
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            Spacer()

            if confettiVisible {
                SparkleParticlesView(count: 40, colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold])
                    .frame(height: 200)
                    .transition(.opacity)
            }

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.neonGreen)
                .shadow(color: .neonGreen.opacity(0.5), radius: 16, x: 0, y: 0)
                .scaleEffect(confettiVisible ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: confettiVisible)

            Text("Well Done!")
                .font(Typography.largeTitle)
                .rainbowText()

            Text("You\u{2019}ve practiced all 8 refusal scripts.\nYou\u{2019}re prepared for any situation.")
                .font(Typography.body)
                .foregroundColor(.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppStyle.screenPadding)

            Spacer()

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Done")
            }
            .buttonStyle(RainbowButtonStyle())
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.bottom, AppStyle.largeSpacing)
        }
    }

    // MARK: - Helpers

    private func markAsPracticed(_ id: String) {
        var current = practicedSet
        current.insert(id)
        practicedScriptsRaw = current.joined(separator: ",")
    }
}

// MARK: - Refusal Script Model

private struct RefusalScript: Identifiable {
    let id: String
    let title: String
    let style: String
    let context: String
    let fullScript: String
    let icon: String
    let color: Color
}

struct RefusalScriptView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RefusalScriptView()
        }
        .preferredColorScheme(.dark)
    }
}
