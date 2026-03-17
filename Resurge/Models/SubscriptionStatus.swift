import Foundation

enum SubscriptionStatus: String, Codable, CaseIterable, Identifiable {
    case free
    case trial
    case monthly
    case yearly
    case lifetime

    var id: String { rawValue }

    var isPremium: Bool {
        switch self {
        case .free:
            return false
        case .trial, .monthly, .yearly, .lifetime:
            return true
        }
    }

    var isPaid: Bool {
        self != .free
    }

    var displayName: String {
        switch self {
        case .free:     return "Free"
        case .trial:    return "Trial"
        case .monthly:  return "Monthly"
        case .yearly:   return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }
}
