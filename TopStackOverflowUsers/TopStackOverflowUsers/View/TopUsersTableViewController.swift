//
//  TopUsersTableViewController.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import UIKit

@MainActor
final class TopUsersTableViewController: UITableViewController {
    private let viewModel: TopUsersViewModel

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.viewModel = TopUsersViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Top Users"
        bindViewModel()
        viewModel.configureDataSource(for: tableView)
        viewModel.configureFetchedResultsController()
        viewModel.fetchDataFromRemote()
    }

    private func bindViewModel() {
        viewModel.onError = { error in
            print(error)
        }
    }
}
