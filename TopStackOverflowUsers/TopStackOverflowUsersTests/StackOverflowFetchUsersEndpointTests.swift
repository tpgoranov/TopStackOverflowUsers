//
//  StackOverflowFetchUsersEndpointTests.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation
import XCTest
@testable import TopStackOverflowUsers

@MainActor
final class StackOverflowFetchUsersEndpointTests: XCTestCase {
    func testStackOverflowFetchEndpointProvidesExpectedConfiguration() throws {
        let endpoint = StackOverflowFetchEndpoint()

        XCTAssertEqual(endpoint.urlPath, "https://api.stackexchange.com/2.2/users")
        XCTAssertEqual(endpoint.httpMethod, "GET")
        XCTAssertEqual(endpoint.queryParameters.count, 5)
        
        XCTAssertEqual(endpoint.queryParameters[0], URLQueryItem(name: "page", value: "1"))
        XCTAssertEqual(endpoint.queryParameters[1], URLQueryItem(name: "pagesize", value: "20"))
        XCTAssertEqual(endpoint.queryParameters[2], URLQueryItem(name: "order", value: "desc"))
        XCTAssertEqual(endpoint.queryParameters[3], URLQueryItem(name: "sort", value: "reputation"))
        XCTAssertEqual(endpoint.queryParameters[4], URLQueryItem(name: "site", value: "stackoverflow"))
    }
}
