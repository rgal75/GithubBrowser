//
//  RootFlow.swift
//  GithubBrowser
//
//  
//
import Foundation
import CocoaLumberjack
import RxFlow
import SafariServices

protocol RootFlowProtocol: Flow, AlertPresenterProtocol {}

class RootFlow: RootFlowProtocol {
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .repositoriesViewRequested:
            return showRepositoriesView()
        case .safariViewRequested(let url):
            return showSafariView(url: url)
        case .alert(let alertDetails):
            present(alertDetails: alertDetails, withStyle: .alert, on: rootViewController)
            return .none
        }
    }

    private func showRepositoriesView() -> FlowContributors {
        let initialViewController = StoryboardScene.RepositoriesViewController.repositoriesViewController.instantiate()
        rootViewController.setViewControllers([initialViewController], animated: false)

        return .one(flowContributor: .contribute(
                        withNextPresentable: initialViewController,
                        withNextStepper: initialViewController.stepper))
    }

    private func showSafariView(url: URL) -> FlowContributors {
        let safariVC = SFSafariViewController(url: url)
        rootViewController.present(safariVC, animated: true)

        return .none
    }
}
