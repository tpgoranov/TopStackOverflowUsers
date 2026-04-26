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

    func configureFetchedResultsController() {
        do {
            try fetchedResultsController.performFetch()
            dataSource?.applyInitialSnapshot()
            onStateChanged?(.content)
        } catch {
            handle(error)
        }
    }

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

    private func image(for user: StackOverflowUser) -> UIImage? {
        guard
            let imageURLString = user.profileImageURL
        else {
            return nil
        }

        return avatarRepository.cachedImage(for: imageURLString)
    }

    private func handle(_ error: Error) {
        log(error)
        dataSource?.applyEmptySnapshot()
        onStateChanged?(.serverUnreachable)
    }

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
