//
//  MockRepositoriesViewModel.swift
//  GithubBrowserTests
//
//  Copyright © 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import Foundation
import RxSwift
import RxRelay
import RxFlow
import Nimble

class MockRepositoriesViewModelBase: RepositoriesViewModelProtocol {

    var invokedSearchTermGetter = false
    var invokedSearchTermGetterCount = 0
    var stubbedSearchTerm: PublishRelay<String>!

    var searchTerm: PublishRelay<String> {
        invokedSearchTermGetter = true
        invokedSearchTermGetterCount += 1
        return stubbedSearchTerm
    }

    var invokedLoadNextPageGetter = false
    var invokedLoadNextPageGetterCount = 0
    var stubbedLoadNextPage: PublishRelay<Void>!

    var loadNextPage: PublishRelay<Void> {
        invokedLoadNextPageGetter = true
        invokedLoadNextPageGetterCount += 1
        return stubbedLoadNextPage
    }

    var invokedRepositoriesGetter = false
    var invokedRepositoriesGetterCount = 0
    var stubbedRepositories: Observable<GitHubRepositoriesSection>!

    var repositories: Observable<GitHubRepositoriesSection> {
        invokedRepositoriesGetter = true
        invokedRepositoriesGetterCount += 1
        return stubbedRepositories
    }

    var invokedStepsGetter = false
    var invokedStepsGetterCount = 0
    var stubbedSteps: PublishRelay<Step>!

    var steps: PublishRelay<Step> {
        invokedStepsGetter = true
        invokedStepsGetterCount += 1
        return stubbedSteps
    }

    var invokedInitialStepGetter = false
    var invokedInitialStepGetterCount = 0
    var stubbedInitialStep: Step!

    var initialStep: Step {
        invokedInitialStepGetter = true
        invokedInitialStepGetterCount += 1
        return stubbedInitialStep
    }

    var invokedReadyToEmitSteps = false
    var invokedReadyToEmitStepsCount = 0

    func readyToEmitSteps () {
        invokedReadyToEmitSteps = true
        invokedReadyToEmitStepsCount += 1
    }
}

class MockRepositoriesViewModel: MockRepositoriesViewModelBase {

    private var disposeBag = DisposeBag()

    override init() {
        super.init()

        stubbedSearchTerm = PublishRelay<String>()
        stubbedSearchTerm.subscribe(onNext: { [weak self] (term: String) in
            self?.triggeredSearchTermCount += 1
            self?.stubbedSearchTermLastTriggerValue = term
        }).disposed(by: disposeBag)

        stubbedLoadNextPage = PublishRelay<Void>()
        stubbedLoadNextPage.subscribe(onNext: { [weak self] _ in
            self?.triggeredLoadNextPageCount += 1
        }).disposed(by: disposeBag)

        stubbedRepositories = stubbedRepositoriesSubject.asObservable()
        stubbedSteps = PublishRelay<Step>()
        stubbedInitialStep = RxFlowStep.home
    }

    func resetVerifications() {
        triggeredSearchTermCount = 0
        stubbedSearchTermLastTriggerValue = nil
    }

    // MARK: - searchTerm

    private var triggeredSearchTermCount = 0
    private var stubbedSearchTermLastTriggerValue: String?
    func verifySearchTermTriggered(
        times triggerCount: Int = 1,
        withSearchTerm expectedSearchTerm: String? = nil,
        file: FileString = #file,
        line: UInt = #line) {
        expect(file: file, line: line, self.triggeredSearchTermCount)
            .to(equal(triggerCount))
        if triggerCount > 0 {
            expect(file: file, line: line, self.stubbedSearchTermLastTriggerValue)
                .to(equal(expectedSearchTerm))

        }
    }

    // MARK: - loadNextPage

    private var triggeredLoadNextPageCount = 0
    func verifyLoadNextPageTriggered(
        times triggerCount: Int = 1,
        file: FileString = #file,
        line: UInt = #line) {
        expect(file: file, line: line, self.triggeredLoadNextPageCount)
            .to(equal(triggerCount))
    }

    // MARK: - repositories

    private var stubbedRepositoriesSubject = ReplaySubject<GitHubRepositoriesSection>.create(bufferSize: 1)
    func expectRepositoriesToEmit(_ repositories: GitHubRepositoriesSection) {
        stubbedRepositoriesSubject.onNext(repositories)
    }
}
