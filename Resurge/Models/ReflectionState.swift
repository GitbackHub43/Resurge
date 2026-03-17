import Foundation

enum ReflectionState: String, Codable, CaseIterable, Identifiable {
    case pending
    case completed
    case skipped

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pending:   return "Pending"
        case .completed: return "Completed"
        case .skipped:   return "Skipped"
        }
    }
}
