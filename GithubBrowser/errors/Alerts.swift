//
//  Alerts.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import Alamofire

struct AlertAction {

    enum Style {
        case retry, `default`, cancel, destructive

        func asUIAlertActionStyle() -> UIAlertAction.Style {
            switch self {
            case .retry, .default:
                return .default
            case .cancel:
                return .cancel
            case .destructive:
                return .destructive
            }
        }
    }

    var title: String? {
        return wrappedAction.title
    }
    var style: AlertAction.Style
    var handler: ((UIAlertAction) -> Void)?
    var nativeAction: UIAlertAction {
        return wrappedAction
    }
    private var wrappedAction: UIAlertAction

    init(title: String?, style: AlertAction.Style, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.handler = handler
        self.style = style
        self.wrappedAction = UIAlertAction(title: title, style: style.asUIAlertActionStyle(), handler: handler)
    }

    static let okAction = AlertAction(title: L10n.Alert.Action.ok, style: .default)
}

struct AlertDetails: Equatable {
    static func == (lhs: AlertDetails, rhs: AlertDetails) -> Bool {
        guard lhs.actions.count == rhs.actions.count else { return false}

        var actionsAreEqual = true
        for i in 0...lhs.actions.count - 1 {
            let action1 = lhs.actions[i]
            let action2 = rhs.actions[i]
            actionsAreEqual = actionsAreEqual && action1.title == action2.title && action1.style == action2.style
        }

        return
            lhs.title == rhs.title &&
            lhs.message == rhs.message &&
            actionsAreEqual
    }

    var title: String
    var message: String
    var error: Error?
    var actions: [AlertAction]
}

func alertDetails(from error: Error) -> AlertDetails? {

    let error: GitHubBrowserError = apiError(fromError: error)
    switch error {
    case .serviceNotAvailable:
        return serviceUnavailableErrorDetails()
    case .disconnected:
        return disconnectedErrorDetails()
    default:
        return unexpectedErrorDetails(error: error)
    }
}

func apiError(fromError error: Error) -> GitHubBrowserError {
    if let eKretaError = error as? GitHubBrowserError {
        return eKretaError
    }
    var result: GitHubBrowserError
    switch error {
    case let moyaError as MoyaError:
        result = apiError(fromMoyaError: moyaError)
    case let alamoError as AFError:
        result = apiError(fromAlamofireError: alamoError)
    case let nsError as NSError:
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet {
            result = .disconnected
        } else if nsError.code == NSURLErrorTimedOut {
            result = .timeout
        } else {
            result = .unexpectedError
        }
    default:
        result = .unexpectedError
    }
    return result
}

private func apiError(fromMoyaError moyaError: MoyaError) -> GitHubBrowserError {
    var result: GitHubBrowserError
    switch moyaError {
    case .underlying(let error, let response):
        if response?.statusCode == 503 {
            return .serviceNotAvailable
        }
        result = apiError(fromError: error)
    default:
        result = .unexpectedError
    }
    return result
}

private func apiError(fromAlamofireError alamoError: AFError) -> GitHubBrowserError {
    var result: GitHubBrowserError
    switch alamoError {
    case .sessionTaskFailed(let error):
        result = apiError(fromError: error)
    default:
        result = .unexpectedError
    }
    return result
}

func disconnectedErrorDetails() -> AlertDetails {
    return AlertDetails(
        title: L10n.Alert.Title.error,
        message: L10n.Error.Disconnected.message,
        error: GitHubBrowserError.disconnected,
        actions: [AlertAction(title: L10n.Alert.Action.ok, style: .cancel, handler: { _ in })])
}

func serviceUnavailableErrorDetails() -> AlertDetails {
    return AlertDetails(
        title: L10n.Alert.Title.error,
        message: L10n.Error.ServiceUnavailable.message,
        error: GitHubBrowserError.serviceNotAvailable,
        actions: [AlertAction(title: L10n.Alert.Action.ok, style: .cancel, handler: { _ in })])
}

func unexpectedErrorDetails(error: Error) -> AlertDetails {
    return AlertDetails(
        title: L10n.Alert.Title.error,
        message: L10n.Error.Unexpected.message,
        error: error,
        actions: [AlertAction(title: L10n.Alert.Action.ok, style: .cancel, handler: { _ in })])
}
