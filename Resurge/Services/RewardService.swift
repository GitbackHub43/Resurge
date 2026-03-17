import CoreData

final class RewardService {

    func awardShards(for action: ShardAction, context: NSManagedObjectContext) {
        let wallet = CDRewardWallet.fetchOrCreate(in: context)
        wallet.shardsBalance += Int64(action.shards)
        wallet.lifetimeEarned += Int64(action.shards)
        CDRewardTransaction.create(
            in: context,
            actionType: action.rawValue,
            amount: Int32(action.shards),
            reason: action.displayName,
            habitID: nil
        )
        try? context.save()
        UserDefaults.standard.set(Int(wallet.shardsBalance), forKey: "shardBalance")
    }

    func spendShards(amount: Int, reason: String, context: NSManagedObjectContext) -> Bool {
        let wallet = CDRewardWallet.fetchOrCreate(in: context)
        guard wallet.shardsBalance >= Int64(amount) else { return false }
        wallet.shardsBalance -= Int64(amount)
        CDRewardTransaction.create(
            in: context,
            actionType: "spend",
            amount: Int32(-amount),
            reason: reason,
            habitID: nil
        )
        try? context.save()
        UserDefaults.standard.set(Int(wallet.shardsBalance), forKey: "shardBalance")
        return true
    }

    func balance(context: NSManagedObjectContext) -> (shards: Int64, lifetime: Int64) {
        let w = CDRewardWallet.fetchOrCreate(in: context)
        return (w.shardsBalance, w.lifetimeEarned)
    }
}
