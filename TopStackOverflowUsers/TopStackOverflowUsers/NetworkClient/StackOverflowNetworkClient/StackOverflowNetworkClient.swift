//
//  StackOverflowNetworkClient.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation

protocol StackOverflowUserProviding {
    func fetchTopUsers() async throws -> [TopUser]
    func downloadImage(from imageURLString: String) async throws -> Data
}

final class StackOverflowNetwokClient: StackOverflowUserProviding {
    private let networkClient: NetworkRequestPerforming

    init(networkClient: NetworkRequestPerforming = AppNetworkClient()) {
        self.networkClient = networkClient
    }

    func fetchTopUsers() async throws -> [TopUser] {
        let response: TopUsersResponse = try await networkClient.performRequest(StackOverflowFetchEndpoint())
        return response.items
    }

    func downloadImage(from imageURLString: String) async throws -> Data {
        try await networkClient.performDataRequest(
            StackOverflowDownloadImageEndpoint(imageURLString: imageURLString)
        )
    }
}
