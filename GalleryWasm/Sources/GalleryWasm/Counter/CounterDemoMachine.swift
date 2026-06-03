import Actomaton
import Counter
import Reactivity

@Reactive
final class CounterState
{
    var counter: Counter.State = .init()
}

typealias CounterDemoMachine = MealyDriver<Counter.Action, CounterState, Never>

func makeCounterDemoMachine(state: CounterState = CounterState()) -> CounterDemoMachine
{
    CounterDemoMachine(
        state: state,
        reducer: Counter.reducer
            .contramap(state: \CounterState.counter),
        environment: ()
    )
}
