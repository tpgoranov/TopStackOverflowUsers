//
//  StackOverflowDownloadImageEndpoint.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation

struct StackOverflowDownloadImageEndpoint: Endpoint {
    let imageURLString: String

    var urlPath: String {
        imageURLString
    }

    var queryParameters: [URLQueryItem] {
        []
    }

    var httpMethod: String {
        "GET"
    }
}
