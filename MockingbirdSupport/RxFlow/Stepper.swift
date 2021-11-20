/// a Stepper has only one purpose is: emits Steps that correspond to specific navigation states.
/// The Step changes lead to navigation actions in the context of a specific Flow
public protocol Stepper {
    /// the relay used to emit steps inside this Stepper
    var steps: PublishRelay<Step> { get }

    /// the initial step that will be emitted when listening to this Stepper
    var initialStep: Step { get }

    /// function called when stepper is listened by the FlowCoordinator
    func readyToEmitSteps ()
}
