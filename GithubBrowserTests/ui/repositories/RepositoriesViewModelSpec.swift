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

// swiftlint:disable file_length
class RepositoriesViewModelSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("RepositoriesViewModel") {
            var sut: RepositoriesViewModel!
            var mockGitHubService: MockGitHubService!
            var testScheduler: TestScheduler!
            var disposeBag: DisposeBag!
            var assembler: MainAssembler!

            var emittedRepositoriesSectionList: [GitHubRepositoriesSection] = []
            var emittedFlowSteps: [AppStep] = []
            var emittedShowLoadingValues: [Bool] = []
            
            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container
                sut = assembler.resolver.resolve(RepositoriesViewModel.self)
                mockGitHubService = assembler.resolver.resolve(GitHubServiceProtocol.self) as? MockGitHubService
                testScheduler = assembler.resolver.resolve(SchedulerType.self) as? TestScheduler
                disposeBag = DisposeBag()

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

            func stubSearchResult(withTotalItemCount totalCount: Int, pageCount: Int) -> GitHubSearchResult {
                var repositories: [GitHubRepository] = []
                for i in 0...pageCount-1 {
                    repositories.append(GitHubRepository(
                                            fullName: "Repo-\(i)",
                                            description: "any",
                                            language: "any",
                                            stargazersCount: 1,
                                            htmlUrlString: "any",
                                            owner: Owner(login: "any", avatarUrlString: "any")))
                }
                return GitHubSearchResult(totalCount: totalCount, repositories: repositories)
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
                        mockGitHubService.verifyFindRepositoriesCalled(
                            times: 1, withSearchTerm: "abc", page: 1, pageSize: 15)
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
                        mockGitHubService.verifyFindRepositoriesCalled(
                            withSearchTerm: "abc", page: 1, pageSize: 15)
                    }
                }

                context("when querying the repositories fails") {
                    let expectedAlertDetails = AlertDetails(
                        title: "Error",
                        message: "An unexpected error has occurred.",
                        actions: [AlertAction(title: "OK", style: .cancel)])
                    beforeEach {
                        mockGitHubService.expectFindRepositoriesToFail(
                            withError: GitHubBrowserError.unexpectedError)
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
                            mockGitHubService.verifyFindRepositoriesCalled(
                                times: 2, withSearchTerm: "abc", page: 1, pageSize: 15)
                        }
                    }
                }

                context("""
                    when querying the repositories succeeds
                    and the result fits in one page
                    """) {
                    beforeEach {
                        mockGitHubService.expectFindRepositoriesToEmit(
                            stubSearchResult(withTotalItemCount: 5, pageCount: 1))
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(1000)
                    }
                    it("requests to hide the loading indicator") {
                        expect(emittedShowLoadingValues).to(equal([true, false]))
                    }
                    it("emits a section of repositories without next-page-indicator") {
                        guard emittedRepositoriesSectionList.count == 1 else {
                            return fail("Expected to produce 2 emissions, got \(emittedRepositoriesSectionList.count)")
                        }

                        let theEmittedSection = emittedRepositoriesSectionList[0]
                        expect(theEmittedSection.searchTerm).to(equal("abc"))
                        expect(theEmittedSection.numPages).to(equal(1))
                        expect(theEmittedSection.items).to(haveCount(1))
                    }
                }

                context("""
                    when querying the repositories succeeds
                    and the result does not fit in one page
                    """) {
                    beforeEach {
                        mockGitHubService.expectFindRepositoriesToEmit(
                            stubSearchResult(withTotalItemCount: 20, pageCount: 15))
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(1000)
                    }
                    it("requests to hide the loading indicator") {
                        expect(emittedShowLoadingValues).to(equal([true, false]))
                    }
                    it("emits a section of repositories with a next-page-indicator") {
                        guard emittedRepositoriesSectionList.count == 1 else {
                            return fail("Expected to produce 2 emissions, got \(emittedRepositoriesSectionList.count)")
                        }

                        let theEmittedSection = emittedRepositoriesSectionList[0]
                        expect(theEmittedSection.searchTerm).to(equal("abc"))
                        expect(theEmittedSection.numPages).to(equal(1))
                        expect(theEmittedSection.items).to(haveCount(16))
                    }
                }

                context("""
                given that the client has already sent a search term,
                when the client requests to load the next page of the matching repositories
                """) {
                    beforeEach {
                        mockGitHubService.expectFindRepositoriesToEmit(
                            stubSearchResult(withTotalItemCount: 20, pageCount: 15))
                        sut.searchTerm.accept("abc")
                        testScheduler.advanceTo(1000)
                        mockGitHubService.expectFindRepositoriesToEmit(
                            stubSearchResult(withTotalItemCount: 20, pageCount: 5))
                        sut.loadNextPage.accept(())
                    }
                    it("queries GitHub the next 15 matching repositories") {
                        mockGitHubService.verifyFindRepositoriesCalled(
                            times: 2, withSearchTerm: "abc", page: 2, pageSize: 15)
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
                        expect(firstEmission.numPages).to(equal(1))
                        expect(firstEmission.items).to(haveCount(16))

                        let secondEmission = emittedRepositoriesSectionList[1]
                        expect(secondEmission.searchTerm).to(equal("abc"))
                        expect(secondEmission.numPages).to(equal(2))
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
                return MockGitHubService()
            }.inObjectScope(.container)

            container.register(SchedulerType.self) { _ in
                return TestScheduler(initialClock: 0, resolution: 0.001)
            }.inObjectScope(.container)
        }
    }
}
