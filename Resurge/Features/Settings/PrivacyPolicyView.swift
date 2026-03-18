import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppStyle.largeSpacing) {
                Text("Privacy Policy")
                    .font(Typography.largeTitle)
                    .rainbowText()

                Text("Last updated: March 2026")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)

                section(title: "Your Privacy Matters", body: """
                LoopRoot is designed with your privacy as a top priority. We understand that recovery is deeply personal, and we built this app to keep your data safe and private.
                """)

                section(title: "Data Storage", body: """
                All your data is stored locally on your device using Core Data. This includes your habits, daily logs, journal entries, craving records, achievements, and settings.

                We do not have servers. We do not collect your data. We cannot see your data. Period.
                """)

                section(title: "No Account Required", body: """
                LoopRoot does not require you to create an account, provide an email address, or sign in with any service. You can use the app completely anonymously.
                """)

                section(title: "No Tracking or Analytics", body: """
                We do not use any third-party analytics, tracking, or advertising SDKs. We do not track your behavior, location, or usage patterns. There are no cookies, no fingerprinting, and no data brokers.
                """)

                section(title: "In-App Purchases", body: """
                If you purchase a premium subscription, the transaction is handled entirely by Apple through the App Store. We do not process, store, or have access to your payment information.

                Apple may share a transaction receipt with us to verify your subscription status. This contains no personal information.
                """)

                section(title: "Notifications", body: """
                If you enable notifications, they are scheduled locally on your device. No notification data is sent to any server.
                """)

                section(title: "Biometric Data", body: """
                If you enable Face ID or Touch ID for privacy locks, authentication is handled entirely by iOS. We never access, store, or transmit biometric data.
                """)

                section(title: "Data Deletion", body: """
                You can delete all your data at any time by deleting the app from your device. Since all data is stored locally, deleting the app permanently removes everything.
                """)

                section(title: "Children's Privacy", body: """
                LoopRoot is not directed at children under 13. We do not knowingly collect data from children.
                """)

                section(title: "Changes to This Policy", body: """
                We may update this policy from time to time. Any changes will be reflected in the app with an updated date.
                """)

                section(title: "Contact", body: """
                If you have questions about this privacy policy, you can reach us at support@looprootapp.com.
                """)
            }
            .padding(AppStyle.screenPadding)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Privacy Policy")
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
