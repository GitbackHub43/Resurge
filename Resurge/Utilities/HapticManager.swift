import UIKit

enum HapticManager {

    /// Double haptic for achievements: success notification + heavy impact.
    static func achievement() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)

        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }

    /// Medium impact for pledges and confirmations.
    static func pledge() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    /// Success notification for resisting a craving.
    static func resisted() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }

    /// Warning notification for lapses.
    static func lapse() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.warning)
    }

    /// Light impact for general taps and selections.
    static func tap() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}
