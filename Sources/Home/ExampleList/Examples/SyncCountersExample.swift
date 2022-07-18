import SwiftUI
import ActomatonUI
import SyncCounters

struct SyncCountersExample: Example
{
    var exampleIcon: Image { Image(systemName: "goforward.plus") }

    var exampleInitialState: Home.State.Current
    {
        .syncCounters(SyncCounters.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.syncCounters,
            statePath: /Home.State.Current.syncCounters,
            makeView: SyncCountersView.init
        )
    }
}
