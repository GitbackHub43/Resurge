import Foundation

// MARK: - Recovery Phase

enum RecoveryPhase: String, CaseIterable {
    case detox          // days 1-7
    case building       // days 8-30
    case strengthening  // days 31-90
    case maintaining    // days 91+

    var displayName: String {
        switch self {
        case .detox:          return "Detox"
        case .building:       return "Building"
        case .strengthening:  return "Strengthening"
        case .maintaining:    return "Maintaining"
        }
    }

    static func phase(for daysSober: Int) -> RecoveryPhase {
        switch daysSober {
        case 0...7:    return .detox
        case 8...30:   return .building
        case 31...90:  return .strengthening
        default:       return .maintaining
        }
    }
}

// MARK: - Daily Challenge

struct DailyChallenge: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let phase: RecoveryPhase
}
