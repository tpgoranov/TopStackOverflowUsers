//
//  TopUsersViewModelTests.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import CoreData
import UIKit
import XCTest
@testable import TopStackOverflowUsers

@MainActor
final class TopUsersViewModelTests: CoreDataTestCase {
    func testConfigureDataSource() {
        let dataFetcher = MockTopUserDataFetcher(
            fetchedResultsController: makeFetchedResultsController()
        )
        let viewModel = TopUsersViewModel(
            dataFetcher: dataFetcher,
            avatarRepository: MockAvatarRepository()
        )

        viewModel.configureDataSource(for: UITableView())

        XCTAssertNotNil(viewModel.dataSource)
    }

    func testFetchDataFromRemote() async {
        let dataFetcher = MockTopUserDataFetcher(
            fetchedResultsController: makeFetchedResultsController()
        )
        let viewModel = TopUsersViewModel(
            dataFetcher: dataFetcher,
            avatarRepository: MockAvatarRepository()
        )
        let stateExpectation = expectation(description: "Wait for content state")

        viewModel.onStateChanged = { state in
            if case .content = state {
                stateExpectation.fulfill()
            }
        }

        viewModel.fetchDataFromRemote()

        await fulfillment(of: [stateExpectation], timeout: 1.0)
        XCTAssertEqual(dataFetcher.fetchTopUsersCallCount, 1)
    }

    func testFetchDataFromRemoteOnFailureState() async {
        let dataFetcher = MockTopUserDataFetcher(
            fetchedResultsController: makeFetchedResultsController(),
            fetchError: AppNetworkClientError.serverUnreachable
        )
        let viewModel = TopUsersViewModel(
            dataFetcher: dataFetcher,
            avatarRepository: MockAvatarRepository()
        )
        let stateExpectation = expectation(description: "Wait for server unreachable state")

        viewModel.onStateChanged = { state in
            if case .serverUnreachable = state {
                stateExpectation.fulfill()
            }
        }

        viewModel.fetchDataFromRemote()

        await fulfillment(of: [stateExpectation], timeout: 1.0)
        XCTAssertEqual(dataFetcher.fetchTopUsersCallCount, 1)
    }

    func testConfigureFetchedResultsControllerPublishesContentState() throws {
        let persistentContainer = makeInMemoryPersistentContainer()
        try storeUser(
            accountId: 1,
            reputation: 100,
            displayName: "First",
            profileImageURL: nil,
            in: persistentContainer.viewContext
        )

        let dataFetcher = MockTopUserDataFetcher(
            fetchedResultsController: makeFetchedResultsController(
                using: persistentContainer.viewContext
            )
        )
        let viewModel = TopUsersViewModel(
            dataFetcher: dataFetcher,
            avatarRepository: MockAvatarRepository()
        )
        let stateExpectation = expectation(description: "Wait for content state")

        viewModel.onStateChanged = { state in
            if case .content = state {
                stateExpectation.fulfill()
            }
        }

        viewModel.configureDataSource(for: UITableView())
        viewModel.configureFetchedResultsController()

        wait(for: [stateExpectation], timeout: 1.0)
        XCTAssertEqual(viewModel.fetchedResultsController.fetchedObjects?.count, 1)
    }

    private func makeFetchedResultsController(
        using context: NSManagedObjectContext? = nil
    ) -> NSFetchedResultsController<StackOverflowUser> {
        let resolvedContext: NSManagedObjectContext
        if let context {
            resolvedContext = context
        } else {
            resolvedContext = makeInMemoryPersistentContainer().viewContext
        }

        return NSFetchedResultsController(
            fetchRequest: StackOverflowUser.usersFetchRequest(),
            managedObjectContext: resolvedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}

private final class MockTopUserDataFetcher: TopUserDataFetching {
    private let fetchedResultsController: NSFetchedResultsController<StackOverflowUser>
    private let fetchError: Error?

    private(set) var fetchTopUsersCallCount = 0

    init(
        fetchedResultsController: NSFetchedResultsController<StackOverflowUser>,
        fetchError: Error? = nil
    ) {
        self.fetchedResultsController = fetchedResultsController
        self.fetchError = fetchError
    }

    func fetchTopUsers() async throws {
        fetchTopUsersCallCount += 1

        if let fetchError {
            throw fetchError
        }
    }

    func makeUsersFetchedResultsController() -> NSFetchedResultsController<StackOverflowUser> {
        fetchedResultsController
    }

    func toggleFollowState(for objectID: NSManagedObjectID) {
    }
}

private struct MockAvatarRepository: AvatarRepositorying {
    func cachedImage(for imageURLString: String) -> UIImage? {
        nil
    }

    func fetchImage(for imageURLString: String) async throws -> UIImage? {
        nil
    }
}
