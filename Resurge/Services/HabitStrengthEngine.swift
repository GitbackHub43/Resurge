import SwiftUI

struct HabitStrengthEngine {

    // MARK: - Strength Calculation

    /// Calculate habit strength (0-100%) based on recovery metrics.
    ///
    /// Algorithm:
    /// - Base: daysSober * 3 (capped at 100)
    /// - Each lapse reduces strength by 10
    /// - Days since last lapse bonus: +1 per day (up to 20)
    /// - Result is clamped to 0...100
    static func calculateStrength(
        daysSober: Int,
        totalLapses: Int,
        daysSinceLastLapse: Int?
    ) -> Double {
        // Base score: 3 points per sober day, max 100
        let base = min(Double(daysSober) * 3.0, 100.0)

        // Lapse penalty: -10 per lapse
        let lapsePenalty = Double(totalLapses) * 10.0

        // Recovery bonus: +1 per day since last lapse, max 20
        let recoveryBonus: Double
        if let daysSince = daysSinceLastLapse {
            recoveryBonus = min(Double(daysSince), 20.0)
        } else {
            recoveryBonus = 0
        }

        let raw = base - lapsePenalty + recoveryBonus
        return min(max(raw, 0), 100)
    }

    // MARK: - Strength Color

    /// Returns a color representing the strength level.
    /// - 0-30: neonOrange (weak)
    /// - 30-70: neonGold (building)
    /// - 70-100: neonGreen (strong)
    static func strengthColor(_ strength: Double) -> Color {
        if strength < 30 {
            return .neonOrange
        } else if strength < 70 {
            return .neonGold
        } else {
            return .neonGreen
        }
    }

    // MARK: - Strength Label

    /// Returns a human-readable label for the strength level.
    static func strengthLabel(_ strength: Double) -> String {
        if strength < 30 {
            return "Building"
        } else if strength < 70 {
            return "Growing"
        } else {
            return "Strong"
        }
    }
}
