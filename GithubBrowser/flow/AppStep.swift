//
//  AppStep.swift
//  GithubBrowser
//
//  
//
import RxFlow
import RxSwift
import RxRelay

enum AppStep: Step, Equatable {
    case initialViewRequested
    case safariViewRequested(url: URL)

    case alert(AlertDetails)
}
