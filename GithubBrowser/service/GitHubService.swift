//
//  GitHubService.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import InjectPropertyWrapper

protocol GitHubServiceProtocol {
    func findRepositories(
        withSearchTerm searchTerm: String,
        page: Int,
        pageSize: Int) -> Single<GitHubSearchResult>
}

class GitHubService: GitHubServiceProtocol {

    @Inject var moya: MoyaProvider<GitHubApi>!

    func findRepositories(
        withSearchTerm searchTerm: String,
        page: Int,
        pageSize: Int) -> Single<GitHubSearchResult> {
        return moya.rx.request(GitHubApi.searchRepositories(
                                query: searchTerm, perPage: pageSize, page: page))
            .map(GitHubSearchResult.self)
    }
}
