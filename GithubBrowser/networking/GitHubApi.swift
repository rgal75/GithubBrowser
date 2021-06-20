//
//  GitHubApi.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation
import Moya

enum GitHubApi {
    case searchRepositories(query: String, perPage: Int)
    case nextPage(pageUrl: URL)
}

extension GitHubApi: TargetType {

    var baseURL: URL {
        switch self {
        case .searchRepositories:
            return URL(string: "https://api.github.com")!
        case .nextPage(let pageUrl):
            return pageUrl
        }
    }
    var path: String {
        switch self {
        case .searchRepositories:
            return "/search/repositories"
        case .nextPage:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .searchRepositories, .nextPage:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .searchRepositories(query, perPage):
            return .requestParameters(
                    parameters: ["q": query, "per_page": perPage, "page": 1],
                    encoding: URLEncoding.default)
        case .nextPage:
            return .requestPlain
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
