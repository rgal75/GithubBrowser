//
//  AlertPresenter.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import UIKit

protocol AlertPresenterProtocol {
    func present(
        alertDetails: AlertDetails,
        withStyle style: UIAlertController.Style,
        on viewController: UIViewController)
}

extension AlertPresenterProtocol {
    func present(
        alertDetails: AlertDetails,
        withStyle style: UIAlertController.Style,
        on viewController: UIViewController) {
        let alert = UIAlertController(
            title: alertDetails.title,
            message: alertDetails.message,
            preferredStyle: style)
        for action in alertDetails.actions {
            alert.addAction(action.nativeAction)
        }
        viewController.present(alert, animated: true)
    }
}
