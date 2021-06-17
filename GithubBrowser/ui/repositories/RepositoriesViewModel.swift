//
//  RepositoriesViewModel.swift
//  GithubBrowser
//
//  Copyright (c) 2021. VividMind. All rights reserved.
//

import RxSwift
import RxRelay
import RxFlow
import InjectPropertyWrapper

enum GitHubRepositoryItemType: Equatable {
    case repository(GitHubRepository)
    case nextPageIndicator
}

struct GitHubRepositoriesSection {
    var searchTerm: String
    var numPages: Int
    var totalPages: Int
    var items: [GitHubRepositoryItemType]
}

protocol RepositoriesViewModelProtocol: Stepper {
    // MARK: - Input
    var searchTerm: PublishRelay<String> { get }
    var loadNextPage: PublishRelay<Void> { get }

    // MARK: - Output
    var repositories: Observable<GitHubRepositoriesSection> { get }
}

private let REPOSITORIES_PAGE_SIZE = 15

class RepositoriesViewModel: RepositoriesViewModelProtocol {

    // MARK: - Input
    var searchTerm = PublishRelay<String>()
    var loadNextPage = PublishRelay<Void>()

    // MARK: - Output
    var repositories: Observable<GitHubRepositoriesSection> = .never()

    // MARK: - Internal
    var steps = PublishRelay<Step>()
    @Inject private var gitHubService: GitHubServiceProtocol
    @Inject var typingScheduler: SchedulerType
    private var disposeBag = DisposeBag()

    init() {
        let gitHubService = self.gitHubService

        let firstPageRequest$: Observable<GitHubRepositoriesSection> = searchTerm
            .debounce(.milliseconds(600), scheduler: typingScheduler)
            .map({ (searchTerm: String) -> GitHubRepositoriesSection in
                return GitHubRepositoriesSection(
                    searchTerm: searchTerm, numPages: 0, totalPages: 0, items: [])
            })
        let nextPageRequest$: Observable<GitHubRepositoriesSection> = Observable.deferred { [weak self] in
            guard let self = self else { return .never() }
            return self.loadNextPage
                .withLatestFrom(self.repositories)
        }

        repositories = Observable.merge(firstPageRequest$, nextPageRequest$)
            .flatMap({ (lastSection: GitHubRepositoriesSection) -> Observable<GitHubRepositoriesSection> in
                let searchTerm = lastSection.searchTerm
                let nextPage = lastSection.numPages + 1
                var totalPageCount = 0
                var repositories$: Observable<[GitHubRepositoryItemType]> = .never()
                if searchTerm.isEmpty {
                    repositories$ = Observable.just([])
                } else {
                    repositories$ = gitHubService.findRepositories(
                        withSearchTerm: searchTerm, page: nextPage, pageSize: REPOSITORIES_PAGE_SIZE)
                        .debug(">>> findRepositories")
                        .map({ (searchResult: GitHubSearchResult) -> [GitHubRepositoryItemType] in
                            totalPageCount = searchResult.totalCount
                            return searchResult.repositories.map { repo -> GitHubRepositoryItemType in
                                return .repository(repo)
                            }
                        })
                        .catchError(showAlert: { [weak self] (alertDetails: AlertDetails) in
                            self?.steps.accept(AppStep.alert(alertDetails))
                        })
                        .asObservable()
                }
                return repositories$
                    .map({ (newPageItems: [GitHubRepositoryItemType]) -> GitHubRepositoriesSection in
                        var repositoryItems = lastSection.items + newPageItems
                        repositoryItems.removeAll(where: { (item: GitHubRepositoryItemType) in
                            return item == .nextPageIndicator
                        })
                        if totalPageCount > nextPage * REPOSITORIES_PAGE_SIZE {
                            repositoryItems.append(.nextPageIndicator)
                        }
                        return GitHubRepositoriesSection(
                            searchTerm: searchTerm,
                            numPages: nextPage,
                            totalPages: totalPageCount,
                            items: repositoryItems)
                    })
            })
            .retry()
            .share(replay: 1)
    }
}
