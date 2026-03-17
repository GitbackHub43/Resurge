import Foundation
import SwiftUI

enum MoodState: Int, CaseIterable, Codable, Identifiable {
    case terrible = 1
    case bad = 2
    case neutral = 3
    case good = 4
    case great = 5

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .terrible: return "Terrible"
        case .bad:      return "Bad"
        case .neutral:  return "Neutral"
        case .good:     return "Good"
        case .great:    return "Great"
        }
    }

    var emoji: String {
        switch self {
        case .terrible: return "😞"
        case .bad:      return "😕"
        case .neutral:  return "😐"
        case .good:     return "🙂"
        case .great:    return "😄"
        }
    }

    var color: Color {
        switch self {
        case .terrible: return Color(red: 0.91, green: 0.30, blue: 0.24)
        case .bad:      return Color(red: 0.90, green: 0.49, blue: 0.13)
        case .neutral:  return Color(red: 0.95, green: 0.77, blue: 0.06)
        case .good:     return Color(red: 0.18, green: 0.80, blue: 0.44)
        case .great:    return Color(red: 0.10, green: 0.74, blue: 0.61)
        }
    }
}
