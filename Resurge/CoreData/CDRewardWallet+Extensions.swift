import Foundation
import CoreData

@objc(CDRewardWallet)
public class CDRewardWallet: NSManagedObject, Identifiable {

    // MARK: - Managed Properties

    @NSManaged public var id: UUID
    @NSManaged public var shardsBalance: Int64
    @NSManaged public var lifetimeEarned: Int64

    // MARK: - Fetch-or-Create Singleton

    static func fetchOrCreate(in context: NSManagedObjectContext) -> CDRewardWallet {
        let request: NSFetchRequest<CDRewardWallet> = NSFetchRequest(entityName: "CDRewardWallet")
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let wallet = CDRewardWallet(context: context)
        wallet.id = UUID()
        wallet.shardsBalance = 0
        wallet.lifetimeEarned = 0

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Failed to save new CDRewardWallet: \(nsError), \(nsError.userInfo)")
        }

        return wallet
    }
}
