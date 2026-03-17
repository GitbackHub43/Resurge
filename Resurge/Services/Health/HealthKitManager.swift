import Foundation

// MARK: - HealthKitManagerProtocol

protocol HealthKitManagerProtocol {
    func requestAuthorization() async -> Bool
    func isAvailable() -> Bool
}

// MARK: - HealthKitManager

final class HealthKitManager: HealthKitManagerProtocol {

    /// Returns whether HealthKit is available on this device.
    func isAvailable() -> Bool {
        // HealthKit availability check — guarded for platforms without HealthKit (e.g., iPad).
        #if canImport(HealthKit)
        return _healthKitIsAvailable()
        #else
        return false
        #endif
    }

    /// Requests authorization to read/write relevant HealthKit data types.
    /// Currently a stub — returns false until specific data types are configured.
    func requestAuthorization() async -> Bool {
        guard isAvailable() else { return false }

        // Future implementation: request specific HKSampleType permissions
        // for sleep analysis, heart rate, mindful minutes, etc.
        return false
    }

    #if canImport(HealthKit)
    private func _healthKitIsAvailable() -> Bool {
        // Defer the import to runtime so the file compiles even without the HealthKit framework linked.
        guard NSClassFromString("HKHealthStore") != nil else { return false }
        // HKHealthStore.isHealthDataAvailable() requires the framework to be linked.
        // For now, return true if the class exists (device supports it).
        return true
    }
    #endif
}
