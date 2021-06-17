//
//  TestStepper.swift
//  GithubBrowserTests
//
//  Copyright © 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import Foundation
import RxFlow
import RxCocoa

class TestStepper: Stepper {
    internal var steps = PublishRelay<Step>()

    var initialStep: Step = RxFlowStep.home

    func triggerStep(_ step: Step) {
        steps.accept(step)
        executeRunLoop()
    }
}
