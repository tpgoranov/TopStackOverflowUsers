//
//  AppNetworkClientTests.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation
import XCTest
@testable import TopStackOverflowUsers

final class AppNetworkClientTests: XCTestCase {
    func testCreateURLRequestBuildsExpectedRequest() throws {
        let client = AppNetworkClient()
        let endpoint = MockEndpoint(
            urlPath: "https://example.com/users",
            queryParameters: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "sort", value: "name")
            ],
            httpMethod: "GET"
        )

        let request = try client.createURLRequest(from: endpoint)

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url, URL(string:"https://example.com/users?page=1&sort=name"))
    }
}

private struct MockEndpoint: Endpoint {
    let urlPath: String
    let queryParameters: [URLQueryItem]
    let httpMethod: String
}
