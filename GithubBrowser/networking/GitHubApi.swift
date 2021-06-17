//
//  GitHubApi.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation
import Moya

enum GitHubApi {
    case searchRepositories(query: String, perPage: Int, page: Int)
    }

extension GitHubApi: TargetType {

    var baseURL: URL { return URL(string: "https://api.github.com")! }
    var path: String {
        switch self {
        case .searchRepositories:
            return "/search/repositories"
        }
    }

    var method: Moya.Method {
        switch self {
        case .searchRepositories:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .searchRepositories(query, perPage, page):
            return .requestParameters(
                parameters: ["q": query, "per_page": perPage, "page": page],
                encoding: URLEncoding.default)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var validationType: ValidationType {
        return .customCodes(Array(200..<400))
    }

    var headers: [String: String]? {
        return ["Accept": "application/vnd.github.v3+json"]
    }
}
