import Foundation
import LocalAuthentication

// MARK: - BiometricType

enum BiometricType {
    case faceID
    case touchID
    case none
}

// MARK: - BiometricLockManager

final class BiometricLockManager {

    // MARK: - Can Use Biometrics

    func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    // MARK: - Authenticate

    func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        context.localizedCancelTitle = "Cancel"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock LoopRoot to access your private data."
            )
            return success
        } catch {
            print("Biometric authentication failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Biometric Type

    func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
}
