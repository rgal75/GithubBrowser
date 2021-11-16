//
//  StubObservable.swift
//  GithubBrowserTests
//
//  Copyright © 2021. VividMind. All rights reserved.
//
@testable import GithubBrowser
import Foundation
import RxSwift
import RxRelay
import Quick
import Nimble

protocol TriggerCountVerifier {
    associatedtype E
    func verifyTriggered(
        times triggerCount: Int,
        file: FileString,
        line: UInt)
}

protocol ElementVerifier {
    associatedtype E
    func verifyTriggered(
        times triggerCount: Int,
        with expectedValue: E?,
        file: FileString,
        line: UInt)
}

class ObservableSpy<O: ObservableType> {
    private(set) var observable: O
    private var triggerCount = 0
    private var lastTriggerValue: O.Element?
    private var disposeBag = DisposeBag()

    init(with observable: O) {
        self.observable = observable
        self.observable.subscribe(onNext: { [weak self] (value: O.Element) in
            self?.triggerCount += 1
            self?.lastTriggerValue = value
        }).disposed(by: disposeBag)
    }

    func reset() {
        triggerCount = 0
        lastTriggerValue = nil
    }
}

extension ObservableSpy: ElementVerifier where O.Element: Equatable {
    typealias E = O.Element

    func verifyTriggered(
        times triggerCount: Int = 1,
        with expectedValue: E? = nil,
        file: FileString = #file,
        line: UInt = #line) {
        expect(file: file, line: line, self.triggerCount).to(equal(triggerCount))
        if triggerCount > 0 {
            expect(file: file, line: line, self.lastTriggerValue).to(equal(expectedValue))
        }
    }
}

extension ObservableSpy: TriggerCountVerifier {
    typealias E = O.Element

    func verifyTriggered(
        times triggerCount: Int = 1,
        file: FileString = #file,
        line: UInt = #line) {
        expect(file: file, line: line, self.triggerCount).to(equal(triggerCount))
    }
}
