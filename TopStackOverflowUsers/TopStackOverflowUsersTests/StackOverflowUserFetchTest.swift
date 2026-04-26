//
//  StackOverflowUserFetchTest.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import CoreData
import XCTest
@testable import TopStackOverflowUsers

@MainActor
final class StackOverflowUserFetchTests: CoreDataTestCase {
    func testUsersFetchRequestSortsByReputationDescending() throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        try storeUser(
            accountId: 1,
            reputation: 100,
            displayName: "First",
            profileImageURL: nil,
            in: persistentContainer.viewContext
        )
        try storeUser(
            accountId: 2,
            reputation: 500,
            displayName: "Second",
            profileImageURL: nil,
            in: persistentContainer.viewContext
        )

        let users = try persistentContainer.viewContext.fetch(StackOverflowUser.usersFetchRequest())

        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].accountId, 2)
        XCTAssertEqual(users[1].accountId, 1)
    }

    func testFetchUserReturnsMatchingUser() throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        let storedUser = try storeUser(
            accountId: 42,
            reputation: 250,
            displayName: "Answer",
            profileImageURL: "https://example.com/42.png",
            in: persistentContainer.viewContext
        )

        let fetchedUser = try StackOverflowUser.fetchUser(
            withAccountID: 42,
            in: persistentContainer.viewContext
        )

        XCTAssertEqual(fetchedUser?.objectID, storedUser.objectID)
        
        let fetchMissingUser = try StackOverflowUser.fetchUser(
            withAccountID: 999,
            in: persistentContainer.viewContext
        )

        XCTAssertNil(fetchMissingUser)
    }

    func testStoreUpdatesExistingUser() throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        try storeUser(
            accountId: 7,
            reputation: 100,
            displayName: "Old Name",
            profileImageURL: "https://example.com/old.png",
            in: persistentContainer.viewContext
        )

        try StackOverflowUser.store(
            [
                TopUser(
                    accountId: 7,
                    reputation: 500,
                    profileImage: "https://example.com/new.png",
                    displayName: "New Name"
                )
            ],
            in: persistentContainer.viewContext
        )

        let users = try persistentContainer.viewContext.fetch(StackOverflowUser.usersFetchRequest())

        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.accountId, 7)
        XCTAssertEqual(users.first?.reputation, 500)
        XCTAssertEqual(users.first?.displayName, "New Name")
        XCTAssertEqual(users.first?.profileImageURL, "https://example.com/new.png")
    }
}
