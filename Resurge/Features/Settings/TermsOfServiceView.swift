import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppStyle.largeSpacing) {
                Text("Terms of Service")
                    .font(Typography.largeTitle)
                    .rainbowText()

                Text("Last updated: March 2026")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)

                section(title: "Acceptance of Terms", body: """
                By downloading, installing, or using Resurge, you agree to these Terms of Service. If you do not agree, please do not use the app.
                """)

                section(title: "Description of Service", body: """
                Resurge is a personal habit and addiction recovery tracking app. It provides tools for tracking sobriety, logging cravings, journaling, setting goals, and monitoring progress. Resurge is a self-help tool and is not a substitute for professional medical advice, diagnosis, or treatment.
                """)

                section(title: "Not Medical Advice", body: """
                Resurge is not a medical device and does not provide medical advice. The content, tools, and features in this app are for informational and motivational purposes only.

                If you are experiencing a medical emergency, substance withdrawal, or mental health crisis, please contact emergency services (911) or a qualified healthcare provider immediately.

                Always seek the advice of a qualified health professional with any questions you may have regarding a medical condition or treatment.
                """)

                section(title: "User Responsibilities", body: """
                You are responsible for maintaining the confidentiality of your device and any data stored within the app. You agree to use the app only for lawful purposes and in accordance with these terms.
                """)

                section(title: "Subscriptions & Payments", body: """
                Resurge offers optional premium subscriptions (Monthly, Yearly, and Lifetime) that unlock additional features. Subscriptions are processed through the Apple App Store.

                - Payment is charged to your Apple ID account at confirmation of purchase.
                - Monthly and yearly subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.
                - You can manage or cancel subscriptions in your Apple ID account settings.
                - No refunds are provided for partial subscription periods.
                - The Lifetime purchase is a one-time payment and does not renew.
                """)

                section(title: "Free Tier", body: """
                The free version of Resurge includes tracking for 1 habit, basic check-ins, journaling, craving tools, and basic achievements. Premium features require a paid subscription.
                """)

                section(title: "Intellectual Property", body: """
                All content, design, code, graphics, and other materials in Resurge are owned by Resurge and protected by copyright and intellectual property laws. You may not copy, modify, distribute, or reverse engineer any part of the app.
                """)

                section(title: "Disclaimer of Warranties", body: """
                Resurge is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not guarantee that the app will be error-free, uninterrupted, or free of harmful components.
                """)

                section(title: "Limitation of Liability", body: """
                To the maximum extent permitted by law, Resurge and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the app.
                """)

                section(title: "Termination", body: """
                We reserve the right to terminate or restrict access to the app at any time, for any reason, without notice. Upon termination, your right to use the app ceases immediately.
                """)

                section(title: "Changes to Terms", body: """
                We may modify these terms at any time. Continued use of the app after changes constitutes acceptance of the updated terms.
                """)

                section(title: "Contact", body: """
                If you have questions about these terms, you can reach us at support@resurgeapp.com.
                """)
            }
            .padding(AppStyle.screenPadding)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(.textPrimary)

            Text(body)
                .font(Typography.body)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
