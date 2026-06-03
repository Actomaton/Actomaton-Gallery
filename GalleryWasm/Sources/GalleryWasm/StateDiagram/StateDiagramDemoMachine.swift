import Actomaton
import StateDiagram
import Reactivity

@Reactive
final class StateDiagramState
{
    var stateDiagram: StateDiagram.State = .loggedOut
}

typealias StateDiagramDemoMachine = MealyDriver<StateDiagram.Action, StateDiagramState, Never>

func makeStateDiagramDemoMachine(state: StateDiagramState = StateDiagramState()) -> StateDiagramDemoMachine
{
    StateDiagramDemoMachine(
        state: state,
        reducer: StateDiagram.reducer
            .contramap(state: \StateDiagramState.stateDiagram),
        environment: ()
    )
}
