//
//  GitHubService.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation
import CocoaLumberjack
import RxSwift
import Moya
import InjectPropertyWrapper

//sourcery: AutoMockable
protocol GitHubServiceProtocol {
    func findRepositories(
        withSearchTerm searchTerm: String,
        nextPageUrl: URL?,
        pageSize: Int) -> Single<GitHubSearchResult>
}

class GitHubService: GitHubServiceProtocol {

    @Inject var moya: MoyaProvider<GitHubApi>!

    func findRepositories(
        withSearchTerm searchTerm: String,
        nextPageUrl: URL?,
        pageSize: Int) -> Single<GitHubSearchResult> {
        var request$: Single<Response> = .never()
        if let nextPageUrl = nextPageUrl {
            request$ = moya.rx.request(GitHubApi.nextPage(pageUrl: nextPageUrl))
        } else {
            request$ = moya.rx.request(GitHubApi.searchRepositories(
                                        query: searchTerm, perPage: pageSize))
        }
        return request$
            .flatMap({ (response: Response) -> Single<GitHubSearchResult> in
                guard let urlResponse = response.response else { return .never() }
                let endpoints = linkUrls(from: urlResponse.allHeaderFields)
                DDLogDebug(">>> endpoints: \(endpoints)")
                if let linkHeader = response.response?.allHeaderFields["Link"]/* as? String*/ {
                    DDLogDebug(">>> link header: \(linkHeader)")
                }
                var gitHubResult = try response.map(GitHubSearchResult.self)
                gitHubResult.nextPageUrl = endpoints["next"]
                return .just(gitHubResult)
            })
    }
}

func linkUrls(from headerFields: [AnyHashable: Any]) -> [String: URL] {

        var endpointsFound: [String: URL] = [:]

        if let linkHeaderString = headerFields["Link"] as? String {
            let linkItems = linkHeaderString
                .split(separator: ",")
                .map({ (linkSegment: Substring) -> [String] in
                return linkSegments(
                    in: String(linkSegment),
                    with: "<(.+)>; rel=\"([a-zA-Z_-]+)\"")
            })

            for linkItem in linkItems where linkItem.count > 0 {
                let linkType = linkItem[1]
                if let linkUrl = URL(string: linkItem[0]) {
                    endpointsFound[linkType] = linkUrl
                }
            }
        }

        return endpointsFound
    }

func linkSegments(in text: String, with regex: String) -> [String] {

    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        var matches: [String] = []
        DDLogDebug(">>> regex results: \(results)")
        for match in results {
            for n in 1..<match.numberOfRanges {
                let range = match.range(at: n)
                let r = text.index(text.startIndex, offsetBy: range.location) ..< text.index(text.startIndex, offsetBy: range.location+range.length)
                matches.append(text.substring(with: r))
            }
        }
        return matches
    } catch let error {
        DDLogError("invalid regex: \(error.localizedDescription)")
        return []
    }
}
