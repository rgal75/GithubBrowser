//
//  RepositoriesViewControllerSpec.swift
//  GithubBrowser
//
//  Copyright (c) 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import Nimble
import Quick
import Swinject
import SwinjectStoryboard
import UIKit
import RxSwift
import RxCocoa
import InjectPropertyWrapper
import SwiftyMocky

// swiftlint:disable file_length function_parameter_count
class RepositoriesViewControllerSpec: QuickSpec {
    
    // swiftlint:disable function_body_length
    override func spec() {
        describe("RepositoriesViewController") {
            var sut: RepositoriesViewController!
            var mockViewModel: RepositoriesViewModelProtocolMock!
            var assembler: MainAssembler!

            var searchTermSpy: ObservableSpy<PublishRelay<String>>!
            var repositorySelectedSpy: ObservableSpy<PublishRelay<GitHubRepository>>!
            var loadNextPageSpy: ObservableSpy<PublishRelay<Void>>!

            var stubbedRepositories: StubObservable<GitHubRepositoriesSection>!
            var stubbedShowLoading: StubObservable<Bool>!

            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container
                sut = StoryboardScene.RepositoriesViewController.repositoriesViewController.instantiate()
                mockViewModel = sut.viewModel as? RepositoriesViewModelProtocolMock

                searchTermSpy = ObservableSpy(with: PublishRelay<String>())
                Given(mockViewModel, .searchTerm(getter: searchTermSpy.observable))

                repositorySelectedSpy = ObservableSpy(with: PublishRelay<GitHubRepository>())
                Given(mockViewModel, .repositorySelected(getter: repositorySelectedSpy.observable))

                loadNextPageSpy = ObservableSpy(with: PublishRelay<Void>())
                Given(mockViewModel, .loadNextPage(getter: loadNextPageSpy.observable))

                stubbedRepositories = StubObservable<GitHubRepositoriesSection>()
                Given(mockViewModel, .repositories(getter: stubbedRepositories.observable))

                stubbedShowLoading = StubObservable<Bool>()
                Given(mockViewModel, .showLoading(getter: stubbedShowLoading.observable))
            }
            
            afterEach {
                assembler.dispose()
            }

            func verifyRepositoriesTableRowCountIs(
                _ rowCount: Int,
                file: FileString = #file,
                line: UInt = #line) {
                expect(file: file, line: line, sut.repositoriesTable.numberOfSections)
                    .to(equal(1))
                expect(file: file, line: line, sut.repositoriesTable.numberOfRows(inSection: 0))
                    .to(equal(rowCount))
            }

            func verifyRepositoryCell(
                at row: Int,
                toHaveFullName expectedFullName: String,
                description expectedDescription: String,
                starsCount expectedStarsCount: String,
                language expectedLanguage: String,
                login expectedLogin: String,
                file: FileString = #file,
                line: UInt = #line) {
                guard let cell = sut.repositoriesTable.cellForRow(at: IndexPath(row: row, section: 0)) as? RepositoryCell else {
                    return fail("Expected a \(RepositoryCell.self), got something else.", file: file, line: line)
                }
                expect(file: file, line: line, cell.fullNameLabel.text).to(equal(expectedFullName))
                expect(file: file, line: line, cell.descriptionLabel.text).to(equal(expectedDescription))
                expect(file: file, line: line, cell.starsLabel.text).to(equal(expectedStarsCount))
                expect(file: file, line: line, cell.languageLabel.text).to(equal(expectedLanguage))
                expect(file: file, line: line, cell.loginLabel.text).to(equal(expectedLogin))
            }

            func verifyNextPageIndicatorCell(
                at row: Int,
                file: FileString = #file,
                line: UInt = #line) {
                let cell = sut.repositoriesTable.cellForRow(at: IndexPath(row: row, section: 0))
                guard (cell as? NextPageIndicatorCell) != nil else {
                    return fail("Expected a \(NextPageIndicatorCell.self), got \(String(describing: cell)).", file: file, line: line)
                }
            }

            func stubRepository(withFullName fullName: String) -> GitHubRepository {
                return GitHubRepository(
                    fullName: fullName,
                    description: "any",
                    language: "any",
                    stargazersCount: 1,
                    htmlUrlString: "any",
                    owner: Owner(login: "any", avatarUrlString: "any"))
            }

            it("can be instantiated") {
                expect(sut).toNot(beNil())
            }

            context("given that the view is loaded") {
                beforeEach {
                    sut.loadViewIfNeeded()
                }
                it("has `Repositories` as title") {
                    expect(sut.navigationItem.title).to(equal("Repositories"))
                }
                it("has a search bar") {
                    expect(sut.searchBar).toNot(beNil())
                }
                it("has `Enter search term` as placeholder in the search bar") {
                    expect(sut.searchBar.placeholder).to(equal("Enter search term"))
                }
                it("""
                    has a table view for repositories configured
                    for dynamic row heights
                    and to dismiss the keyboard on drag
                    """) {
                    expect(sut.repositoriesTable).toNot(beNil())
                    expect(sut.repositoriesTable.rowHeight).to(equal(UITableView.automaticDimension))
                    expect(sut.repositoriesTable.estimatedRowHeight).to(equal(120))
                    expect(sut.repositoriesTable.keyboardDismissMode).to(equal(UIScrollView.KeyboardDismissMode.onDrag))
                }
                it("""
                    has a view to represent the empty state of the repositories table
                    with an initial message
                    and a hidden loading indicator
                    """) {
                    expect(sut.repositoriesTable.backgroundView).to(be(sut.emptyStateView))
                    expect(sut.emptyStateLabel.text).to(equal("Enter your search criteria to find GitHub repositories."))
                    expect(sut.loadingIndicator.isHidden).to(beTrue())
                }
                it("sends an empty search term to the view model") {
                    searchTermSpy.verifyTriggered(times: 1, with: "")

                }
                context("when the user enters a search term") {
                    beforeEach {
                        searchTermSpy.reset()
                        sut.searchBar.text = "any"
                        sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "any")
                    }
                    it("sends the search term to the view model") {
                        searchTermSpy.verifyTriggered(times: 1, with: "any")
                    }
                }

                context("when the view model emits an empty list of repositories") {
                    beforeEach {
                        stubbedRepositories.emit(
                            GitHubRepositoriesSection(
                                searchTerm: "a",
                                nextPageUrl: nil,
                                isNewSearch: true,
                                items: [
                                    .repository(stubRepository(withFullName: "Repo-1"))
                                ]))
                        verifyRepositoriesTableRowCountIs(1)
                        // when
                        stubbedRepositories.emit(
                            GitHubRepositoriesSection(
                                searchTerm: "ab",
                                nextPageUrl: nil,
                                isNewSearch: true,
                                items: []))
                    }
                    it("clears the repositories table") {
                        verifyRepositoriesTableRowCountIs(0)
                    }
                    it("shows a message to explain why the table is empty") {
                        expect(sut.emptyStateLabel.text).to(equal("No repositories match your search criteria."))
                    }
                }

                context("when the view model emits a list of repositories with a next-page indicator") {
                    var repository1: GitHubRepository!
                    beforeEach {
                        repository1 = GitHubRepository(
                            fullName: "Repo-1",
                            description: "Repo-1-desc",
                            language: "Repo-1-lang",
                            stargazersCount: 1,
                            htmlUrlString: "Repo-1-url",
                            owner: Owner(login: "Repo-1-owner", avatarUrlString: "Repo-1-avatar-url"))
                        stubbedRepositories.emit(
                            GitHubRepositoriesSection(
                                searchTerm: "any",
                                nextPageUrl: nil,
                                isNewSearch: true,
                                items: [
                                    .repository(repository1),
                                    .repository(GitHubRepository(
                                                    fullName: "Repo-2",
                                                    description: "Repo-2-desc",
                                                    language: "Repo-2-lang",
                                                    stargazersCount: 2,
                                                    htmlUrlString: "Repo-2-url",
                                                    owner: Owner(login: "Repo-2-owner", avatarUrlString: "Repo-2-avatar-url"))),
                                    .nextPageIndicator
                                ]))
                    }
                    it("""
                        shows the repositories in the repositories table
                        along with a next-page-indicator cell
                        """) {
                        verifyRepositoriesTableRowCountIs(3)
                        verifyRepositoryCell(
                            at: 0,
                            toHaveFullName: "Repo-1",
                            description: "Repo-1-desc",
                            starsCount: "1",
                            language: "Repo-1-lang",
                            login: "Repo-1-owner")
                        verifyRepositoryCell(
                            at: 1,
                            toHaveFullName: "Repo-2",
                            description: "Repo-2-desc",
                            starsCount: "2",
                            language: "Repo-2-lang",
                            login: "Repo-2-owner")
                        verifyNextPageIndicatorCell(at: 2)
                    }

                    context("when the user selects a repository") {
                        beforeEach {
                            sut.repositoriesTable.delegate?.tableView?(
                                sut.repositoriesTable, didSelectRowAt: IndexPath(row: 0, section: 0))
                        }
                        it("sends the selected repository the view model") {
                            repositorySelectedSpy.verifyTriggered(times: 1, with: repository1)
                        }
                    }
                }

                context("when the next-page-indicator cell becomes visible") {
                    let nextPageIndicatorCell = NextPageIndicatorCell()
                    let activityIndicator = UIActivityIndicatorView()
                    beforeEach {
                        nextPageIndicatorCell.loadingIndicator = activityIndicator
                        sut.repositoriesTable.delegate!.tableView!(
                            sut.repositoriesTable,
                            willDisplay: nextPageIndicatorCell,
                            forRowAt: IndexPath(row: 123, section: 0))
                    }
                    it("animates the activity indicator in the cell") {
                        expect(nextPageIndicatorCell.loadingIndicator.isAnimating).to(beTrue())
                    }
                    it("requests the view model to load the next page") {
                        loadNextPageSpy.verifyTriggered(times: 1)
                    }
                }

                context("""
                    given that the loading indicator is hidden,
                    when the view model requests to show the loading indicator
                    """) {
                    beforeEach {
                        // given
                        sut.loadingIndicator.isHidden = true
                        sut.loadingIndicator.startAnimating()
                        // when
                        stubbedShowLoading.emit(true)
                    }
                    it("shows the loading indicator and hides the empty state message") {
                        expect(sut.loadingIndicator.isHidden).to(beFalse())
                        expect(sut.loadingIndicator.isAnimating).to(beTrue())
                        expect(sut.emptyStateLabel.isHidden).to(beTrue())
                    }
                }

                context("""
                    given that the loading indicator is shown,
                    when the view model requests to hide the loading indicator
                    """) {
                    beforeEach {
                        // given
                        sut.loadingIndicator.isHidden = false
                        sut.loadingIndicator.stopAnimating()
                        // when
                        stubbedShowLoading.emit(false)
                    }
                    it("hides the loading indicator and shows the emtpy state message") {
                        expect(sut.loadingIndicator.isHidden).to(beTrue())
                        expect(sut.loadingIndicator.isAnimating).to(beFalse())
                        expect(sut.emptyStateLabel.isHidden).to(beFalse())
                    }
                }
            }
        }
    }
}

extension RepositoriesViewControllerSpec {
    
    class TestAssembly: Assembly {
        func assemble(container: Container) {
            container.register(RepositoriesViewModelProtocol.self) { _ in
                let instance = RepositoriesViewModelProtocolMock()
                return instance
            }.inObjectScope(.transient)
        }
    }
}
