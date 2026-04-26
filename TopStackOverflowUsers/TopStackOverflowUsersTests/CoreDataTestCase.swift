//
//  CoreDataTestCase.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import CoreData
import XCTest
@testable import TopStackOverflowUsers

@MainActor
class CoreDataTestCase: XCTestCase {
    func makeInMemoryPersistentContainer() -> NSPersistentContainer {
        guard
            let modelURL = Bundle(for: AppDelegate.self).url(forResource: "TopStackOverflowUsers", withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Failed to load TopStackOverflowUsers managed object model")
        }

        let persistentContainer = NSPersistentContainer(
            name: "TopStackOverflowUsers",
            managedObjectModel: managedObjectModel
        )
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                XCTFail("Failed to load persistent store: \(error)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        return persistentContainer
    }

    @discardableResult
    func storeUser(
        accountId: Int64,
        reputation: Int64,
        displayName: String,
        profileImageURL: String?,
        in context: NSManagedObjectContext
    ) throws -> StackOverflowUser {
        let user = StackOverflowUser(context: context)
        user.accountId = accountId
        user.reputation = reputation
        user.isFollowed = false
        user.displayName = displayName
        user.profileImageURL = profileImageURL
        try context.save()
        return user
    }
}
