import Foundation

enum TriggerType: Codable, Hashable, Identifiable {
    case stress
    case boredom
    case social
    case emotional
    case environmental
    case routine
    case celebration
    case loneliness
    case anxiety
    case anger
    case tiredness
    case hunger
    case custom(String)

    var id: String {
        switch self {
        case .custom(let value): return "custom_\(value)"
        default: return String(describing: self)
        }
    }

    var displayName: String {
        switch self {
        case .stress:          return "Stress"
        case .boredom:         return "Boredom"
        case .social:          return "Social Pressure"
        case .emotional:       return "Emotional"
        case .environmental:   return "Environmental"
        case .routine:         return "Routine"
        case .celebration:     return "Celebration"
        case .loneliness:      return "Loneliness"
        case .anxiety:         return "Anxiety"
        case .anger:           return "Anger"
        case .tiredness:       return "Tiredness"
        case .hunger:          return "Hunger"
        case .custom(let val): return val
        }
    }

    var iconName: String {
        switch self {
        case .stress:        return "bolt.heart.fill"
        case .boredom:       return "clock.fill"
        case .social:        return "person.2.fill"
        case .emotional:     return "heart.fill"
        case .environmental: return "building.2.fill"
        case .routine:       return "arrow.triangle.2.circlepath"
        case .celebration:   return "party.popper.fill"
        case .loneliness:    return "person.fill.questionmark"
        case .anxiety:       return "waveform.path.ecg"
        case .anger:         return "flame.fill"
        case .tiredness:     return "powersleep"
        case .hunger:        return "fork.knife"
        case .custom:        return "tag.fill"
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type, value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .custom(let value):
            try container.encode("custom", forKey: .type)
            try container.encode(value, forKey: .value)
        default:
            try container.encode(String(describing: self), forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "stress":        self = .stress
        case "boredom":       self = .boredom
        case "social":        self = .social
        case "emotional":     self = .emotional
        case "environmental": self = .environmental
        case "routine":       self = .routine
        case "celebration":   self = .celebration
        case "loneliness":    self = .loneliness
        case "anxiety":       self = .anxiety
        case "anger":         self = .anger
        case "tiredness":     self = .tiredness
        case "hunger":        self = .hunger
        case "custom":
            let value = try container.decode(String.self, forKey: .value)
            self = .custom(value)
        default:
            self = .custom(type)
        }
    }

    /// All standard (non-custom) trigger types.
    static var allStandard: [TriggerType] {
        [.stress, .boredom, .social, .emotional, .environmental,
         .routine, .celebration, .loneliness, .anxiety, .anger,
         .tiredness, .hunger]
    }
}
