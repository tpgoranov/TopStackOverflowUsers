//
//  MockStackOverflowNetworkClient.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import Foundation

struct MockStackOverflowNetworkClient: StackOverflowUserProviding {
    // Return fake users for UI tests.
    func fetchTopUsers() async throws -> [TopUser] {
        [
            TopUser(
                accountId: 1,
                reputation: 1000,
                profileImage: nil,
                displayName: "Mock User One"
            ),
            TopUser(
                accountId: 2,
                reputation: 900,
                profileImage: nil,
                displayName: "Mock User Two"
            )
        ]
    }

    // Return empty data because ui tests do not need real images.
    func downloadImage(from imageURLString: String) async throws -> Data {
        Data()
    }
}
