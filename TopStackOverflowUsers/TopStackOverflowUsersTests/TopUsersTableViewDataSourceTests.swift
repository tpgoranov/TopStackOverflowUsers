//
//  TopUsersTableViewDataSourceTests.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import CoreData
import UIKit
import XCTest
@testable import TopStackOverflowUsers

@MainActor
final class TopUsersTableViewDataSourceTests: CoreDataTestCase {
    func testApplyInitialSnapshotDisplaysFetchedUsers() throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        let firstUser = try storeUser(
            accountId: 1,
            reputation: 100,
            displayName: "First",
            profileImageURL: "https://example.com/1.png",
            in: persistentContainer.viewContext
        )
        let secondUser = try storeUser(
            accountId: 2,
            reputation: 200,
            displayName: "Second",
            profileImageURL: "https://example.com/2.png",
            in: persistentContainer.viewContext
        )

        let tableView = UITableView()
        let fetchedResultsController = makeFetchedResultsController(using: persistentContainer.viewContext)
        try fetchedResultsController.performFetch()

        let testDataSource = TopUsersTableViewDataSource(
            tableView: tableView,
            fetchedResultsController: fetchedResultsController,
            imageProvider: { _ in UIImage() },
            onImageRequested: { _ in XCTFail("Did not expect an image request") },
            onFollowRequested: { _ in }
        )

        testDataSource.applyInitialSnapshot()

        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 2)

        let firstCell = try XCTUnwrap(
            tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? TopUserTableViewCell
        )
        let secondCell = try XCTUnwrap(
            tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? TopUserTableViewCell
        )

        XCTAssertNotNil(firstCell)
        XCTAssertNotNil(secondCell)
        XCTAssertEqual(fetchedResultsController.object(at: IndexPath(row: 0, section: 0)).objectID, secondUser.objectID)
        XCTAssertEqual(fetchedResultsController.object(at: IndexPath(row: 1, section: 0)).objectID, firstUser.objectID)
    }

    func testApplyEmptySnapshotClearsDisplayedRows() throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        try storeUser(
            accountId: 1,
            reputation: 100,
            displayName: "First",
            profileImageURL: nil,
            in: persistentContainer.viewContext
        )

        let tableView = UITableView()
        let fetchedResultsController = makeFetchedResultsController(using: persistentContainer.viewContext)
        try fetchedResultsController.performFetch()

        let testDataSource = TopUsersTableViewDataSource(
            tableView: tableView,
            fetchedResultsController: fetchedResultsController,
            imageProvider: { _ in nil },
            onImageRequested: { _ in },
            onFollowRequested: { _ in }
        )

        testDataSource.applyInitialSnapshot()
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)

        testDataSource.applyEmptySnapshot()

        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)
    }

    func testCellConfigurationRequestsImageWhenMissing() throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        let user = try storeUser(
            accountId: 7,
            reputation: 500,
            displayName: "Needs Image",
            profileImageURL: "https://example.com/image.png",
            in: persistentContainer.viewContext
        )

        let tableView = UITableView()
        let fetchedResultsController = makeFetchedResultsController(using: persistentContainer.viewContext)
        try fetchedResultsController.performFetch()

        var requestedUserIDs: [NSManagedObjectID] = []
        let testDataSource = TopUsersTableViewDataSource(
            tableView: tableView,
            fetchedResultsController: fetchedResultsController,
            imageProvider: { _ in nil },
            onImageRequested: { requestedUser in
                requestedUserIDs.append(requestedUser.objectID)
            },
            onFollowRequested: { _ in }
        )

        testDataSource.applyInitialSnapshot()
        _ = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(requestedUserIDs, [user.objectID])
    }

    private func makeFetchedResultsController(
        using context: NSManagedObjectContext
    ) -> NSFetchedResultsController<StackOverflowUser> {
        NSFetchedResultsController(
            fetchRequest: StackOverflowUser.usersFetchRequest(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
