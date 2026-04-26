//
//  TopUsersDataLoaderTests.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import CoreData
import XCTest
@testable import TopStackOverflowUsers

@MainActor
final class TopUsersDataLoaderTests: CoreDataTestCase {
    func testFetchTopUsersStoresFetchedUsersInSTore() async throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        let provider = MockStackOverflowUserProvider(
            fetchedUsers: [
                TopUser(accountId: 2, reputation: 250, profileImage: "https://example.com/2.png", displayName: "Second"),
                TopUser(accountId: 1, reputation: 100, profileImage: "https://example.com/1.png", displayName: "First")
            ]
        )
        let testLoader = TopUsersDataLoader(userProvider: provider, persistentContainer: persistentContainer)

        try await testLoader.fetchTopUsers()

        let fetchedResultsController = testLoader.makeUsersFetchedResultsController()
        try fetchedResultsController.performFetch()

        let users = fetchedResultsController.fetchedObjects ?? []
        XCTAssertEqual(users[0].accountId, 2)
        XCTAssertEqual(users[0].displayName, "Second")
        XCTAssertEqual(users[1].accountId, 1)
        XCTAssertEqual(users[1].displayName, "First")
    }

    func testFetchTopUsersAndUpdate() async throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        try storeUser(
            accountId: 7,
            reputation: 100,
            displayName: "Old Name",
            profileImageURL: "https://example.com/old.png",
            in: persistentContainer.viewContext
        )

        let provider = MockStackOverflowUserProvider(
            fetchedUsers: [
                TopUser(accountId: 7, reputation: 500, profileImage: "https://example.com/new.png", displayName: "New Name")
            ]
        )
        let testLoader = TopUsersDataLoader(userProvider: provider, persistentContainer: persistentContainer)

        try await testLoader.fetchTopUsers()

        let users = try persistentContainer.viewContext.fetch(StackOverflowUser.usersFetchRequest())
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.accountId, 7)
        XCTAssertEqual(users.first?.reputation, 500)
        XCTAssertEqual(users.first?.displayName, "New Name")
        XCTAssertEqual(users.first?.profileImageURL, "https://example.com/new.png")
    }

    func testFetchTopUsersWithError() async {
        let persistentContainer = makeInMemoryPersistentContainer()
        let provider = MockStackOverflowUserProvider(error: MockError.fetchFailed)
        let testLoader = TopUsersDataLoader(userProvider: provider, persistentContainer: persistentContainer)

        do {
            try await testLoader.fetchTopUsers()
            XCTFail("Expected fetchTopUsers() to throw")
        } catch {
            XCTAssertEqual(error as? MockError, .fetchFailed)
        }

        let users = try? persistentContainer.viewContext.fetch(StackOverflowUser.usersFetchRequest())
        XCTAssertEqual(users?.count, 0)
    }
    
    func testToggleUser() async throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        let user = try storeUser(
            accountId: 7,
            reputation: 100,
            displayName: "Old Name",
            profileImageURL: "https://example.com/old.png",
            in: persistentContainer.viewContext
        )

        let provider = MockStackOverflowUserProvider(
            fetchedUsers: [
                TopUser(accountId: 7, reputation: 500, profileImage: "https://example.com/new.png", displayName: "New Name")
            ]
        )
        let testLoader = TopUsersDataLoader(userProvider: provider, persistentContainer: persistentContainer)
        XCTAssertEqual(user.isFollowed, false)

        testLoader.toggleFollowState(for: user.objectID)
        XCTAssertEqual(user.isFollowed, true)
    }

    func testMakeUsersFetchedResultsControllerUses() {
        let persistentContainer = makeInMemoryPersistentContainer()
        let testLoader = TopUsersDataLoader(
            userProvider: MockStackOverflowUserProvider(),
            persistentContainer: persistentContainer
        )

        let fetchedResultsController = testLoader.makeUsersFetchedResultsController()

        XCTAssertTrue(fetchedResultsController.managedObjectContext === persistentContainer.viewContext)
        XCTAssertEqual(fetchedResultsController.fetchRequest.sortDescriptors?.count, 1)
        XCTAssertEqual(fetchedResultsController.fetchRequest.sortDescriptors?.first?.key, "reputation")
        XCTAssertEqual(fetchedResultsController.fetchRequest.sortDescriptors?.first?.ascending, false)
    }
}

private struct MockStackOverflowUserProvider: StackOverflowUserProviding {
    var fetchedUsers: [TopUser] = []
    var error: Error?

    func fetchTopUsers() async throws -> [TopUser] {
        if let error {
            throw error
        }

        return fetchedUsers
    }

    func downloadImage(from imageURLString: String) async throws -> Data {
        Data()
    }
}

private enum MockError: Error, Equatable {
    case fetchFailed
}
