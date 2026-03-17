import SwiftUI

struct WhyGoalsView: View {

    @Binding var reasonToQuit: String
    @Binding var goalPeriod: GoalPeriod

    let onNext: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Header
                VStack(spacing: 8) {
                    Text("Your Why")
                        .font(Typography.largeTitle)
                        .rainbowText()

                    Text("Knowing your reason makes all the difference when things get tough.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppStyle.largeSpacing)
                .padding(.horizontal, AppStyle.screenPadding)

                // Motivational quote
                HStack(spacing: AppStyle.spacing) {
                    Image(systemName: "quote.opening")
                        .font(.title2)
                        .foregroundColor(.neonGold)

                    Text("The secret of change is to focus all your energy not on fighting the old, but on building the new.")
                        .font(Typography.callout)
                        .foregroundColor(.appText)
                        .italic()
                }
                .padding()
                .background(Color.neonGold.opacity(0.08))
                .cornerRadius(AppStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                        .stroke(
                            LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                        .opacity(0.4)
                )
                .padding(.horizontal, AppStyle.screenPadding)

                // Reason to quit
                VStack(alignment: .leading, spacing: 6) {
                    Text("Why do you want to quit?")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)

                    TextEditor(text: $reasonToQuit)
                        .font(Typography.body)
                        .foregroundColor(.appText)
                        .frame(minHeight: 120)
                        .padding(8)
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
                }
                .padding(.horizontal, AppStyle.screenPadding)

                // Goal period picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Set your first goal")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)

                    Picker("Goal Period", selection: $goalPeriod) {
                        ForEach(GoalPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, AppStyle.screenPadding)

                // Goal description
                goalDescription
                    .padding(.horizontal, AppStyle.screenPadding)

                Spacer()
                    .frame(height: AppStyle.largeSpacing)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: - Goal Description

    private var goalDescription: some View {
        HStack(spacing: AppStyle.spacing) {
            Image(systemName: "target")
                .font(.title2)
                .foregroundColor(.neonMagenta)

            VStack(alignment: .leading, spacing: 4) {
                Text("Your Goal")
                    .font(Typography.headline)
                    .foregroundColor(.appText)

                Text(goalMessage)
                    .font(Typography.callout)
                    .foregroundColor(.subtleText)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.neonMagenta.opacity(0.08))
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(Color.neonMagenta.opacity(0.3), lineWidth: 1)
        )
    }

    private var goalMessage: String {
        switch goalPeriod {
        case .oneWeek:
            return "Start small. Seven days of freedom is a powerful first step."
        case .oneMonth:
            return "One month builds a real foundation. You will feel the difference."
        case .threeMonths:
            return "Ninety days rewires your brain. This is where lasting change begins."
        case .sixMonths:
            return "Half a year of growth. Your future self will thank you."
        case .oneYear:
            return "A full year. You are committing to a transformed life."
        }
    }
}

// MARK: - Preview

struct WhyGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        WhyGoalsView(
            reasonToQuit: .constant(""),
            goalPeriod: .constant(.oneMonth),
            onNext: {}
        )
    }
}
