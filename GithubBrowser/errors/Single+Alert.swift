//
//  Single+Alert.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    func catchError(showAlert: @escaping (AlertDetails) -> Void) -> Single<Element> {

        return self.catch({ (error: Error) -> Single<Element> in
            if let alertDetails = alertDetails(from: error) {
                var mutableAlertDetails = alertDetails
                let dismissedSubject = PublishSubject<AlertAction>()
                let _actions = alertDetails.actions.map { (action: AlertAction) -> AlertAction in
                    return AlertAction(
                        title: action.title,
                        style: action.style,
                        handler: { (nativeAction: UIAlertAction) in
                            action.handler?(nativeAction)
                            dismissedSubject.onNext(action)
                            dismissedSubject.onCompleted()
                        })
                }
                mutableAlertDetails.actions = _actions
                showAlert(mutableAlertDetails)
                return dismissedSubject
                    .take(1)
                    .asSingle()
                    .map({ (action: AlertAction) -> Element in
                        if action.style == .retry {
                            throw GitHubBrowserError.retryRequest
                        } else {
                            throw error
                        }
                    })
            }
            return Single.error(error)
        })
    }
}
