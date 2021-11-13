//
//  RepositoriesViewModelSpec.swift
//  GithubBrowser
//
//  Copyright (c) 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import Nimble
import Quick
import Swinject
import SwinjectStoryboard
import RxCocoa
import RxSwift
import InjectPropertyWrapper
import RxFlow
import RxTest
import SwiftyMocky

// swiftlint:disable file_length
class RepositoriesViewModelSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("RepositoriesViewModel") {
            var sut: RepositoriesViewModel!
            var mockGitHubService: GitHubServiceProtocolMock!
            var testScheduler: TestScheduler!
            var disposeBag: DisposeBag!
            var assembler: MainAssembler!

            var emittedRepositoriesSectionList: [GitHubRepositoriesSection] = []
            var emittedFlowSteps: [AppStep] = []
            var emittedShowLoadingValues: [Bool] = []

            var stubbedFindRepositoriesResultSubject: ReplaySubject<GitHubSearchResult>!
            var stubbedFindRepositoriesResult: Single<GitHubSearchResult>!

            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container
                sut = assembler.resolver.resolve(RepositoriesViewModel.self)
                mockGitHubService = assembler.resolver.resolve(GitHubServiceProtocol.self) as? GitHubServiceProtocolMock
                testScheduler = assembler.resolver.resolve(SchedulerType.self) as? TestScheduler
                disposeBag = DisposeBag()

                stubbedFindRepositoriesResultSubject = ReplaySubject<GitHubSearchResult>.create(bufferSize: 1)
                stubbedFindRepositoriesResult = stubbedFindRepositoriesResultSubject.take(1).asSingle()

                Given(
                    mockGitHubService,
                    .findRepositories(
                        withSearchTerm: .any,
                        nextPageUrl: .any,
                        pageSize: .any,
                        willReturn: stubbedFindRepositoriesResult))

                emittedRepositoriesSectionList.removeAll()
                sut.repositories.subscribe(onNext: { (section: GitHubRepositoriesSection) in
                    emittedRepositoriesSectionList.append(section)
                }).disposed(by: disposeBag)

                emittedFlowSteps.removeAll()
                sut.steps
                    .subscribe(onNext: { (step: Step) in
                        if let appStep = step as? AppStep {
                            emittedFlowSteps.append(appStep)
                        }
                    }).disposed(by: disposeBag)

                emittedShowLoadingValues.removeAll()
                sut.showLoading
                    .subscribe(onNext: { (show: Bool) in
                       emittedShowLoadingValues.append(show)
                    }).disposed(by: disposeBag)
            }
            
            afterEach {
                disposeBag = nil
                assembler.dispose()
            }

            func stubSearchResult(
                numItems: Int,
                nextPageUrl: URL? = nil) -> GitHubSearchResult {
                var repositories: [GitHubRepository] = []
                for i in 0...numItems-1 {
                    repositories.append(GitHubRepository(
                                            fullName: "Repo-\(i)",
                                            description: "any",
                                            language: "any",
                                            stargazersCount: 1,
                                            htmlUrlString: "any",
                                            owner: Owner(login: "any", avatarUrlString: "any")))
                }
                return GitHubSearchResult(
                    totalCount: 123, repositories: repositories, nextPageUrl: nextPageUrl)
            }

            context("repositories") {
                context("when the client sends an empty search term") {
                    beforeEach {
                        sut.searchTerm.accept("")
                        testScheduler.advanceTo(1000)
                    }
                    it("emits nothing") {
                        expect(emittedRepositoriesSectionList).to(haveCount(0))
                    }
                }

                context("when the client starts typing a search term quickly") {
                    beforeEach {
                        sut.searchTerm.accept("a")
                        sut.searchTerm.accept("ab")
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(601)
                    }
                    it("starts querying GitHub only if the user stops typing for at least 500 ms") {
                        Verify(mockGitHubService, 1, .findRepositories(
                            withSearchTerm: .value("abc"),
                            nextPageUrl: nil,
                            pageSize: .value(15)))
                    }
                }

                context("when the client sends a search term") {
                    beforeEach {
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(1000)
                    }
                    it("requests to show the loading indicator") {
                        expect(emittedShowLoadingValues).to(equal([true]))
                    }
                    it("queries GitHub the first 15 matching repositories") {
                        Verify(mockGitHubService, 1, .findRepositories(
                            withSearchTerm: .value("abc"),
                            nextPageUrl: nil,
                            pageSize: .value(15)))
                    }
                }

                context("when querying the repositories fails") {
                    let expectedAlertDetails = AlertDetails(
                        title: "Error",
                        message: "An unexpected error has occurred.",
                        actions: [AlertAction(title: "OK", style: .cancel)])
                    beforeEach {
                        stubbedFindRepositoriesResultSubject
                            .onError(GitHubBrowserError.unexpectedError)
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(1000)
                    }

                    it("requests to show an error alert") {
                        expect(emittedFlowSteps.last).to(equal(.alert(expectedAlertDetails)))
                    }

                    context("when the user dismisses the alert") {
                        beforeEach {
                            guard
                                let appStep = emittedFlowSteps.last,
                                case let AppStep.alert(receivedAlertDetails) = appStep else {
                                preconditionFailure("AppStep.alert is expected")
                            }
                            receivedAlertDetails.actions[0]
                                .handler!(receivedAlertDetails.actions[0].nativeAction)
                        }

                        it("requests to hide the loading indicator") {
                            expect(emittedShowLoadingValues).to(equal([true, false]))
                        }
                        
                        it("continues listening search requests") {
                            sut.searchTerm.accept("abc")
                            testScheduler.advanceTo(2001)
                            Verify(mockGitHubService, .findRepositories(
                                withSearchTerm: .value("abc"),
                                nextPageUrl: nil,
                                pageSize: .value(15)))
                        }
                    }
                }

                context("""
                    when querying the repositories succeeds
                    and the result fits in one page
                    """) {
                    beforeEach {
                        stubbedFindRepositoriesResultSubject.onNext(stubSearchResult(numItems: 1))
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(1000)
                    }
                    it("requests to hide the loading indicator") {
                        expect(emittedShowLoadingValues).to(equal([true, false]))
                    }
                    it("emits a section of repositories without next-page-indicator") {
                        guard emittedRepositoriesSectionList.count == 1 else {
                            return fail("Expected to produce 1 emission, got \(emittedRepositoriesSectionList.count)")
                        }

                        let theEmittedSection = emittedRepositoriesSectionList[0]
                        expect(theEmittedSection.searchTerm).to(equal("abc"))
                        expect(theEmittedSection.nextPageUrl).to(beNil())
                        expect(theEmittedSection.isNewSearch).to(beTrue())
                        expect(theEmittedSection.items).to(haveCount(1))
                    }
                }

                context("""
                    when querying the repositories succeeds
                    and the result does not fit in one page
                    """) {
                    beforeEach {
                        stubbedFindRepositoriesResultSubject.onNext(
                            stubSearchResult(
                                numItems: 15,
                                nextPageUrl: URL(string: "https://next.page.url")))
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(1000)
                    }
                    it("requests to hide the loading indicator") {
                        expect(emittedShowLoadingValues).to(equal([true, false]))
                    }
                    it("emits a section of repositories with a next-page-indicator") {
                        guard emittedRepositoriesSectionList.count == 1 else {
                            return fail("Expected to produce 1 emission, got \(emittedRepositoriesSectionList.count)")
                        }

                        let theEmittedSection = emittedRepositoriesSectionList[0]
                        expect(theEmittedSection.searchTerm).to(equal("abc"))
                        expect(theEmittedSection.isNewSearch).to(beTrue())
                        expect(theEmittedSection.items).to(haveCount(16))
                    }
                }

                context("""
                given that the client has already sent a search term,
                when the client requests to load the next page of the matching repositories
                """) {
                    let nextPageUrl = URL(string: "https://next.page.url")!
                    beforeEach {
                        stubbedFindRepositoriesResultSubject.onNext(
                            stubSearchResult(
                                numItems: 15,
                                nextPageUrl: nextPageUrl))
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(1000)
                        stubbedFindRepositoriesResultSubject.onNext(stubSearchResult(numItems: 5))
                        sut.loadNextPage.accept(())
                    }
                    it("queries GitHub the next page of repositories") {
                        Verify(mockGitHubService, 1, .findRepositories(
                            withSearchTerm: .value("abc"),
                            nextPageUrl: nil,
                            pageSize: .value(15)))
                        Verify(mockGitHubService, 1, .findRepositories(
                            withSearchTerm: .value("abc"),
                            nextPageUrl: .value(nextPageUrl),
                            pageSize: .value(15)))
                    }
                    it("""
                    emits the first page with 15 items plus the next-page-indicator
                    and then appends the second page with the remaining 5 items
                    """) {
                        guard emittedRepositoriesSectionList.count == 2 else {
                            return fail("Expected to produce 2 emissions, got \(emittedRepositoriesSectionList.count)")
                        }

                        let firstEmission = emittedRepositoriesSectionList[0]
                        expect(firstEmission.searchTerm).to(equal("abc"))
                        expect(firstEmission.nextPageUrl).to(equal(nextPageUrl))
                        expect(firstEmission.isNewSearch).to(beTrue())
                        expect(firstEmission.items).to(haveCount(16))

                        let secondEmission = emittedRepositoriesSectionList[1]
                        expect(secondEmission.searchTerm).to(equal("abc"))
                        expect(secondEmission.nextPageUrl).to(beNil())
                        expect(secondEmission.isNewSearch).to(beFalse())
                        expect(secondEmission.items).to(haveCount(20))
                    }
                }

                context("when the client tells that a repository was selected") {
                    beforeEach {
                        sut.repositorySelected.accept(GitHubRepository(
                                                        fullName: "Repo-1",
                                                        description: "Repo-1-desc",
                                                        language: "Repo-1-lang",
                                                        stargazersCount: 1,
                                                        htmlUrlString: "Repo-1-url",
                                                        owner: Owner(login: "Repo-1-owner", avatarUrlString: "Repo-1-avatar-url")))
                    }
                    it("requests to the repository in a Safari view") {
                        expect(emittedFlowSteps).to(haveCount(1))
                        expect(emittedFlowSteps.last).to(equal(AppStep.safariViewRequested(url: URL(string: "Repo-1-url")!)))
                    }
                }
            }
        }
    }
}

extension RepositoriesViewModelSpec {
    
    class TestAssembly: Assembly {
        func assemble(container: Container) {
            container.register(RepositoriesViewModel.self) { _ in
                return RepositoriesViewModel()
            }.inObjectScope(.transient)

            container.register(GitHubServiceProtocol.self) { _ in
                return GitHubServiceProtocolMock()
            }.inObjectScope(.container)

            container.register(SchedulerType.self) { _ in
                return TestScheduler(initialClock: 0, resolution: 0.001)
            }.inObjectScope(.container)
        }
    }
}
