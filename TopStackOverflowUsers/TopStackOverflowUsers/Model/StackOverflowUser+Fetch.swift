//
//  StackOverflowUser+Fetch.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import CoreData

extension StackOverflowUser {
    // Make the fetch request used for the users list.
    static func usersFetchRequest() -> NSFetchRequest<StackOverflowUser> {
        let fetchRequest = StackOverflowUser.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "reputation", ascending: false)]
        return fetchRequest
    }

    // Find one user by account id.
    static func fetchUser(withAccountID accountID: Int, in context: NSManagedObjectContext) throws -> StackOverflowUser? {
        let fetchRequest = StackOverflowUser.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "accountId == %d", accountID)
        return try context.fetch(fetchRequest).first
    }

    // Save or update the downloaded users.
    static func store(_ users: [TopUser], in context: NSManagedObjectContext) throws {
        for user in users {
            let managedUser = try fetchUser(withAccountID: user.accountId, in: context)
                ?? StackOverflowUser(context: context)

            managedUser.applyChanges(from: user)
        }

        if context.hasChanges {
            try context.save()
        }
    }

    // Copy response values into the managed object.
    func applyChanges(from user: TopUser) {
        let accountID = Int64(user.accountId)
        if accountId != accountID {
            accountId = accountID
        }

        if displayName != user.displayName {
            displayName = user.displayName
        }

        if profileImageURL != user.profileImage {
            profileImageURL = user.profileImage
        }

        let reputation = Int64(user.reputation)
        if self.reputation != reputation {
            self.reputation = reputation
        }
    }
}
