//
//  ErrorConvertSpec.swift
//  GithubBrowser
//
//  Copyright (c) 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import Nimble
import Quick
import RxSwift
import Swinject
import Moya
import Alamofire

// swiftlint:disable file_length
class ErrorConvertSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("Error Converting") {

            it("converts a MoyaError with NSURLErrorNotConnectedToInternet underlying error to a DISCONNECTED error") {
                // given
                let moyaError = MoyaError.underlying(
                    NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil), nil)
                // when
                let convertedError = apiError(fromError: moyaError)
                // then
                expect(convertedError).to(equal(GitHubBrowserError.disconnected))
            }

            it("converts a MoyaError with an AFError with NSURLErrorNotConnectedToInternet underlying error to a DISCONNECTED error") {
                // given
                let alamoError = AFError.sessionTaskFailed(error:
                    NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil))
                let moyaError = MoyaError.underlying(alamoError, nil)
                // when
                let convertedError = apiError(fromError: moyaError)
                // then
                expect(convertedError).to(equal(GitHubBrowserError.disconnected))
            }

            it("converts a MoyaError with an underlying error NOT NSURLErrorNotConnectedToInternet to an UNEXPECTED error") {
                // given
                let alamoError = AFError.sessionTaskFailed(error:
                    NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil))
                let moyaError = MoyaError.underlying(alamoError, nil)
                // when
                let convertedError = apiError(fromError: moyaError)
                // then
                expect(convertedError).to(equal(GitHubBrowserError.unexpectedError))
            }

            it("converts an NSError NOT NSURLErrorNotConnectedToInternet to an UNEXPECTED error") {
                // given
                let platformError = NSError(domain: NSURLErrorDomain, code: NSFormattingError, userInfo: nil)
                // when
                let convertedError = apiError(fromError: platformError)
                // then
                expect(convertedError).to(equal(GitHubBrowserError.unexpectedError))
            }

            it("converts an Error to an UNEXPECTED error") {
                // given
                let error = DummyError.dummy
                // when
                let convertedError = apiError(fromError: error)
                // then
                expect(convertedError).to(equal(GitHubBrowserError.unexpectedError))
            }
        }
    }
}

enum DummyError: Error {
    case dummy
}
