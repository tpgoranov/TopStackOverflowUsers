//
//  TopUsersViewModel.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation
import UIKit
import CoreData

enum TopUsersViewState {
    case content
    case serverUnreachable
}

@MainActor
final class TopUsersViewModel {
    private let dataFetcher: TopUserDataFetching
    private let avatarRepository: AvatarRepositorying

    lazy var fetchedResultsController = dataFetcher.makeUsersFetchedResultsController()
    private(set) var dataSource: TopUsersTableViewDataSource?
    var onStateChanged: ((TopUsersViewState) -> Void)?

    init(dataFetcher: TopUserDataFetching, avatarRepository: AvatarRepositorying) {
        self.dataFetcher = dataFetcher
        self.avatarRepository = avatarRepository
    }

    // Build the table data source in a declarative functional way
    func configureDataSource(for tableView: UITableView) {
        dataSource = TopUsersTableViewDataSource(
            tableView: tableView,
            fetchedResultsController: fetchedResultsController,
            imageProvider: { [weak self] user in
                self?.image(for: user)
            },
            onImageRequested: { [weak self] user in
                self?.fetchImage(for: user)
            },
            onFollowRequested: { [weak self] user in
                self?.dataFetcher.toggleFollowState(for: user.objectID)
            }
        )
    }

    // Start loading users from remote.
    func fetchDataFromRemote() {
        Task {
            do {
                try await dataFetcher.fetchTopUsers()
                onStateChanged?(.content)
            } catch {
                handle(error)
            }
        }
    }

    // Do the first fetch from Core Data for the table.
    func configureFetchedResultsController() {
        do {
            try fetchedResultsController.performFetch()
            dataSource?.applyInitialSnapshot()
            onStateChanged?(.content)
        } catch {
            handle(error)
        }
    }

    // Download one missing image and refresh the row when completed.
    private func fetchImage(for user: StackOverflowUser) {
        guard let imageURLString = user.profileImageURL else {
            return
        }

        Task {
            do {
                _ = try await avatarRepository.fetchImage(for: imageURLString)
                dataSource?.reloadObject(user)
                dataSource?.applyAnimatedSnapshot()
            } catch {
                log(error)
            }
        }
    }

    // Read an image from the repository cache.
    private func image(for user: StackOverflowUser) -> UIImage? {
        guard
            let imageURLString = user.profileImageURL
        else {
            return nil
        }

        return avatarRepository.cachedImage(for: imageURLString)
    }

    // Handle error state when loading failed. Change ViewController State
    private func handle(_ error: Error) {
        log(error)
        dataSource?.applyEmptySnapshot()
        onStateChanged?(.serverUnreachable)
    }

    // Print simple error info for debugging.
    private func log(_ error: Error) {
        if let networkError = error as? AppNetworkClientError {
            switch networkError {
            case .invalidURLResponse:
                print("Network error: invalid URL response.")
            case .decodingFailed:
                print("Network error: decoding failed.")
            case .badUrl:
                print("Network error: bad URL.")
            case .noNetwork:
                print("Network error: no network connection.")
            case .serverUnreachable:
                print("Network error: server unreachable.")
            }
        } else {
            print("Unexpected error: \(error)")
        }
    }
}
