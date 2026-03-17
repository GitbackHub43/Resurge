import Foundation

enum CravingToolKind: Codable, Hashable, Identifiable {
    case breathing
    case puzzle
    case quotes
    case journaling
    case bodyOverride
    case urgeDefusion
    case urgeLog
    case copingSimulator
    case refusalScript
    case futureThinking
    case approachBias
    case focusShift
    case cravingLab
    case valuesCompass
    case programSpecific(String)

    var id: String {
        switch self {
        case .breathing:               return "breathing"
        case .puzzle:                  return "puzzle"
        case .quotes:                  return "quotes"
        case .journaling:              return "journaling"
        case .bodyOverride:            return "bodyOverride"
        case .urgeDefusion:            return "urgeDefusion"
        case .urgeLog:                 return "urgeLog"
        case .copingSimulator:         return "copingSimulator"
        case .refusalScript:           return "refusalScript"
        case .futureThinking:          return "futureThinking"
        case .approachBias:            return "approachBias"
        case .focusShift:              return "focusShift"
        case .cravingLab:              return "cravingLab"
        case .valuesCompass:           return "valuesCompass"
        case .programSpecific(let s):  return "programSpecific_\(s)"
        }
    }

    var displayName: String {
        switch self {
        case .breathing:        return "Breathing Exercise"
        case .puzzle:           return "Distraction Puzzle"
        case .quotes:           return "Motivational Quotes"
        case .journaling:       return "Quick Journal"
        case .bodyOverride:     return "Body Override"
        case .urgeDefusion:     return "Urge Defusion"
        case .urgeLog:          return "Urge Log"
        case .copingSimulator:  return "Coping Simulator"
        case .refusalScript:    return "Refusal Scripts"
        case .futureThinking:   return "Time Portal"
        case .approachBias:     return "Bias Training"
        case .focusShift:       return "Focus Shift"
        case .cravingLab:       return "Craving Lab"
        case .valuesCompass:    return "Values Compass"
        case .programSpecific(let s): return s
        }
    }

    var iconName: String {
        switch self {
        case .breathing:        return "wind"
        case .puzzle:           return "puzzlepiece.fill"
        case .quotes:           return "quote.bubble.fill"
        case .journaling:       return "pencil.and.scribble"
        case .bodyOverride:     return "bolt.heart.fill"
        case .urgeDefusion:     return "person.fill.xmark"
        case .urgeLog:          return "chart.line.uptrend.xyaxis"
        case .copingSimulator:  return "theatermasks.fill"
        case .refusalScript:    return "text.bubble.fill"
        case .futureThinking:   return "sparkles.rectangle.stack.fill"
        case .approachBias:     return "hand.draw.fill"
        case .focusShift:       return "eye.trianglebadge.exclamationmark.fill"
        case .cravingLab:       return "waveform.path.ecg"
        case .valuesCompass:    return "compass.drawing"
        case .programSpecific:  return "star.fill"
        }
    }

    var description: String {
        switch self {
        case .breathing:
            return "A guided breathing exercise to ride out the craving wave."
        case .puzzle:
            return "A quick puzzle to redirect your focus and let the urge pass."
        case .quotes:
            return "Read motivational quotes to remind yourself why you started."
        case .journaling:
            return "Write down what you are feeling right now."
        case .bodyOverride:
            return "TIPP protocol: cold, movement, breathing, and muscle relaxation to override the urge."
        case .urgeDefusion:
            return "Defuse the urge by treating it as a salesman you can talk back to."
        case .urgeLog:
            return "Log your urge in 10 seconds and discover your craving patterns."
        case .copingSimulator:
            return "Practice handling real-world scenarios with healthy choices."
        case .refusalScript:
            return "Rehearse saying no with proven refusal scripts."
        case .futureThinking:
            return "Create vivid scenes of your recovered future self."
        case .approachBias:
            return "Train your brain to push away triggers and pull toward health."
        case .focusShift:
            return "Sharpen your attention by spotting the difference in a grid."
        case .cravingLab:
            return "Observe your craving like a scientist — scan, label, and surf it."
        case .valuesCompass:
            return "Reconnect with your values and choose one tiny action right now."
        case .programSpecific(let name):
            return "A coping tool designed for \(name)."
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type, value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .programSpecific(let value):
            try container.encode("programSpecific", forKey: .type)
            try container.encode(value, forKey: .value)
        default:
            try container.encode(id, forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "breathing":        self = .breathing
        case "puzzle":           self = .puzzle
        case "quotes":           self = .quotes
        case "journaling":       self = .journaling
        case "bodyOverride":     self = .bodyOverride
        case "urgeDefusion":     self = .urgeDefusion
        case "urgeLog":          self = .urgeLog
        case "copingSimulator":  self = .copingSimulator
        case "refusalScript":    self = .refusalScript
        case "futureThinking":   self = .futureThinking
        case "approachBias":     self = .approachBias
        case "focusShift":       self = .focusShift
        case "cravingLab":       self = .cravingLab
        case "valuesCompass":    self = .valuesCompass
        case "programSpecific":
            let value = try container.decode(String.self, forKey: .value)
            self = .programSpecific(value)
        default:
            self = .programSpecific(type)
        }
    }
}
