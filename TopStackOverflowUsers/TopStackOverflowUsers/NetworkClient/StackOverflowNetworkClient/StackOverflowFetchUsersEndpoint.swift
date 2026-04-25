//
//  StackOverflowFetchUsersEndpoint.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation

struct StackOverflowFetchEndpoint: Endpoint {
    var urlPath: String {
        "https://api.stackexchange.com/2.2/users"
    }

    var httpMethod: String {
        "GET"
    }

    var queryParameters: [URLQueryItem] {
        [URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "pagesize", value: "20"),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "sort", value: "reputation"),
            URLQueryItem(name: "site", value: "stackoverflow")]
    }
}
