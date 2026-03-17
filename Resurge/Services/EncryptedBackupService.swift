import Foundation
import CryptoKit
import CoreData

struct EncryptedBackupService {

    static func exportBackup(context: NSManagedObjectContext, passphrase: String) throws -> Data {
        // Serialize habits, logs, journal, cravings, achievements, settings to JSON dict
        var backup: [String: Any] = [:]
        backup["version"] = 1
        backup["exportedAt"] = ISO8601DateFormatter().string(from: Date())

        // Fetch and serialize each entity type
        let habitRequest: NSFetchRequest<CDHabit> = NSFetchRequest(entityName: "CDHabit")
        let habits = (try? context.fetch(habitRequest)) ?? []
        backup["habitCount"] = habits.count
        // ... more entities

        let jsonData = try JSONSerialization.data(withJSONObject: backup)

        // Derive key from passphrase
        let keyData = SHA256.hash(data: Data(passphrase.utf8))
        let key = SymmetricKey(data: keyData)

        // Encrypt
        let sealedBox = try AES.GCM.seal(jsonData, using: key)
        guard let combined = sealedBox.combined else {
            throw NSError(domain: "Backup", code: 1)
        }
        return combined
    }

    static func importBackup(data: Data, passphrase: String) throws -> [String: Any] {
        let keyData = SHA256.hash(data: Data(passphrase.utf8))
        let key = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        guard let json = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any] else {
            throw NSError(domain: "Backup", code: 2)
        }
        return json
    }
}
