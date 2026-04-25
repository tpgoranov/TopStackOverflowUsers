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
        tableView.register(TopUserTableViewCell.self, forCellReuseIdentifier: TopUserTableViewCell.reuseIdentifier)
        bindViewModel()
        viewModel.fetchTopUsers()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopUserTableViewCell.reuseIdentifier, for: indexPath) as! TopUserTableViewCell
        cell.configure(with: viewModel.users[indexPath.row])
        return cell
    }

    private func bindViewModel() {
        viewModel.onUsersUpdated = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onError = { error in
            print(error)
        }
    }
}
