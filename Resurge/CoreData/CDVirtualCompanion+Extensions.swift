import Foundation
import CoreData

@objc(CDVirtualCompanion)
public class CDVirtualCompanion: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var species: String
    @NSManaged public var level: Int32
    @NSManaged public var xp: Int32
    @NSManaged public var currentMood: String
    @NSManaged public var equippedCosmetics: String?
    @NSManaged public var createdAt: Date

    // MARK: - Convenience Initializer Helper

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        name: String,
        species: String
    ) -> CDVirtualCompanion {
        let companion = CDVirtualCompanion(context: context)
        companion.id = UUID()
        companion.name = name
        companion.species = species
        companion.level = 1
        companion.xp = 0
        companion.currentMood = "happy"
        companion.equippedCosmetics = nil
        companion.createdAt = Date()
        return companion
    }
}
