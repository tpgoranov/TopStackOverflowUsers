//
//  MockStackOverflowNetworkClient.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 26/04/2026.
//

import Foundation

struct MockStackOverflowNetworkClient: StackOverflowUserProviding {
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

    func downloadImage(from imageURLString: String) async throws -> Data {
        Data()
    }
}
