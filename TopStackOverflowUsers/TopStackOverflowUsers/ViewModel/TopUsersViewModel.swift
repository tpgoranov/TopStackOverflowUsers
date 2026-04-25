//
//  TopUsersViewModel.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation

@MainActor
final class TopUsersViewModel {
    private var userProvider: StackOverflowUserProviding {
        StackOverflowNetwokClient()
    }

    private(set) var users: [TopUser] = []
    var onUsersUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?

    func fetchTopUsers() {
        Task {
            do {
                users = try await userProvider.fetchTopUsers()
                onUsersUpdated?()
            } catch {
                onError?(error)
            }
        }
    }
}
