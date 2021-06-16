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
