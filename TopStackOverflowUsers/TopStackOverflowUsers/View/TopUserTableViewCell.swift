//
//  TopUserTableViewCell.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import UIKit

final class TopUserTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TopUserTableViewCell"

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let reputationLabel = UILabel()
    private let labelsStackView = UIStackView()
    private let followButton = UIButton(type: .system)
    private var onFollowButtonTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Fill the cell with one user.
    func configure(with user: StackOverflowUser, image: UIImage?, onFollowButtonTapped: @escaping () -> Void) {
        nameLabel.text = user.displayName
        reputationLabel.text = "Reputation: \(user.reputation)"
        avatarImageView.image = image
        self.onFollowButtonTapped = onFollowButtonTapped
        updateFollowButton(isFollowed: user.isFollowed)
    }

    // Clear old cell data before reuse.
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        onFollowButtonTapped = nil
    }

    // Create the views used inside the cell.
    private func configureViews() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 24
        avatarImageView.backgroundColor = .tertiarySystemFill

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.numberOfLines = 0

        reputationLabel.font = .preferredFont(forTextStyle: .subheadline)
        reputationLabel.textColor = .secondaryLabel

        labelsStackView.axis = .vertical
        labelsStackView.spacing = 4
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false

        followButton.translatesAutoresizingMaskIntoConstraints = false
        var followButtonConfiguration = UIButton.Configuration.filled()
        followButtonConfiguration.buttonSize = .small
        followButtonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        followButton.configuration = followButtonConfiguration
        followButton.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        followButton.setContentHuggingPriority(.required, for: .horizontal)
        followButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        followButton.layer.cornerRadius = 6
        followButton.clipsToBounds = true
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)

        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(reputationLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(labelsStackView)
        contentView.addSubview(followButton)
    }

    // Add the layout constraints for the cell.
    private func configureLayout() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelsStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            labelsStackView.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // Change the follow button title.
    private func updateFollowButton(isFollowed: Bool) {
        var configuration = followButton.configuration ?? .filled()
        configuration.title = isFollowed ? "Unfollow" : "Follow"
        configuration.cornerStyle = .fixed
        followButton.configuration = configuration
    }

    @objc
    // Run the action when the button is tapped.
    private func didTapFollowButton() {
        onFollowButtonTapped?()
    }
}
