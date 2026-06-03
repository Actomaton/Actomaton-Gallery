import Foundation
import Actomaton
import CommonEffects
import Physics
import Reactivity

@Reactive
final class PhysicsState
{
    var physics: PhysicsRoot.State = .init(current: PhysicsExampleID.gravityUniverse.initialState)
}

typealias PhysicsDemoMachine = MealyDriver<PhysicsRoot.Action, PhysicsState, Never>

func makePhysicsDemoMachine(state: PhysicsState = PhysicsState()) -> PhysicsDemoMachine
{
    PhysicsDemoMachine(
        state: state,
        reducer: PhysicsRoot.reducer
            .contramap(state: \PhysicsState.physics),
        environment: PhysicsRoot.Environment(timer: CommonEffects.timer)
    )
}
