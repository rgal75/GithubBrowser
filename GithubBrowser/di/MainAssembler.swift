//
//  MainAssembler.swift
//  GithubBrowser
//
//  
//
import Swinject
import SwinjectStoryboard
import Moya
import CocoaLumberjack
import RxSwift

class MainAssembler {
    public static var instance: MainAssembler! = nil

    var resolver: Resolver {
        return assembler.resolver
    }
    let container: Container
    private let assembler: Assembler

    // swiftlint:disable force_cast
    private init(withAssembly assembly: Assembly) {
        container = SwinjectStoryboard.defaultContainer
        assembler = Assembler(container: container)
        assembler.apply(assembly: assembly)
        DDLogDebug("DI: Assembler instance: \(ObjectIdentifier(assembler).debugDescription)")
    }

    /// Creates the single MainAssembler instance with the given assembly.
    /// IMPORTANT: this factory method SHOULD only be called once. Thereafter, use
    /// MainAssembler.instance to access the sibgleton instance that this method created.
    /// There SHOULD NOT be multiple ManAssembler and ManAssembly instances in the system!
    static func create(withAssembly assembly: Assembly) -> MainAssembler {
        instance = MainAssembler(withAssembly: assembly)
        return instance
    }

    deinit {
        DDLogDebug("deinit")
    }

    func dispose() {
        DDLogDebug("dispose")
        SwinjectStoryboard.defaultContainer.removeAll()
    }
}

// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
class MainAssembly: Assembly {

    func assemble(container: Container) {

        container.register(RootFlow.self) { _ in
            return RootFlow()
        }.inObjectScope(.transient)

        container.register(RepositoriesViewModelProtocol.self) { _ in
            return RepositoriesViewModel()
        }.inObjectScope(.transient)

        container.register(GitHubServiceProtocol.self) { _ in
            return GitHubService()
        }.inObjectScope(.container)

        container.register(RepositoriesViewModelProtocol.self) { _ in
            return RepositoriesViewModel()
        }.inObjectScope(.transient)

        container.register(MoyaProvider<GitHubApi>.self) { _ in
            return MoyaProvider<GitHubApi>(plugins: [
                NetworkLoggerPlugin(
                    configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
            ])
        }.inObjectScope(.container)

        container.register(SchedulerType.self) { _ in
            return MainScheduler.instance
        }.inObjectScope(.transient)
    }
}
