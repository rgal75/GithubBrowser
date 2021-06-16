//
//  TestHelper+UI.swift
//  GithubBrowserTests
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation
import UIKit

func presentAsInitialViewController(_ viewController: UIViewController) {
    let window = UIWindow()
    window.rootViewController = viewController
    window.makeKeyAndVisible()
}

func executeRunLoop(_ interval: TimeInterval = 0) {
    RunLoop.current.run(until: Date(timeInterval: interval, since: Date()))
}
