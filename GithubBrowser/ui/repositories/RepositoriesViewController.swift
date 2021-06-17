//
//  RepositoriesViewController.swift
//  GithubBrowser
//
//  Copyright (c) 2021. VividMind. All rights reserved.
//

import UIKit
import CocoaLumberjack
import RxSwift
import RxSwiftExt
import RxCocoa
import RxFlow
import InjectPropertyWrapper
import RxDataSources
import Kingfisher

extension GitHubRepositoriesSection: SectionModelType {
  typealias Item = GitHubRepositoryItemType

   init(original: GitHubRepositoriesSection, items: [Item]) {
    self = original
    self.items = items
  }
}

class RepositoriesViewController: UIViewController, HasStepper {
    @IBOutlet weak var repositoriesTable: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @Inject var viewModel: RepositoriesViewModelProtocol!
    var disposeBag = DisposeBag()

    var searchBar: UISearchBar {
        return searchController.searchBar
    }

    var stepper: Stepper {
        return viewModel
    }

    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = L10n.Repositories.SearchBar.placeholder
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    deinit {
        DDLogDebug("RepositoriesViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        driveUI()
        bindToViewModel()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        navigationItem.searchController = searchController
        navigationItem.title = L10n.Repositories.title
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = false

        repositoriesTable.backgroundView = emptyStateView
        emptyStateLabel.text = ""
        loadingIndicator.isHidden = true
        repositoriesTable.rowHeight = UITableView.automaticDimension
        repositoriesTable.estimatedRowHeight = 120
        repositoriesTable.removeEmptyBottomCells()
        repositoriesTable.keyboardDismissMode = .onDrag
    }

    private func bindToViewModel() {
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchTerm).disposed(by: disposeBag)

        repositoriesTable.rx.willDisplayCell
            .filterMap({ (event: WillDisplayCellEvent) -> FilterMap<NextPageIndicatorCell> in
                guard let nextPageIndicatorCell = event.cell as? NextPageIndicatorCell else { return .ignore }
                return .map(nextPageIndicatorCell)
            })
            .do(onNext: { (nextPageIndicatorCell: NextPageIndicatorCell) in
                nextPageIndicatorCell.loadingIndicator.startAnimating()
            })
            .mapTo(())
            .bind(to: viewModel.loadNextPage).disposed(by: disposeBag)

    }

    private func driveUI() {
        let repositoriesDataSource = RxTableViewSectionedReloadDataSource<GitHubRepositoriesSection>(
            configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
                var cell: UITableViewCell?
                switch item {
                case .repository(let repository):
                    guard let repositoryCell = tableView.dequeueReusableCell(
                            withIdentifier: "RepositoryCell", for: indexPath)
                            as? RepositoryCell else {
                        preconditionFailure("Failed to dequeue \(RepositoryCell.self).")
                    }
                    repositoryCell.fullNameLabel?.text = repository.fullName
                    repositoryCell.descriptionLabel?.text = repository.description
                    repositoryCell.starsLabel?.text = "\(repository.stargazersCount)"
                    repositoryCell.languageLabel?.text = repository.language
                    repositoryCell.loginLabel?.text = repository.owner?.login
                    if let avatarUrlString = repository.owner?.avatarUrlString,
                       let avatarUrl = URL(string: avatarUrlString) {
                        repositoryCell.avatarImageView.kf.setImage(
                            with: avatarUrl, placeholder: UIImage(systemName: "questionmark.circle"))
                    }
                    cell = repositoryCell
                case .nextPageIndicator:
                    guard let nextPageIndicatorCell = tableView.dequeueReusableCell(
                            withIdentifier: "NextPageIndicatorCell", for: indexPath)
                            as? NextPageIndicatorCell else {
                        preconditionFailure("Failed to dequeue \(NextPageIndicatorCell.self).")
                    }
                    cell = nextPageIndicatorCell
                }

                return cell ?? UITableViewCell()
            })

        repositoriesTable.rx.modelSelected(GitHubRepositoryItemType.self)
            .filterMap({ (repositoryItem: GitHubRepositoryItemType) -> FilterMap<GitHubRepository> in
                guard case let GitHubRepositoryItemType.repository(repository) = repositoryItem else {
                    return .ignore
                }
                return .map(repository)
            })
            .bind(to: viewModel.repositorySelected)
            .disposed(by: disposeBag)

        viewModel.repositories
            .map({[$0]})
            .bind(to: repositoriesTable.rx.items(dataSource: repositoriesDataSource))
            .disposed(by: disposeBag)

        viewModel.repositories
            .map({$0.items.isEmpty})
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] (empty: Bool) in
                self?.setEmptyState(empty, withMessage: L10n.Repositories.emptyMessage)
            }).disposed(by: disposeBag)

        viewModel.showLoading
            .map({!$0})
            .asDriver(onErrorJustReturn: false)
            .do(onNext: { [weak self] hideLoading in
                if hideLoading {
                    self?.loadingIndicator.stopAnimating()
                    self?.emptyStateLabel.isHidden = false
                } else {
                    self?.loadingIndicator.startAnimating()
                    self?.emptyStateLabel.isHidden = true
                }
            })
            .drive(loadingIndicator.rx.isHidden).disposed(by: disposeBag)
    }

    private func setEmptyState(_ empty: Bool, withMessage message: String) {
        emptyStateView.isHidden = !empty
        emptyStateLabel.text = empty ? message : ""
    }
}