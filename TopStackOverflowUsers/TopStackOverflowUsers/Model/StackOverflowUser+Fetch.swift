//
//  StackOverflowUser+Fetch.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import CoreData

extension StackOverflowUser {
    static func usersFetchRequest() -> NSFetchRequest<StackOverflowUser> {
        let fetchRequest = StackOverflowUser.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "reputation", ascending: false)]
        return fetchRequest
    }

    static func fetchUser(withAccountID accountID: Int, in context: NSManagedObjectContext) throws -> StackOverflowUser? {
        let fetchRequest = StackOverflowUser.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "accountId == %d", accountID)
        return try context.fetch(fetchRequest).first
    }

    static func store(_ users: [TopUser], in context: NSManagedObjectContext) throws {
        for user in users {
            let managedUser = try fetchUser(withAccountID: user.accountId, in: context)
                ?? StackOverflowUser(context: context)

            managedUser.accountId = Int64(user.accountId)
            managedUser.displayName = user.displayName
            managedUser.profileImageURL = user.profileImage
            managedUser.reputation = Int64(user.reputation)
        }

        if context.hasChanges {
            try context.save()
        }
    }

    static func imageData(forAccountID accountID: Int, in context: NSManagedObjectContext) throws -> Data? {
        try fetchUser(withAccountID: accountID, in: context)?.image
    }

    static func profileImageURL(forAccountID accountID: Int, in context: NSManagedObjectContext) throws -> String? {
        try fetchUser(withAccountID: accountID, in: context)?.profileImageURL
    }

    static func storeImageData(
        _ imageData: Data,
        forAccountID accountID: Int,
        in context: NSManagedObjectContext
    ) throws {
        guard let managedUser = try fetchUser(withAccountID: accountID, in: context) else {
            return
        }

        managedUser.image = imageData

        if context.hasChanges {
            try context.save()
        }
    }
}
