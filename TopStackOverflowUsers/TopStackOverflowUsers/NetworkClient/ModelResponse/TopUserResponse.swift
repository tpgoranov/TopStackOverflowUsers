//
//  TopUserResponse.swift
//  TopStackOverflowUsers
//
//  Created by Todor Goranov on 25/04/2026.
//

import Foundation

struct TopUsersResponse: Codable {
    let items: [TopUser]
}

struct TopUser: Codable {
    let accountId: Int
    let reputation: Int
    let profileImage: String?
    let displayName: String
}
