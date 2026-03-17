import SwiftUI

struct DisclaimerView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppStyle.largeSpacing) {

                    // Header
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.neonOrange)
                        Text("Important Disclaimer")
                            .font(Typography.title)
                            .foregroundColor(.textPrimary)
                    }

                    // Medical advice disclaimer
                    disclaimerCard(
                        icon: "cross.circle.fill",
                        color: .neonMagenta,
                        title: "Not Medical Advice",
                        body: "This app does not provide medical advice, diagnosis, or treatment. The content is for informational and educational purposes only. Always seek the advice of a qualified health provider with any questions you may have regarding a medical condition or treatment."
                    )

                    // Withdrawal warning
                    disclaimerCard(
                        icon: "exclamationmark.octagon.fill",
                        color: .neonOrange,
                        title: "Withdrawal Warning",
                        body: "Withdrawal from alcohol or benzodiazepines can be life-threatening. Do not attempt to stop using these substances abruptly without medical supervision. If you experience seizures, severe tremors, hallucinations, or confusion, seek emergency medical help immediately."
                    )

                    // Crisis resources
                    disclaimerCard(
                        icon: "phone.fill",
                        color: .neonCyan,
                        title: "Crisis Resources",
                        body: "If you are in crisis or experiencing a medical emergency, please contact emergency services immediately.\n\n988 Suicide & Crisis Lifeline: Call or text 988\n\nSAMHSA National Helpline: 1-800-662-4357\n(Free, confidential, 24/7 treatment referral and information)\n\nEmergency: Call 911"
                    )

                    Spacer().frame(height: AppStyle.largeSpacing)
                }
                .padding(.horizontal, AppStyle.screenPadding)
                .padding(.top, AppStyle.spacing)
            }
        }
        .navigationTitle("Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func disclaimerCard(icon: String, color: Color, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.textPrimary)
            }

            Text(body)
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
        }
        .padding(AppStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DisclaimerView()
        }
        .preferredColorScheme(.dark)
    }
}
