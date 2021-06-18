//
//  AppDelegate.swift
//  GithubBrowser
//
//  
//

import UIKit
import CocoaLumberjack
import RxFlow
import RxSwift
import SwinjectStoryboard
import InjectPropertyWrapper

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let assembler = MainAssembler.create(withAssembly: MainAssembly())
    private var coordinator = FlowCoordinator()
    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        InjectSettings.resolver = assembler.container
        setupLogging()
        showRootViewController()
        DDLogDebug("Application started")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func showRootViewController() {
        coordinator.rx.willNavigate.subscribe(onNext: { (flow, step) in
            DDLogDebug("Will navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: disposeBag)

        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            DDLogDebug("Did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: disposeBag)

        guard let initialFlow = assembler.resolver.resolve(RootFlow.self) else {
            preconditionFailure("Failed to resolve \(RootFlow.self).")
        }

        Flows.use(initialFlow, when: .ready) { [weak self] root in
            guard let self = self else { return }
            self.window = UIWindow()
            self.window?.rootViewController = root
            self.window?.makeKeyAndVisible()
        }

        coordinator.coordinate(
            flow: initialFlow,
            with: OneStepper(withSingleStep: AppStep.repositoriesViewRequested))
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
        let osLogger = DDOSLogger.sharedInstance
        osLogger.logFormatter = LogFormatter()
        DDLog.add(osLogger)
    }
}
