//
//  TestingAppDelegate.swift
//  GithubBrowserTests
//
//  
//
import Foundation
import UIKit
import GithubBrowser
import CocoaLumberjack

class TestingAppDelegate: NSObject {
    @objc var window: UIWindow?
    override init() {
        super.init()
        setupLogging()
        DDLogDebug("Testing started.")
    }

    private func setupLogging() {
        #if DEBUG
        dynamicLogLevel = .debug
        #else
        dynamicLogLevel = .error
        #endif

        if let ttyLogger = DDTTYLogger.sharedInstance {
            ttyLogger.logFormatter = LogFormatter()
            DDLog.add(ttyLogger) // TTY = Xcode console
        }
    }
}
