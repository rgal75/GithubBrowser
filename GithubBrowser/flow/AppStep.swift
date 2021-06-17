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
    // Global
    case initialViewRequested

    case alert(AlertDetails)
}
