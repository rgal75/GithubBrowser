//
//  StubObservable.swift
//  GithubBrowserTests
//
//  Copyright © 2021. VividMind. All rights reserved.
//
@testable import GithubBrowser
import Foundation
import RxSwift

class StubObservable<T> {
    private var stubObservable: Observable<T>!
    private var stubbingSubject = ReplaySubject<T>.create(bufferSize: 1)

    init() {
        stubObservable = stubbingSubject.asObservable()
    }

    var observable: Observable<T> {
        return stubObservable
    }
    
    func emit(_ value: T) {
        stubbingSubject.onNext(value)
    }
}
