//
//  GitHubServiceSpec.swift
//  GithubBrowser
//
//  Copyright (c) 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import Nimble
import Quick
import RxSwift
import Swinject
import Moya
import InjectPropertyWrapper

private var searchRepositoriesParameters: (q: String?, perPage: Int?, page: Int?)?
private var expectedSearchRepositoriesResponse: EndpointSampleResponse =
    .networkResponse(502, Data())
private let searchRepositoriesSuccessResponseData = """
{
    "total_count": 308,
    "incomplete_results": false,
    "items": [
        {
            "id": 56589037,
            "node_id": "MDEwOlJlcG9zaXRvcnk1NjU4OTAzNw==",
            "name": "RxRealm",
            "full_name": "RxSwiftCommunity/RxRealm",
            "private": false,
            "owner": {
                "login": "RxSwiftCommunity",
                "id": 15903991,
                "node_id": "MDEyOk9yZ2FuaXphdGlvbjE1OTAzOTkx",
                "avatar_url": "https://avatars.githubusercontent.com/u/15903991?v=4",
                "gravatar_id": "",
                "url": "https://api.github.com/users/RxSwiftCommunity",
                "html_url": "https://github.com/RxSwiftCommunity",
                "followers_url": "https://api.github.com/users/RxSwiftCommunity/followers",
                "following_url": "https://api.github.com/users/RxSwiftCommunity/following{/other_user}",
                "gists_url": "https://api.github.com/users/RxSwiftCommunity/gists{/gist_id}",
                "starred_url": "https://api.github.com/users/RxSwiftCommunity/starred{/owner}{/repo}",
                "subscriptions_url": "https://api.github.com/users/RxSwiftCommunity/subscriptions",
                "organizations_url": "https://api.github.com/users/RxSwiftCommunity/orgs",
                "repos_url": "https://api.github.com/users/RxSwiftCommunity/repos",
                "events_url": "https://api.github.com/users/RxSwiftCommunity/events{/privacy}",
                "received_events_url": "https://api.github.com/users/RxSwiftCommunity/received_events",
                "type": "Organization",
                "site_admin": false
            },
            "html_url": "https://github.com/RxSwiftCommunity/RxRealm",
            "description": "RxSwift extension for RealmSwift's types",
            "fork": false,
            "url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm",
            "forks_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/forks",
            "keys_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/keys{/key_id}",
            "collaborators_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/collaborators{/collaborator}",
            "teams_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/teams",
            "hooks_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/hooks",
            "issue_events_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/issues/events{/number}",
            "events_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/events",
            "assignees_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/assignees{/user}",
            "branches_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/branches{/branch}",
            "tags_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/tags",
            "blobs_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/git/blobs{/sha}",
            "git_tags_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/git/tags{/sha}",
            "git_refs_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/git/refs{/sha}",
            "trees_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/git/trees{/sha}",
            "statuses_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/statuses/{sha}",
            "languages_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/languages",
            "stargazers_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/stargazers",
            "contributors_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/contributors",
            "subscribers_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/subscribers",
            "subscription_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/subscription",
            "commits_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/commits{/sha}",
            "git_commits_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/git/commits{/sha}",
            "comments_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/comments{/number}",
            "issue_comment_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/issues/comments{/number}",
            "contents_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/contents/{+path}",
            "compare_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/compare/{base}...{head}",
            "merges_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/merges",
            "archive_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/{archive_format}{/ref}",
            "downloads_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/downloads",
            "issues_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/issues{/number}",
            "pulls_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/pulls{/number}",
            "milestones_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/milestones{/number}",
            "notifications_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/notifications{?since,all,participating}",
            "labels_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/labels{/name}",
            "releases_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/releases{/id}",
            "deployments_url": "https://api.github.com/repos/RxSwiftCommunity/RxRealm/deployments",
            "created_at": "2016-04-19T10:53:02Z",
            "updated_at": "2021-06-16T08:17:03Z",
            "pushed_at": "2021-05-10T12:41:41Z",
            "git_url": "git://github.com/RxSwiftCommunity/RxRealm.git",
            "ssh_url": "git@github.com:RxSwiftCommunity/RxRealm.git",
            "clone_url": "https://github.com/RxSwiftCommunity/RxRealm.git",
            "svn_url": "https://github.com/RxSwiftCommunity/RxRealm",
            "homepage": "",
            "size": 21695,
            "stargazers_count": 1021,
            "watchers_count": 1021,
            "language": "Swift",
            "has_issues": true,
            "has_projects": true,
            "has_downloads": true,
            "has_wiki": true,
            "has_pages": false,
            "forks_count": 175,
            "mirror_url": null,
            "archived": false,
            "disabled": false,
            "open_issues_count": 9,
            "license": {
                "key": "mit",
                "name": "MIT License",
                "spdx_id": "MIT",
                "url": "https://api.github.com/licenses/mit",
                "node_id": "MDc6TGljZW5zZTEz"
            },
            "forks": 175,
            "open_issues": 9,
            "watchers": 1021,
            "default_branch": "main",
            "score": 1.0
        }
    ]
}
""".data(using: String.Encoding.utf8)!

// swiftlint:disable file_length
class GitHubServiceSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("GitHubService") {
            var sut: GitHubService!
            var disposeBag: DisposeBag!
            var assembler: MainAssembler!
            
            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container
                sut = assembler.resolver.resolve(GitHubService.self)
                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
                assembler.dispose()
            }

            func statusCode(from error: Error) -> Int? {
                guard let moyaError = error as? MoyaError,
                    case let MoyaError.underlying(underlyingError, _) = moyaError,
                    case let MoyaError.statusCode(errorResponse) = underlyingError else {
                    return nil
                }
                return errorResponse.statusCode
            }

            it("has a Moya provider") {
                expect(sut.moya).toNot(beNil())
            }

            context("findRepositories") {
                it("passes the q, per_page and page parameters to the API") {
                    // when
                    sut.findRepositories(withSearchTerm: "theQuery", page: 5, pageSize: 25)
                        .subscribe().disposed(by: disposeBag)
                    // then
                    expect(searchRepositoriesParameters?.q).to(equal("theQuery"))
                    expect(searchRepositoriesParameters?.page).to(equal(5))
                    expect(searchRepositoriesParameters?.perPage).to(equal(25))
                }

                context("when the search succeeds") {
                    beforeEach {
                        expectedSearchRepositoriesResponse =
                            .networkResponse(200, searchRepositoriesSuccessResponseData)
                    }
                    it("emits the search result") {
                        // when
                        var emittedResult: GitHubSearchResult?
                        var emittedError: Error?
                        sut.findRepositories(withSearchTerm: "theQuery", page: 5, pageSize: 25)
                            .subscribe(
                                onSuccess: { (result: GitHubSearchResult) in
                                    emittedResult = result
                                },
                                onFailure: { (error: Error) in
                                    emittedError = error
                                }).disposed(by: disposeBag)
                        // then
                        expect(emittedError).to(beNil())
                        expect(emittedResult?.totalCount).to(equal(308))
                        let emittedRepositories = emittedResult?.repositories
                        guard emittedRepositories?.count == 1,
                              let emittedRepository = emittedRepositories?.last else {
                            return fail("Expected 1 repository, got \(String(describing: emittedRepositories?.count))")
                        }
                        expect(emittedRepository.fullName).to(equal("RxSwiftCommunity/RxRealm"))
                        expect(emittedRepository.description).to(equal("RxSwift extension for RealmSwift's types"))
                        expect(emittedRepository.language).to(equal("Swift"))
                        expect(emittedRepository.stargazersCount).to(equal(1021))
                        expect(emittedRepository.owner?.login).to(equal("RxSwiftCommunity"))
                        expect(emittedRepository.owner?.avatarUrlString).to(equal("https://avatars.githubusercontent.com/u/15903991?v=4"))
                    }
                }

                context("when the search fails with HTTP 503") {
                    beforeEach {
                        expectedSearchRepositoriesResponse = .networkResponse(503, Data())
                    }
                    it("emits an error") {
                        // when
                        var emittedResult: GitHubSearchResult?
                        var emittedError: Error?
                        sut.findRepositories(withSearchTerm: "theQuery", page: 5, pageSize: 25)
                            .subscribe(
                                onSuccess: { (result: GitHubSearchResult) in
                                    emittedResult = result
                                },
                                onFailure: { (error: Error) in
                                    emittedError = error
                                }).disposed(by: disposeBag)
                        // then
                        expect(emittedError).toNot(beNil())
                        let statusCode = statusCode(from: emittedError!)
                        expect(statusCode).to(equal(503))
                        expect(emittedResult).to(beNil())
                    }
                }

                context("when the search fails with HTTP 422") {
                    beforeEach {
                        expectedSearchRepositoriesResponse = .networkResponse(422, Data())
                    }
                    it("emits an error") {
                        // when
                        var emittedResult: GitHubSearchResult?
                        var emittedError: Error?
                        sut.findRepositories(withSearchTerm: "theQuery", page: 5, pageSize: 25)
                            .subscribe(
                                onSuccess: { (result: GitHubSearchResult) in
                                    emittedResult = result
                                },
                                onFailure: { (error: Error) in
                                    emittedError = error
                                }).disposed(by: disposeBag)
                        // then
                        expect(emittedError).toNot(beNil())
                        let statusCode = statusCode(from: emittedError!)
                        expect(statusCode).to(equal(422))
                        expect(emittedResult).to(beNil())
                    }
                }
            }
        }
    }
}

extension GitHubServiceSpec {
    
    class TestAssembly: Assembly {
        func assemble(container: Container) {
            container.register(GitHubService.self) { _ in
                let instance = GitHubService()
                return instance
            }.inObjectScope(.transient)

            container.register(MoyaProvider<GitHubApi>.self) { _ in
                return MoyaProvider<GitHubApi>(
                    endpointClosure: self.createStubEndpoint,
                    stubClosure: MoyaProvider.immediatelyStub,
                    plugins: [NetworkLoggerPlugin()])
            }.inObjectScope(.container)
        }

        func createStubEndpoint(withTarget target: GitHubApi) -> Endpoint {
            var sampleResponseClosure: Endpoint.SampleResponseClosure
            switch target {
            case let .searchRepositories(query, perPage, page):
                searchRepositoriesParameters = (q: query, perPage: perPage, page: page)
                sampleResponseClosure = { expectedSearchRepositoriesResponse }
            }
            return Endpoint(
                url: url(target),
                sampleResponseClosure: sampleResponseClosure,
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
        }

        func url(_ target: TargetType) -> String {
            return target.baseURL.appendingPathComponent(target.path).absoluteString
        }
    }
}
