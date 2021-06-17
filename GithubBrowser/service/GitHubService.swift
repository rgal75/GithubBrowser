//
//  GitHubService.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation
import RxSwift

struct GitHubSearchResult {
    var totalCount: Int
    var repositories: [GitHubRepository]
}
protocol GitHubServiceProtocol {
    func findRepositories(
        withSearchTerm searchTerm: String,
        page: Int,
        pageSize: Int) -> Single<GitHubSearchResult>
}

class GitHubService: GitHubServiceProtocol {
    func findRepositories(
        withSearchTerm searchTerm: String,
        page: Int,
        pageSize: Int) -> Single<GitHubSearchResult> {
        return .never()
    }
}
