//
//  Endpoint.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation

protocol Endpoint {
    var urlPath: String { get }
    var queryParameters: [URLQueryItem] { get }
    var httpMethod: String { get }
}
