//
//  RepositoriesViewModel.swift
//  GithubBrowser
//
//  Copyright (c) 2021. VividMind. All rights reserved.
//

import RxSwift
import RxSwiftExt
import RxRelay
import RxFlow
import InjectPropertyWrapper

enum GitHubRepositoryItemType: Equatable {
    case repository(GitHubRepository)
    case nextPageIndicator
}

protocol GitHubRepositoriesSearchRequest {
    var searchTerm: String { get }
    var nextPageUrl: URL? { get }
    var items: [GitHubRepositoryItemType] { get }
}

struct InitialSearchRequest: GitHubRepositoriesSearchRequest {
    var searchTerm: String
    var nextPageUrl: URL? {
        return nil
    }
    var items: [GitHubRepositoryItemType] {
        return []
    }
}

struct GitHubRepositoriesSection: GitHubRepositoriesSearchRequest {
    var searchTerm: String
    var nextPageUrl: URL?
    var isNewSearch: Bool
    var items: [GitHubRepositoryItemType]
}

// sourcery: AutoMockable
protocol RepositoriesViewModelProtocol: Stepper {
    // MARK: - Input
    var searchTerm: PublishRelay<String> { get }
    var loadNextPage: PublishRelay<Void> { get }
    var repositorySelected: PublishRelay<GitHubRepository> { get }

    // MARK: - Output
    var repositories: Observable<GitHubRepositoriesSection> { get }
    var showLoading: Observable<Bool> { get }
}

private let REPOSITORIES_PAGE_SIZE = 15

class RepositoriesViewModel: RepositoriesViewModelProtocol {

    // MARK: - Input
    var searchTerm = PublishRelay<String>()
    var loadNextPage = PublishRelay<Void>()
    var repositorySelected = PublishRelay<GitHubRepository>()

    // MARK: - Output
    var repositories: Observable<GitHubRepositoriesSection> = .never()
    var showLoading: Observable<Bool> = .never()

    // MARK: - Internal
    var steps = PublishRelay<Step>()
    @Inject private var gitHubService: GitHubServiceProtocol
    @Inject var typingScheduler: SchedulerType
    private var disposeBag = DisposeBag()

    init() {
        let gitHubService = self.gitHubService

        let showLoadingSubject = PublishSubject<Bool>()
        showLoading = showLoadingSubject.asObservable()

        let firstPageRequest$: Observable<GitHubRepositoriesSearchRequest> = searchTerm
            .debounce(.milliseconds(600), scheduler: typingScheduler)
            .filter({ !$0.isEmpty })
            .map({ (searchTerm: String) -> GitHubRepositoriesSearchRequest in
                return InitialSearchRequest(searchTerm: searchTerm)
            })
            .do(onNext: { _ in showLoadingSubject.onNext(true) })

        let nextPageRequest$: Observable<GitHubRepositoriesSearchRequest> = Observable.deferred { [weak self] in
            guard let self = self else { return .never() }
            return self.loadNextPage
                .withLatestFrom(self.repositories, resultSelector: { _, lastRepositorySection in
                    return lastRepositorySection as GitHubRepositoriesSearchRequest
                })
        }

        repositories = Observable.merge(firstPageRequest$, nextPageRequest$)
            .flatMap({ (lastRequest: GitHubRepositoriesSearchRequest) -> Observable<GitHubRepositoriesSection> in
                let searchTerm = lastRequest.searchTerm
                var nextPageUrl = lastRequest.nextPageUrl
                guard !searchTerm.isEmpty else {
                    return Observable.just(GitHubRepositoriesSection(
                                            searchTerm: "",
                                            nextPageUrl: nextPageUrl,
                                            isNewSearch: true,
                                            items: []))
                }

                return gitHubService.findRepositories(
                    withSearchTerm: searchTerm,
                    nextPageUrl: nextPageUrl,
                    pageSize: REPOSITORIES_PAGE_SIZE)
                    .map({ (searchResult: GitHubSearchResult) -> [GitHubRepositoryItemType] in
                        nextPageUrl = searchResult.nextPageUrl
                        return searchResult.repositories.map { repo -> GitHubRepositoryItemType in
                            return .repository(repo)
                        }
                    })
                    .catchError(showAlert: { [weak self] (alertDetails: AlertDetails) in
                        self?.steps.accept(AppStep.alert(alertDetails))
                    })
                    .asObservable()
                    .map({ (newPageItems: [GitHubRepositoryItemType]) -> GitHubRepositoriesSection in
                        var repositoryItems = lastRequest.items + newPageItems
                        let isFirstPage = repositoryItems.count <= REPOSITORIES_PAGE_SIZE
                        repositoryItems.removeAll(where: { (item: GitHubRepositoryItemType) in
                            return item == .nextPageIndicator
                        })
                        if nextPageUrl != nil {
                            repositoryItems.append(.nextPageIndicator)
                        }
                        return GitHubRepositoriesSection(
                            searchTerm: searchTerm,
                            nextPageUrl: nextPageUrl,
                            isNewSearch: isFirstPage,
                            items: repositoryItems)
                    })
            })
            .do(onNext: { _ in showLoadingSubject.onNext(false)},
                onError: { _ in showLoadingSubject.onNext(false)})
            .retry()
            .share(replay: 1)

        repositorySelected
            .filterMap({ (repository: GitHubRepository) -> FilterMap<Step> in
                guard let repoUrl = URL(string: repository.htmlUrlString) else {
                    return .ignore
                }
                return .map(AppStep.safariViewRequested(url: repoUrl))
            })
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
}
