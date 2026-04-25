//
//  AppNetworkClient.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation

enum AppNetworkClientError: Error {
    case invalidURLResponse
    case decodingFailed
    case badUrl
    case noNetwork
    case serverUnreachable
}

protocol NetworkRequestPerforming {
    func performRequest<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class AppNetworkClient: NetworkRequestPerforming {
    private let session: URLSession
    private let decoder: JSONDecoder

    init() {
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration)
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func createURLRequest(from endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(string: endpoint.urlPath)
        components?.queryItems = endpoint.queryParameters

        guard let url = components?.url else {
            throw AppNetworkClientError.badUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.httpMethod
        return urlRequest
    }

    func performRequest<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let urlRequest = try createURLRequest(from: endpoint)
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw AppNetworkClientError.noNetwork
            default:
                throw AppNetworkClientError.serverUnreachable
            }
        }

        guard response is HTTPURLResponse else {
            throw AppNetworkClientError.invalidURLResponse
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppNetworkClientError.decodingFailed
        }
    }
}
