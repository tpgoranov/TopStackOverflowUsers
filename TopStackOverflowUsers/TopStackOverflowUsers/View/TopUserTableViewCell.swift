//
//  TopUserTableViewCell.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import UIKit

final class TopUserTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TopUserTableViewCell"

    private let nameLabel = UILabel()
    private let reputationLabel = UILabel()
    private let labelsStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with user: TopUser) {
        nameLabel.text = user.displayName
        reputationLabel.text = "Reputation: \(user.reputation)"
    }

    private func configureViews() {
        selectionStyle = .none

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.numberOfLines = 0

        reputationLabel.font = .preferredFont(forTextStyle: .subheadline)
        reputationLabel.textColor = .secondaryLabel

        labelsStackView.axis = .vertical
        labelsStackView.spacing = 4
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false

        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(reputationLabel)
        contentView.addSubview(labelsStackView)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
