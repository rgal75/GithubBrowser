//
//  RootFlow.swift
//  GithubBrowser
//
//  
//
import Foundation
import CocoaLumberjack
import RxFlow

class RootFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UITabBarController()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .initialViewRequested:
            return .none
        default:
            return .none
        }
    }

}
