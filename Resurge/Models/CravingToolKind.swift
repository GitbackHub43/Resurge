import Foundation

enum CravingToolKind: Codable, Hashable, Identifiable {
    case breathing
    case puzzle
    case quotes
    case journaling
    case bodyOverride
    case urgeDefusion
    case copingSimulator
    case futureThinking
    case focusShift
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
        case .copingSimulator:         return "copingSimulator"
        case .futureThinking:          return "futureThinking"
        case .focusShift:              return "focusShift"
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
        case .copingSimulator:  return "Coping Simulator"
        case .futureThinking:   return "Time Portal"
        case .focusShift:       return "Focus Shift"
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
        case .urgeDefusion:     return "brain.head.profile"
        case .copingSimulator:  return "theatermasks.fill"
        case .futureThinking:   return "sparkles.rectangle.stack.fill"
        case .focusShift:       return "eye.trianglebadge.exclamationmark.fill"
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
        case .copingSimulator:
            return "Practice handling real-world scenarios with healthy choices."
        case .futureThinking:
            return "Create vivid scenes of your recovered future self."
        case .focusShift:
            return "Sharpen your attention by spotting the difference in a grid."
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
        case "copingSimulator":  self = .copingSimulator
        case "futureThinking":   self = .futureThinking
        case "focusShift":       self = .focusShift
        case "valuesCompass":    self = .valuesCompass
        case "programSpecific":
            let value = try container.decode(String.self, forKey: .value)
            self = .programSpecific(value)
        default:
            self = .programSpecific(type)
        }
    }
}

// MARK: - Tool Usage Tracking

import CoreData

/// Records a standalone tool completion for analytics tracking.
/// Creates a minimal CDCravingEntry with the tool ID so it shows in Tool Effectiveness.
func trackToolCompletion(toolId: String, didResist: Bool = true, context: NSManagedObjectContext) {
    // Find the habit from the selectedToolHabitId set when launching from toolkit
    guard let habitIdString = UserDefaults.standard.string(forKey: "selectedToolHabitId"),
          let habitId = UUID(uuidString: habitIdString) else { return }

    let habitRequest = NSFetchRequest<CDHabit>(entityName: "CDHabit")
    habitRequest.predicate = NSPredicate(format: "id == %@", habitId as CVarArg)
    guard let habit = (try? context.fetch(habitRequest))?.first else { return }

    let intensity = Int16(UserDefaults.standard.integer(forKey: "lastToolIntensity"))
    CDCravingEntry.create(
        in: context,
        habit: habit,
        intensity: intensity > 0 ? intensity : 5,
        triggerCategory: nil,
        triggerNote: nil,
        copingToolUsed: toolId,
        didResist: didResist,
        durationSeconds: 0
    )
    try? context.save()
}
