//
//  GitHubSearchResult.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation

struct GitHubSearchResult: Decodable {
    var totalCount: Int
    var repositories: [GitHubRepository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case repositories = "items"
    }
}
