//
//  AppStep.swift
//  GithubBrowser
//
//  
//
import RxFlow

enum AppStep: Step, Equatable {
    case repositoriesViewRequested
    case safariViewRequested(url: URL)
    case alert(AlertDetails)
}
