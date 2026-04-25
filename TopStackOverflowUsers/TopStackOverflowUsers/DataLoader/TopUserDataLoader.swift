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
    func fetchImage(forUserID userID: Int) async throws
    func makeUsersFetchedResultsController() -> NSFetchedResultsController<StackOverflowUser>
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

    func fetchTopUsers() async throws {
        let fetchedUsers = try await userProvider.fetchTopUsers()
        let context = persistentContainer.newBackgroundContext()
        try await context.perform {
            try StackOverflowUser.store(fetchedUsers, in: context)
        }
    }

    func fetchImage(forUserID userID: Int) async throws {
        let viewContext = persistentContainer.viewContext

        guard let managedUser = try StackOverflowUser.fetchUser(withAccountID: userID, in: viewContext) else {
            return
        }

        if managedUser.image != nil {
            return
        }

        guard let imageURLString = try StackOverflowUser.profileImageURL(forAccountID: userID, in: viewContext) else {
            return
        }

        let imageData = try await userProvider.downloadImage(from: imageURLString)
        let backgroundContext = persistentContainer.newBackgroundContext()
        try await backgroundContext.perform {
            try StackOverflowUser.storeImageData(imageData, forAccountID: userID, in: backgroundContext)
        }
    }

    func makeUsersFetchedResultsController() -> NSFetchedResultsController<StackOverflowUser> {
        NSFetchedResultsController(
            fetchRequest: StackOverflowUser.usersFetchRequest(),
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    private static func defaultPersistentContainer() -> NSPersistentContainer {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate is unavailable")
        }

        return appDelegate.persistentContainer
    }
}
