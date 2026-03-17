import Foundation
import CoreData

/// Computes Spearman rank correlations between daily check-in fields
/// for a given habit's log entries.
struct CorrelationEngine {

    // MARK: - Types

    struct CorrelationResult {
        let field1: String
        let field2: String
        let coefficient: Double
        let strength: String
    }

    // MARK: - Public API

    /// Fetches the last 30 CDDailyLogEntry records for the habit and computes
    /// Spearman correlations between all pairs of check-in fields. Only pairs
    /// with |coefficient| >= 0.3 are returned.
    ///
    /// Returns an empty array if fewer than 5 entries are available.
    static func computeCorrelations(for habit: CDHabit) -> [CorrelationResult] {
        let logs = fetchRecentLogs(for: habit, limit: 30)
        guard logs.count >= 5 else { return [] }

        let fields: [(String, (CDDailyLogEntry) -> Double)] = [
            ("mood",         { Double($0.mood) }),
            ("stress",       { Double($0.stress) }),
            ("energy",       { Double($0.energy) }),
            ("sleepQuality", { Double($0.sleepQuality) }),
            ("loneliness",   { Double($0.loneliness) }),
            ("cravingToday", { Double($0.cravingToday) })
        ]

        var results: [CorrelationResult] = []

        for i in 0..<fields.count {
            for j in (i + 1)..<fields.count {
                let valuesA = logs.map { fields[i].1($0) }
                let valuesB = logs.map { fields[j].1($0) }

                let coeff = spearmanCorrelation(valuesA, valuesB)
                let absCoeff = abs(coeff)

                if absCoeff >= 0.3 {
                    let strength: String
                    if absCoeff >= 0.6 {
                        strength = "strong"
                    } else {
                        strength = "moderate"
                    }

                    results.append(CorrelationResult(
                        field1: fields[i].0,
                        field2: fields[j].0,
                        coefficient: coeff,
                        strength: strength
                    ))
                }
            }
        }

        return results
    }

    // MARK: - Spearman Correlation

    /// Computes the Spearman rank correlation coefficient between two arrays
    /// of equal length. Handles ties using average ranks.
    ///
    /// Returns 0 if the arrays have fewer than 2 elements.
    private static func spearmanCorrelation(_ a: [Double], _ b: [Double]) -> Double {
        let n = a.count
        guard n >= 2 else { return 0 }

        let ranksA = averageRanks(a)
        let ranksB = averageRanks(b)

        return pearsonCorrelation(ranksA, ranksB)
    }

    /// Computes average ranks for a series of values. Tied values receive the
    /// mean of the positions they would occupy.
    private static func averageRanks(_ values: [Double]) -> [Double] {
        let n = values.count
        // Pair each value with its original index, then sort by value.
        let indexed = values.enumerated()
            .sorted { $0.element < $1.element }

        var ranks = [Double](repeating: 0, count: n)
        var i = 0

        while i < n {
            var j = i
            // Find the range of tied values.
            while j < n - 1 && indexed[j + 1].element == indexed[j].element {
                j += 1
            }
            // Average rank for positions i...j (1-based).
            let avgRank = Double(i + j) / 2.0 + 1.0
            for k in i...j {
                ranks[indexed[k].offset] = avgRank
            }
            i = j + 1
        }

        return ranks
    }

    /// Standard Pearson correlation coefficient on two arrays of equal length.
    private static func pearsonCorrelation(_ x: [Double], _ y: [Double]) -> Double {
        let n = Double(x.count)
        guard n >= 2 else { return 0 }

        let meanX = x.reduce(0, +) / n
        let meanY = y.reduce(0, +) / n

        var sumXY = 0.0
        var sumX2 = 0.0
        var sumY2 = 0.0

        for i in 0..<x.count {
            let dx = x[i] - meanX
            let dy = y[i] - meanY
            sumXY += dx * dy
            sumX2 += dx * dx
            sumY2 += dy * dy
        }

        let denominator = (sumX2 * sumY2).squareRoot()
        guard denominator > 0 else { return 0 }

        return sumXY / denominator
    }

    // MARK: - Data Fetching

    /// Fetches the most recent `limit` CDDailyLogEntry records for the given
    /// habit, sorted by date descending, using NSFetchRequest with entityName.
    private static func fetchRecentLogs(for habit: CDHabit, limit: Int) -> [CDDailyLogEntry] {
        guard let context = habit.managedObjectContext else { return [] }

        let request = NSFetchRequest<CDDailyLogEntry>(entityName: "CDDailyLogEntry")
        request.predicate = NSPredicate(format: "habit == %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = limit

        do {
            let entries = try context.fetch(request)
            // Return in chronological order for correlation computation.
            return entries.reversed()
        } catch {
            return []
        }
    }
}
