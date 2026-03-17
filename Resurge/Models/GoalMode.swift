import Foundation

enum GoalMode: String, CaseIterable, Codable {
    case abstain
    case reduce
    case moderate
    case delay
    case replace
    case maintain

    var displayName: String {
        switch self {
        case .abstain: return "Abstain Completely"
        case .reduce: return "Reduce Usage"
        case .moderate: return "Moderate Usage"
        case .delay: return "Delay & Postpone"
        case .replace: return "Replace with Alternative"
        case .maintain: return "Maintain Progress"
        }
    }

    var description: String {
        switch self {
        case .abstain: return "Stop entirely and stay free."
        case .reduce: return "Gradually lower your usage over time."
        case .moderate: return "Use within safe, pre-set limits."
        case .delay: return "Push back urges and extend gaps between use."
        case .replace: return "Swap the habit for a healthier alternative."
        case .maintain: return "Keep your current progress steady."
        }
    }
}

enum MeasurementMode: String, CaseIterable, Codable {
    case binary
    case quantity
    case duration
    case mixed

    var displayName: String {
        switch self {
        case .binary: return "Yes / No"
        case .quantity: return "Count Units"
        case .duration: return "Track Duration"
        case .mixed: return "Count + Duration"
        }
    }
}

enum SafetyLevel: String, CaseIterable, Codable {
    case low
    case medium
    case high

    var displayName: String {
        switch self {
        case .low: return "Low Risk"
        case .medium: return "Medium Risk"
        case .high: return "High Risk"
        }
    }

    var description: String {
        switch self {
        case .low: return "Mild habit with low health impact."
        case .medium: return "Moderate habit requiring consistent effort."
        case .high: return "Serious addiction needing strong support."
        }
    }
}

enum EventType: String, CaseIterable, Codable {
    case useEpisode = "USE_EPISODE"
    case urgeEpisode = "URGE_EPISODE"
    case resistedUrge = "RESISTED_URGE"
    case focusSession = "FOCUS_SESSION"
    case copingToolUsed = "COPING_TOOL_USED"
    case lapseReview = "LAPSE_REVIEW"
    case noteOnly = "NOTE_ONLY"

    var displayName: String {
        switch self {
        case .useEpisode: return "Use Episode"
        case .urgeEpisode: return "Urge Episode"
        case .resistedUrge: return "Resisted Urge"
        case .focusSession: return "Focus Session"
        case .copingToolUsed: return "Coping Tool Used"
        case .lapseReview: return "Lapse Review"
        case .noteOnly: return "Note"
        }
    }
}

enum EventOutcome: String, CaseIterable, Codable {
    case resisted
    case used
    case partial
    case unknown

    var displayName: String {
        switch self {
        case .resisted: return "Resisted"
        case .used: return "Used"
        case .partial: return "Partial"
        case .unknown: return "Unknown"
        }
    }
}
