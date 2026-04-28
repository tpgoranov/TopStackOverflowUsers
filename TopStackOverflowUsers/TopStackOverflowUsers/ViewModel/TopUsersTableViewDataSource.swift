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

    // Show the first snapshot with no animation.
    func applyInitialSnapshot() {
        applySnapshot(animatingDifferences: false)
    }

    // Update the table when something changed.
    func applyAnimatedSnapshot() {
        applySnapshot(animatingDifferences: true)
        reloadedObjectIDs.removeAll()
    }

    // Remove all rows from the snapshot to handle error state
    func applyEmptySnapshot() {
        reloadedObjectIDs.removeAll()
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // Mark one user to be reloaded in the next snapshot.
    func reloadObject(_ user: StackOverflowUser) {
        reloadedObjectIDs.insert(user.objectID)
    }

    // Build the diffable data source for the table.
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

    // Apply the current fetched objects to the table.
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

    // Called when the fetched results controller finished updates.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        applySnapshot(animatingDifferences: false)
        reloadedObjectIDs.removeAll()
    }

    // Track updated objects so we can reload them.
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
