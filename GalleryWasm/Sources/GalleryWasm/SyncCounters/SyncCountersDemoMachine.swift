import Actomaton
import SyncCounters
import Reactivity

@Reactive
final class SyncCountersState
{
    var syncCounters: SyncCounters.State = .init()
}

typealias SyncCountersDemoMachine = MealyDriver<SyncCounters.Action, SyncCountersState, Never>

func makeSyncCountersDemoMachine(state: SyncCountersState = SyncCountersState()) -> SyncCountersDemoMachine
{
    SyncCountersDemoMachine(
        state: state,
        reducer: SyncCounters.reducer
            .contramap(state: \SyncCountersState.syncCounters),
        environment: ()
    )
}
