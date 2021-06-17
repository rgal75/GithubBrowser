//
//  RootFlowSpec.swift
//  GithubBrowserTests
//
//  Copyright © 2021. VividMind. All rights reserved.
//

@testable import GithubBrowser
import Nimble
import Quick
import RxSwift
import Swinject
import RxFlow
import InjectPropertyWrapper
import ViewControllerPresentationSpy
import SafariServices

// swiftlint:disable file_length
class RootFlowSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("RootFlow") {
            var sut: RootFlow!
            var disposeBag: DisposeBag!
            var assembler: MainAssembler!

            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container
                sut = assembler.resolver.resolve(RootFlowProtocol.self) as? RootFlow
                disposeBag = DisposeBag()
            }

            afterEach {
                disposeBag = nil
                assembler.dispose()
            }

            context("root") {
                it("is a UINavigationController") {
                    expect(sut.root).to(beAnInstanceOf(UINavigationController.self))
                }
            }

            context("navigation") {
                var testCoordinator: FlowCoordinator!
                var testStepper: TestStepper!

                beforeEach {
                    testStepper = TestStepper()
                    testCoordinator = FlowCoordinator()
                    testCoordinator.coordinate(flow: sut, with: testStepper)
                }

                afterEach {
                    testCoordinator = nil
                }

                context("when presenting the initial view is requested") {
                    beforeEach {
                        testStepper.triggerStep(AppStep.initialViewRequested)
                    }

                    it("shows the \(RepositoriesViewController.self)") {
                        // then
                        expect(sut.rootVC.topViewController).to(beAnInstanceOf(RepositoriesViewController.self))
                    }
                }

                context("when presenting the Safari view is requested") {
                    var presentationVerifier: PresentationVerifier!
                    beforeEach {
                        presentationVerifier = PresentationVerifier()
                        testStepper.triggerStep(AppStep.safariViewRequested(url: URL(string: "https://google.com")!))
                    }

                    afterEach {
                        presentationVerifier = nil
                    }

                    it("shows the \(SFSafariViewController.self)") {
                        // then
                        let presentedVC: SFSafariViewController? = presentationVerifier.verify(
                            animated: true,
                            presentingViewController: sut.rootVC)
                        expect(presentedVC).to(beAnInstanceOf(SFSafariViewController.self))
                    }
                }

                context("when opening an alert is requested") {
                    it("shows the alert") {
                        let alertVerifier = AlertVerifier()
                        let expectedAlert = AlertDetails(
                            title: "alert_title",
                            message: "alert_message",
                            actions: [AlertAction(title: "OK", style: .cancel)])
                        // then
                        testStepper.triggerStep(AppStep.alert(expectedAlert))
                        // then
                        alertVerifier.verify(
                            title: expectedAlert.title,
                            message: expectedAlert.message,
                            animated: true,
                            actions: [
                                .cancel("OK")
                            ],
                            presentingViewController: sut.rootVC
                        )
                    }
                }
            }
        }
    }
}

extension RootFlowSpec {

    class TestAssembly: Assembly {
        func assemble(container: Container) {
            container.register(RootFlowProtocol.self) { _ in
                return RootFlow()
            }.inObjectScope(.transient)

            container.register(RepositoriesViewModelProtocol.self) { _ in
                return MockRepositoriesViewModel()
            }.inObjectScope(.transient)
        }
    }
}

extension RootFlow {
    var rootVC: UINavigationController {
        guard let rootVC = root as? UINavigationController else {
            preconditionFailure("\(RootFlowProtocol.self) root must be a \(UINavigationController.self)")
        }
        return rootVC
    }
}
