//
//  RootFlow.swift
//  GithubBrowser
//
//  
//
import Foundation
import CocoaLumberjack
import RxFlow

protocol RootFlowProtocol: Flow {
}
class RootFlow: RootFlowProtocol {
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .initialViewRequested:
            return showInitialView()
        default:
            return .none
        }
    }

    private func showInitialView() -> FlowContributors {
        let initialViewController = StoryboardScene.RepositoriesViewController.repositoriesViewController.instantiate()
        rootViewController.setViewControllers([initialViewController], animated: false)

        return .one(flowContributor: .contribute(
            withNextPresentable: initialViewController,
                        withNextStepper: OneStepper(withSingleStep: AppStep.initialViewRequested)))
    }
}
