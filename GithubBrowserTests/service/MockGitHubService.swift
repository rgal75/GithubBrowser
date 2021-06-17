//
//  MockGitHubService.swift
//  GithubBrowserTests
//
//  Copyright © 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import RxSwift
import Nimble

class MockGitHubServiceBase: GitHubServiceProtocol {

    var invokedFindRepositories = false
    var invokedFindRepositoriesCount = 0
    var invokedFindRepositoriesParameters: (searchTerm: String, page: Int, pageSize: Int)?
    var invokedFindRepositoriesParametersList = [(searchTerm: String, page: Int, pageSize: Int)]()
    var stubbedFindRepositoriesResult: Single<GitHubSearchResult>!

    func findRepositories(
        withSearchTerm searchTerm: String,
        page: Int,
        pageSize: Int) -> Single<GitHubSearchResult> {
        invokedFindRepositories = true
        invokedFindRepositoriesCount += 1
        invokedFindRepositoriesParameters = (searchTerm, page, pageSize)
        invokedFindRepositoriesParametersList.append((searchTerm, page, pageSize))
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
        page expectedPage: Int,
        pageSize expectedPageSize: Int,
        file: FileString = #file,
        line: UInt = #line) {
        expect(file: file, line: line, self.invokedFindRepositoriesCount).to(equal(callCount))
        expect(file: file, line: line, self.invokedFindRepositoriesParameters?.searchTerm).to(equal(expectedSearchTerm))
        expect(file: file, line: line, self.invokedFindRepositoriesParameters?.page).to(equal(expectedPage))
        expect(file: file, line: line, self.invokedFindRepositoriesParameters?.pageSize).to(equal(expectedPageSize))
    }
}
