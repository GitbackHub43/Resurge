import Foundation

enum ShardAction: String, CaseIterable {
    case morningPlan
    case cravingProtocol
    case cravingProtocolHigh
    case urgeLog
    case worksheet
    case lapseFlow
    case eveningReview
    case toolCompleted

    var shards: Int {
        switch self {
        case .morningPlan:          return 5
        case .cravingProtocol:      return 10
        case .cravingProtocolHigh:  return 15
        case .urgeLog:              return 3
        case .worksheet:            return 5
        case .lapseFlow:            return 15
        case .eveningReview:        return 5
        case .toolCompleted:        return 5
        }
    }

    var displayName: String {
        switch self {
        case .morningPlan:          return "Morning Plan"
        case .cravingProtocol:      return "Craving Protocol"
        case .cravingProtocolHigh:  return "Craving Protocol (High)"
        case .urgeLog:              return "Urge Log"
        case .worksheet:            return "Worksheet"
        case .lapseFlow:            return "Lapse Flow"
        case .eveningReview:        return "Evening Review"
        case .toolCompleted:        return "Tool Completed"
        }
    }
}

struct ShardTransaction: Codable, Identifiable {
    var id = UUID()
    let action: String
    let amount: Int
    let date: Date
}
