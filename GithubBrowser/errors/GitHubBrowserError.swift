//
//  GitHubBrowserError.swift
//  GithubBrowser
//
//  Copyright © 2021. VividMind. All rights reserved.
//

import Foundation

enum GitHubBrowserError: Error, Equatable {
    /// This error is used to trigger a retry with the RX retry operators
    case retryRequest
    /// There was no internet connection while trying to access an API endoint.
    case disconnected
    case serviceNotAvailable
    case validationFailed
    /// An error that we cannot really recover from.
    case unexpectedError
}
