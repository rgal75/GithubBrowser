//
//  GitHubRepository.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation

struct GitHubRepository: Equatable, Decodable {
    var fullName: String
    var description: String? = ""
    var language: String? = ""
    var stargazersCount: Int
    var owner: Owner?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case description = "description"
        case language = "language"
        case stargazersCount = "stargazers_count"
        case owner = "owner"
    }
}

struct Owner: Equatable, Decodable {
    var login: String
    var avatarUrlString: String

    enum CodingKeys: String, CodingKey {
        case login = "login"
        case avatarUrlString = "avatar_url"
    }
}
