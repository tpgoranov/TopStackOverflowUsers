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
    private let onImageRequested: (StackOverflowUser) -> Void
    private lazy var dataSource = makeDataSource()
    private var reloadedObjectIDs = Set<NSManagedObjectID>()

    init(
        tableView: UITableView,
        fetchedResultsController: NSFetchedResultsController<StackOverflowUser>,
        onImageRequested: @escaping (StackOverflowUser) -> Void
    ) {
        self.tableView = tableView
        self.fetchedResultsController = fetchedResultsController
        self.onImageRequested = onImageRequested
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

    func reloadObject(_ user: StackOverflowUser) {
        reloadedObjectIDs.insert(user.objectID)
    }

    private func makeDataSource() -> UITableViewDiffableDataSource<Int, NSManagedObjectID> {
        UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, _ in
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
            let image = user.image.flatMap(UIImage.init(data:))
            cell.configure(with: user, image: image)

            if image == nil {
                onImageRequested(user)
            }

            return cell
        }
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
