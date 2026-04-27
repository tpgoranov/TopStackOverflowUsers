//
//  TopUserDataLoader.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import UIKit
import CoreData

protocol TopUserDataFetching {
    func fetchTopUsers() async throws
    func makeUsersFetchedResultsController() -> NSFetchedResultsController<StackOverflowUser>
    func toggleFollowState(for objectID: NSManagedObjectID)
}

final class TopUsersDataLoader: TopUserDataFetching {
    private let userProvider: StackOverflowUserProviding
    private let persistentContainer: NSPersistentContainer

    init(
        userProvider: StackOverflowUserProviding = StackOverflowNetwokClient(),
        persistentContainer: NSPersistentContainer = TopUsersDataLoader.defaultPersistentContainer()
    ) {
        self.userProvider = userProvider
        self.persistentContainer = persistentContainer
    }

    // Get users from network and store them in Core Data.
    func fetchTopUsers() async throws {
        let fetchedUsers = try await userProvider.fetchTopUsers()
        let context = persistentContainer.newBackgroundContext()
        try await context.perform {
            try StackOverflowUser.store(fetchedUsers, in: context)
        }
    }

    // Make the fetched results controller used by the table.
    func makeUsersFetchedResultsController() -> NSFetchedResultsController<StackOverflowUser> {
        NSFetchedResultsController(
            fetchRequest: StackOverflowUser.usersFetchRequest(),
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    // Change the follow value and save it.
    func toggleFollowState(for objectID: NSManagedObjectID) {
        let context = persistentContainer.viewContext

        do {
            guard let user = try context.existingObject(with: objectID) as? StackOverflowUser else {
                return
            }

            user.isFollowed.toggle()

            if context.hasChanges {
                try context.save()
            }
        } catch {
            context.rollback()
            print("Core Data error: \(error)")
        }
    }

    // Get the shared container from app delegate.
    private static func defaultPersistentContainer() -> NSPersistentContainer {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate is unavailable")
        }

        return appDelegate.persistentContainer
    }
}
