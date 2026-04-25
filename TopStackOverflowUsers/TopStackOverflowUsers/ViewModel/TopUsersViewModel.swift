//
//  TopUsersViewModel.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation
import UIKit
import CoreData

@MainActor
final class TopUsersViewModel {
    private lazy var dataFetcher: TopUserDataFetching = TopUsersDataLoader()

    lazy var fetchedResultsController = dataFetcher.makeUsersFetchedResultsController()
    private(set) var dataSource: TopUsersTableViewDataSource?
    var onError: ((Error) -> Void)?

    func configureDataSource(for tableView: UITableView) {
        dataSource = TopUsersTableViewDataSource(
            tableView: tableView,
            fetchedResultsController: fetchedResultsController,
            onImageRequested: { [weak self] user in
                self?.fetchImage(for: user)
            }
        )
    }

    func fetchDataFromRemote() {
        Task {
            do {
                try await dataFetcher.fetchTopUsers()
            } catch {
                onError?(error)
            }
        }
    }

    func configureFetchedResultsController() {
        do {
            try fetchedResultsController.performFetch()
            dataSource?.applyInitialSnapshot()
        } catch {
            onError?(error)
        }
    }

    private func fetchImage(for user: StackOverflowUser) {
        Task {
            do {
                try await dataFetcher.fetchImage(forUserID: Int(user.accountId))
            } catch {
                onError?(error)
            }
        }
    }
}
