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
    private let errorStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Server Unreachable"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        let userProvider: StackOverflowUserProviding
        if ProcessInfo.processInfo.arguments.contains("--ui-testing-mock-users") {
            userProvider = MockStackOverflowNetworkClient()
        } else {
            userProvider = StackOverflowNetwokClient()
        }

        self.viewModel = TopUsersViewModel(
            dataFetcher: TopUsersDataLoader(userProvider: userProvider),
            avatarRepository: AvatarRepository()
        )
        super.init(coder: coder)
    }

    // Set up the table screen when it opens.
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Top StackOverflow Users"
        tableView.accessibilityIdentifier = "topUsers.table"
        tableView.backgroundView = errorStateLabel
        bindViewModel()
        viewModel.configureDataSource(for: tableView)
        viewModel.configureFetchedResultsController()
        viewModel.fetchDataFromRemote()
    }

    // Listen for state changes from the view model.
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            self?.render(state)
        }
    }

    // Show normal content or error state.
    private func render(_ state: TopUsersViewState) {
        switch state {
        case .content:
            errorStateLabel.isHidden = true
        case .serverUnreachable:
            errorStateLabel.isHidden = false
        }
    }
}
