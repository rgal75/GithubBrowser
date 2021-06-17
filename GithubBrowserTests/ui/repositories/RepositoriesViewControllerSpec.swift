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

// swiftlint:disable file_length
class RepositoriesViewControllerSpec: QuickSpec {
    
    // swiftlint:disable function_body_length
    override func spec() {
        describe("RepositoriesViewController") {
            var sut: RepositoriesViewController!
            var mockViewModel: MockRepositoriesViewModel!
            var disposeBag: DisposeBag!
            var assembler: MainAssembler!
            
            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container
                sut = StoryboardScene.RepositoriesViewController.repositoriesViewController.instantiate()
                mockViewModel = sut.viewModel as? MockRepositoriesViewModel
                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
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
                file: FileString = #file,
                line: UInt = #line) {
                guard let cell = sut.repositoriesTable.cellForRow(at: IndexPath(row: row, section: 0)) as? RepositoryCell else {
                    return fail("Expected a \(RepositoryCell.self), got something else.", file: file, line: line)
                }
                expect(file: file, line: line, cell.fullNameLabel.text).to(equal(expectedFullName))
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
                it("has a table view for repositories") {
                    expect(sut.repositoriesTable).toNot(beNil())
                }
                it("""
                    has a view to represent the empty state of the repositories table
                    with an empty message
                    """) {
                    expect(sut.repositoriesTable.backgroundView).to(be(sut.emptyStateView))
                    expect(sut.emptyStateLabel.text).to(beEmpty())
                }
                it("sends an empty search term to the view model") {
                    mockViewModel.verifySearchTermTriggered(
                        withSearchTerm: "")

                }
                context("when the user enters a search term") {
                    beforeEach {
                        mockViewModel.resetVerifications()
                        sut.searchBar.text = "any"
                        sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "any")
                    }
                    it("sends the search term to the view model") {
                        mockViewModel.verifySearchTermTriggered(
                            withSearchTerm: "any")
                    }
                }

                context("when the view model emits an empty list of repositories") {
                    beforeEach {
                        mockViewModel.expectRepositoriesToEmit(
                            GitHubRepositoriesSection(
                                searchTerm: "any",
                                numPages: 1,
                                totalPages: 1,
                                items: [
                                    .repository(GitHubRepository(fullName: "Repo-1"))
                                ]))
                        verifyRepositoriesTableRowCountIs(1)
                        // when
                        mockViewModel.expectRepositoriesToEmit(
                            GitHubRepositoriesSection(
                                searchTerm: "any",
                                numPages: 1,
                                totalPages: 1,
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
                    beforeEach {
                        mockViewModel.expectRepositoriesToEmit(
                            GitHubRepositoriesSection(
                                searchTerm: "any",
                                numPages: 1,
                                totalPages: 2,
                                items: [
                                    .repository(GitHubRepository(fullName: "Repo-1")),
                                    .repository(GitHubRepository(fullName: "Repo-2")),
                                    .nextPageIndicator
                                ]))
                    }
                    it("""
                        shows the repositories in the repositories table
                        along with a next-page-indicator cell
                        """) {
                        verifyRepositoriesTableRowCountIs(3)
                        verifyRepositoryCell(at: 0, toHaveFullName: "Repo-1")
                        verifyRepositoryCell(at: 1, toHaveFullName: "Repo-2")
                        verifyNextPageIndicatorCell(at: 2)
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
                        mockViewModel.verifyLoadNextPageTriggered()
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
                let instance = MockRepositoriesViewModel()
                return instance
            }.inObjectScope(.transient)
        }
    }
}
