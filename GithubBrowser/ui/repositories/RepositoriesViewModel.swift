//
//  RepositoriesViewModel.swift
//  GithubBrowser
//
//  Copyright (c) 2021. VividMind. All rights reserved.
//

import RxSwift
import RxRelay

enum GithubRepositoryItemType {
    case repository(GithubRepository)
    case nextPageIndicator
}

struct GithubRepository {
    var fullName: String
}

struct GithubRepositoriesSection {
  var items: [GithubRepositoryItemType]
}

protocol RepositoriesViewModelProtocol {
    // MARK: - Input
    var searchTerm: PublishRelay<String> { get }
    var loadNextPage: PublishRelay<Void> { get }
    
    // MARK: - Output
    var repositories: Observable<GithubRepositoriesSection> { get }
}

class RepositoriesViewModel: RepositoriesViewModelProtocol {

    // MARK: - Input
    var searchTerm = PublishRelay<String>()
    var loadNextPage = PublishRelay<Void>()
    
    // MARK: - Output
    var repositories: Observable<GithubRepositoriesSection> = .never()

    // MARK: - Internal
    private var disposeBag = DisposeBag()

    init() {
        loadNextPage
            .debug("loadNextPage")
            .subscribe().disposed(by: disposeBag)

        var result: [GithubRepositoryItemType] = [
            .repository(GithubRepository(fullName: "Repo-1")),
            .repository(GithubRepository(fullName: "Repo-2")),
            .repository(GithubRepository(fullName: "Repo-3")),
            .repository(GithubRepository(fullName: "Repo-4")),
            .repository(GithubRepository(fullName: "Repo-5")),
            .repository(GithubRepository(fullName: "Repo-6")),
            .repository(GithubRepository(fullName: "Repo-7")),
            .repository(GithubRepository(fullName: "Repo-8")),
            .repository(GithubRepository(fullName: "Repo-9")),
            .repository(GithubRepository(fullName: "Repo-10")),
            .repository(GithubRepository(fullName: "Repo-11")),
            .repository(GithubRepository(fullName: "Repo-12")),
            .repository(GithubRepository(fullName: "Repo-13")),
            .repository(GithubRepository(fullName: "Repo-14")),
            .repository(GithubRepository(fullName: "Repo-15")),
            .repository(GithubRepository(fullName: "Repo-16")),
            .repository(GithubRepository(fullName: "Repo-17")),
            .nextPageIndicator
        ]

        let nextPage: [GithubRepositoryItemType] = [
            .repository(GithubRepository(fullName: "Repo-18")),
            .repository(GithubRepository(fullName: "Repo-19")),
            .repository(GithubRepository(fullName: "Repo-20")),
            .repository(GithubRepository(fullName: "Repo-21")),
            .repository(GithubRepository(fullName: "Repo-22")),
            .repository(GithubRepository(fullName: "Repo-23")),
            .repository(GithubRepository(fullName: "Repo-24")),
            .repository(GithubRepository(fullName: "Repo-25")),
            .repository(GithubRepository(fullName: "Repo-26")),
            .repository(GithubRepository(fullName: "Repo-27")),
            .repository(GithubRepository(fullName: "Repo-28")),
            .nextPageIndicator
        ]

        repositories = searchTerm.debug("searchTerm")
            .filter({!$0.isEmpty})
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap({ [weak self] (_: String) -> Observable<GithubRepositoriesSection> in
                guard let self = self else { return .never() }
                return Observable.just(GithubRepositoriesSection(items: result))
                    .concat(self.loadNextPage.asObservable()
                                .delay(.seconds(3), scheduler: MainScheduler.instance)
                                .flatMap({ (_) -> Observable<GithubRepositoriesSection> in
                                    result =
                                        result.prefix(upTo: result.count - 1) + nextPage
                                    return Observable.just(GithubRepositoriesSection(items: result))
                                }))
            })
    }
}
