//
//  main.swift
//  GithubBrowser
//
//  
//
import Foundation
import UIKit

let appDelegateClass: AnyClass? = NSClassFromString("GithubBrowserTests.TestingAppDelegate") ?? AppDelegate.self

_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appDelegateClass!))

