//
//  TopUsersTableViewDataSource.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import UIKit
import CoreData

@MainActor
final class TopUsersTableViewDataSource: NSObject, NSFetchedResultsControllerDelegate {
    private let tableView: UITableView
    private let fetchedResultsController: NSFetchedResultsController<StackOverflowUser>
    private let imageProvider: (StackOverflowUser) -> UIImage?
    private let onImageRequested: (StackOverflowUser) -> Void
    private let onFollowRequested: (StackOverflowUser) -> Void
    private lazy var dataSource = makeDataSource()
    private var reloadedObjectIDs = Set<NSManagedObjectID>()

    init(
        tableView: UITableView,
        fetchedResultsController: NSFetchedResultsController<StackOverflowUser>,
        imageProvider: @escaping (StackOverflowUser) -> UIImage?,
        onImageRequested: @escaping (StackOverflowUser) -> Void,
        onFollowRequested: @escaping (StackOverflowUser) -> Void
    ) {
        self.tableView = tableView
        self.fetchedResultsController = fetchedResultsController
        self.imageProvider = imageProvider
        self.onImageRequested = onImageRequested
        self.onFollowRequested = onFollowRequested
        super.init()
        self.fetchedResultsController.delegate = self
        tableView.dataSource = dataSource
        tableView.register(TopUserTableViewCell.self, forCellReuseIdentifier: TopUserTableViewCell.reuseIdentifier)
    }

    func applyInitialSnapshot() {
        applySnapshot(animatingDifferences: false)
    }

    func applyUpdatedSnapshot() {
        applySnapshot(animatingDifferences: true)
        reloadedObjectIDs.removeAll()
    }

    func applyReloadSnapshot() {
        applySnapshot(animatingDifferences: true)
        reloadedObjectIDs.removeAll()
    }

    func applyEmptySnapshot() {
        reloadedObjectIDs.removeAll()
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func reloadObject(_ user: StackOverflowUser) {
        reloadedObjectIDs.insert(user.objectID)
    }

    private func makeDataSource() -> UITableViewDiffableDataSource<Int, NSManagedObjectID> {
        let dataSource = UITableViewDiffableDataSource<Int, NSManagedObjectID>(tableView: tableView) { [weak self] tableView, indexPath, _ in
            guard
                let self,
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: TopUserTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as? TopUserTableViewCell
            else {
                return UITableViewCell()
            }

            let user = fetchedResultsController.object(at: indexPath)
            let image = imageProvider(user)
            cell.configure(with: user, image: image) { [weak self] in
                self?.onFollowRequested(user)
            }

            if image == nil {
                onImageRequested(user)
            }

            return cell
        }

        dataSource.defaultRowAnimation = .fade
        return dataSource
    }

    private func applySnapshot(animatingDifferences: Bool) {
        let objectIDs = fetchedResultsController.fetchedObjects?.map(\.objectID) ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        snapshot.appendSections([0])
        snapshot.appendItems(objectIDs, toSection: 0)

        let reloadedItems = objectIDs.filter { reloadedObjectIDs.contains($0) }
        if !reloadedItems.isEmpty {
            snapshot.reloadItems(reloadedItems)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        applyUpdatedSnapshot()
    }

    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard type == .update, let user = anObject as? StackOverflowUser else {
            return
        }

        reloadObject(user)
    }
}
