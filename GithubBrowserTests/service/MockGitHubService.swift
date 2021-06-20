//
//  MockGitHubService.swift
//  GithubBrowserTests
//
//  Copyright © 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import RxSwift
import Nimble

// swiftlint:disable large_tuple
class MockGitHubServiceBase: GitHubServiceProtocol {

    var invokedFindRepositories = false
    var invokedFindRepositoriesCount = 0
    var invokedFindRepositoriesParameters: (searchTerm: String, nextPageUrl: URL?, pageSize: Int)?
    var invokedFindRepositoriesParametersList = [(searchTerm: String, nextPageUrl: URL?, pageSize: Int)]()
    var stubbedFindRepositoriesResult: Single<GitHubSearchResult>!

    func findRepositories(
        withSearchTerm searchTerm: String,
        nextPageUrl: URL?,
        pageSize: Int) -> Single<GitHubSearchResult> {
        invokedFindRepositories = true
        invokedFindRepositoriesCount += 1
        invokedFindRepositoriesParameters = (searchTerm, nextPageUrl, pageSize)
        invokedFindRepositoriesParametersList.append((searchTerm, nextPageUrl, pageSize))
        return stubbedFindRepositoriesResult
    }
}

class MockGitHubService: MockGitHubServiceBase {

    override init() {
        super.init()
        stubbedFindRepositoriesResult = stubbedFindRepositoriesResultSubject.take(1).asSingle()
    }

    var stubbedFindRepositoriesResultSubject = ReplaySubject<GitHubSearchResult>.create(bufferSize: 1)

    func expectFindRepositoriesToEmit(_ repositories: GitHubSearchResult) {
        stubbedFindRepositoriesResultSubject.onNext(repositories)
    }

    func expectFindRepositoriesToFail(withError error: Error) {
        stubbedFindRepositoriesResultSubject.onError(error)
    }

    func verifyFindRepositoriesCalled(
        times callCount: Int = 1,
        withSearchTerm expectedSearchTerm: String,
        nextPageUrl expectedNextPageUrl: URL?,
        pageSize expectedPageSize: Int,
        file: FileString = #file,
        line: UInt = #line) {
        expect(file: file, line: line, self.invokedFindRepositoriesCount).to(equal(callCount))
        expect(file: file, line: line, self.invokedFindRepositoriesParameters?.searchTerm).to(equal(expectedSearchTerm))
        if let expectedNextPageUrl = expectedNextPageUrl {
            expect(file: file, line: line, self.invokedFindRepositoriesParameters?.nextPageUrl).to(equal(expectedNextPageUrl))
        } else {
            expect(file: file, line: line, self.invokedFindRepositoriesParameters?.nextPageUrl).to(beNil())
        }
        expect(file: file, line: line, self.invokedFindRepositoriesParameters?.pageSize).to(equal(expectedPageSize))
    }
}
