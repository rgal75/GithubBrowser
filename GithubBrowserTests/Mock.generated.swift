// Generated using Sourcery 1.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// Generated with SwiftyMocky 4.1.0
// Required Sourcery: 1.6.0


import SwiftyMocky
import XCTest
import CocoaLumberjack
import Foundation
import InjectPropertyWrapper
import Moya
import RxFlow
import RxRelay
import RxSwift
import RxSwiftExt
@testable import GithubBrowser


// MARK: - GitHubServiceProtocol

open class GitHubServiceProtocolMock: GitHubServiceProtocol, Mock {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func findRepositories(withSearchTerm searchTerm: String, nextPageUrl: URL?, pageSize: Int) -> Single<GitHubSearchResult> {
        addInvocation(.m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(Parameter<String>.value(`searchTerm`), Parameter<URL?>.value(`nextPageUrl`), Parameter<Int>.value(`pageSize`)))
		let perform = methodPerformValue(.m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(Parameter<String>.value(`searchTerm`), Parameter<URL?>.value(`nextPageUrl`), Parameter<Int>.value(`pageSize`))) as? (String, URL?, Int) -> Void
		perform?(`searchTerm`, `nextPageUrl`, `pageSize`)
		var __value: Single<GitHubSearchResult>
		do {
		    __value = try methodReturnValue(.m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(Parameter<String>.value(`searchTerm`), Parameter<URL?>.value(`nextPageUrl`), Parameter<Int>.value(`pageSize`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for findRepositories(withSearchTerm searchTerm: String, nextPageUrl: URL?, pageSize: Int). Use given")
			Failure("Stub return value not specified for findRepositories(withSearchTerm searchTerm: String, nextPageUrl: URL?, pageSize: Int). Use given")
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(Parameter<String>, Parameter<URL?>, Parameter<Int>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(let lhsSearchterm, let lhsNextpageurl, let lhsPagesize), .m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(let rhsSearchterm, let rhsNextpageurl, let rhsPagesize)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsSearchterm, rhs: rhsSearchterm, with: matcher), lhsSearchterm, rhsSearchterm, "withSearchTerm searchTerm"))
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsNextpageurl, rhs: rhsNextpageurl, with: matcher), lhsNextpageurl, rhsNextpageurl, "nextPageUrl"))
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsPagesize, rhs: rhsPagesize, with: matcher), lhsPagesize, rhsPagesize, "pageSize"))
				return Matcher.ComparisonResult(results)
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize: return ".findRepositories(withSearchTerm:nextPageUrl:pageSize:)"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func findRepositories(withSearchTerm searchTerm: Parameter<String>, nextPageUrl: Parameter<URL?>, pageSize: Parameter<Int>, willReturn: Single<GitHubSearchResult>...) -> MethodStub {
            return Given(method: .m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(`searchTerm`, `nextPageUrl`, `pageSize`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func findRepositories(withSearchTerm searchTerm: Parameter<String>, nextPageUrl: Parameter<URL?>, pageSize: Parameter<Int>, willProduce: (Stubber<Single<GitHubSearchResult>>) -> Void) -> MethodStub {
            let willReturn: [Single<GitHubSearchResult>] = []
			let given: Given = { return Given(method: .m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(`searchTerm`, `nextPageUrl`, `pageSize`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Single<GitHubSearchResult>).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func findRepositories(withSearchTerm searchTerm: Parameter<String>, nextPageUrl: Parameter<URL?>, pageSize: Parameter<Int>) -> Verify { return Verify(method: .m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(`searchTerm`, `nextPageUrl`, `pageSize`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func findRepositories(withSearchTerm searchTerm: Parameter<String>, nextPageUrl: Parameter<URL?>, pageSize: Parameter<Int>, perform: @escaping (String, URL?, Int) -> Void) -> Perform {
            return Perform(method: .m_findRepositories__withSearchTerm_searchTermnextPageUrl_nextPageUrlpageSize_pageSize(`searchTerm`, `nextPageUrl`, `pageSize`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

// MARK: - RepositoriesViewModelProtocol

open class RepositoriesViewModelProtocolMock: RepositoriesViewModelProtocol, Mock {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }

    public var searchTerm: PublishRelay<String> {
		get {	invocations.append(.p_searchTerm_get); return __p_searchTerm ?? givenGetterValue(.p_searchTerm_get, "RepositoriesViewModelProtocolMock - stub value for searchTerm was not defined") }
	}
	private var __p_searchTerm: (PublishRelay<String>)?

    public var loadNextPage: PublishRelay<Void> {
		get {	invocations.append(.p_loadNextPage_get); return __p_loadNextPage ?? givenGetterValue(.p_loadNextPage_get, "RepositoriesViewModelProtocolMock - stub value for loadNextPage was not defined") }
	}
	private var __p_loadNextPage: (PublishRelay<Void>)?

    public var repositorySelected: PublishRelay<GitHubRepository> {
		get {	invocations.append(.p_repositorySelected_get); return __p_repositorySelected ?? givenGetterValue(.p_repositorySelected_get, "RepositoriesViewModelProtocolMock - stub value for repositorySelected was not defined") }
	}
	private var __p_repositorySelected: (PublishRelay<GitHubRepository>)?

    public var repositories: Observable<GitHubRepositoriesSection> {
		get {	invocations.append(.p_repositories_get); return __p_repositories ?? givenGetterValue(.p_repositories_get, "RepositoriesViewModelProtocolMock - stub value for repositories was not defined") }
	}
	private var __p_repositories: (Observable<GitHubRepositoriesSection>)?

    public var showLoading: Observable<Bool> {
		get {	invocations.append(.p_showLoading_get); return __p_showLoading ?? givenGetterValue(.p_showLoading_get, "RepositoriesViewModelProtocolMock - stub value for showLoading was not defined") }
	}
	private var __p_showLoading: (Observable<Bool>)?

    public var steps: PublishRelay<Step> {
		get {	invocations.append(.p_steps_get); return __p_steps ?? givenGetterValue(.p_steps_get, "RepositoriesViewModelProtocolMock - stub value for steps was not defined") }
	}
	private var __p_steps: (PublishRelay<Step>)?

    public var initialStep: Step {
		get {	invocations.append(.p_initialStep_get); return __p_initialStep ?? givenGetterValue(.p_initialStep_get, "RepositoriesViewModelProtocolMock - stub value for initialStep was not defined") }
	}
	private var __p_initialStep: (Step)?





    open func readyToEmitSteps() {
        addInvocation(.m_readyToEmitSteps)
		let perform = methodPerformValue(.m_readyToEmitSteps) as? () -> Void
		perform?()
    }


    fileprivate enum MethodType {
        case m_readyToEmitSteps
        case p_searchTerm_get
        case p_loadNextPage_get
        case p_repositorySelected_get
        case p_repositories_get
        case p_showLoading_get
        case p_steps_get
        case p_initialStep_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_readyToEmitSteps, .m_readyToEmitSteps): return .match
            case (.p_searchTerm_get,.p_searchTerm_get): return Matcher.ComparisonResult.match
            case (.p_loadNextPage_get,.p_loadNextPage_get): return Matcher.ComparisonResult.match
            case (.p_repositorySelected_get,.p_repositorySelected_get): return Matcher.ComparisonResult.match
            case (.p_repositories_get,.p_repositories_get): return Matcher.ComparisonResult.match
            case (.p_showLoading_get,.p_showLoading_get): return Matcher.ComparisonResult.match
            case (.p_steps_get,.p_steps_get): return Matcher.ComparisonResult.match
            case (.p_initialStep_get,.p_initialStep_get): return Matcher.ComparisonResult.match
            default: return .none
            }
        }

        func intValue() -> Int {
            switch self {
            case .m_readyToEmitSteps: return 0
            case .p_searchTerm_get: return 0
            case .p_loadNextPage_get: return 0
            case .p_repositorySelected_get: return 0
            case .p_repositories_get: return 0
            case .p_showLoading_get: return 0
            case .p_steps_get: return 0
            case .p_initialStep_get: return 0
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_readyToEmitSteps: return ".readyToEmitSteps()"
            case .p_searchTerm_get: return "[get] .searchTerm"
            case .p_loadNextPage_get: return "[get] .loadNextPage"
            case .p_repositorySelected_get: return "[get] .repositorySelected"
            case .p_repositories_get: return "[get] .repositories"
            case .p_showLoading_get: return "[get] .showLoading"
            case .p_steps_get: return "[get] .steps"
            case .p_initialStep_get: return "[get] .initialStep"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func searchTerm(getter defaultValue: PublishRelay<String>...) -> PropertyStub {
            return Given(method: .p_searchTerm_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func loadNextPage(getter defaultValue: PublishRelay<Void>...) -> PropertyStub {
            return Given(method: .p_loadNextPage_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func repositorySelected(getter defaultValue: PublishRelay<GitHubRepository>...) -> PropertyStub {
            return Given(method: .p_repositorySelected_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func repositories(getter defaultValue: Observable<GitHubRepositoriesSection>...) -> PropertyStub {
            return Given(method: .p_repositories_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func showLoading(getter defaultValue: Observable<Bool>...) -> PropertyStub {
            return Given(method: .p_showLoading_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func steps(getter defaultValue: PublishRelay<Step>...) -> PropertyStub {
            return Given(method: .p_steps_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func initialStep(getter defaultValue: Step...) -> PropertyStub {
            return Given(method: .p_initialStep_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func readyToEmitSteps() -> Verify { return Verify(method: .m_readyToEmitSteps)}
        public static var searchTerm: Verify { return Verify(method: .p_searchTerm_get) }
        public static var loadNextPage: Verify { return Verify(method: .p_loadNextPage_get) }
        public static var repositorySelected: Verify { return Verify(method: .p_repositorySelected_get) }
        public static var repositories: Verify { return Verify(method: .p_repositories_get) }
        public static var showLoading: Verify { return Verify(method: .p_showLoading_get) }
        public static var steps: Verify { return Verify(method: .p_steps_get) }
        public static var initialStep: Verify { return Verify(method: .p_initialStep_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func readyToEmitSteps(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_readyToEmitSteps, performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

