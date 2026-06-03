import Foundation
import Actomaton
import CommonEffects
import Stopwatch
import Reactivity

@Reactive
final class StopwatchState
{
    var stopwatch: Stopwatch.State = .init()
}

typealias StopwatchDemoMachine = MealyDriver<Stopwatch.Action, StopwatchState, Never>

func makeStopwatchDemoMachine(state: StopwatchState = StopwatchState()) -> StopwatchDemoMachine
{
    StopwatchDemoMachine(
        state: state,
        reducer: Stopwatch.reducer
            .contramap(state: \StopwatchState.stopwatch),
        environment: Stopwatch.Environment(
            getDate: { Date() },
            timer: CommonEffects.timer
        )
    )
}
