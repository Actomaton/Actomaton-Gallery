import SwiftUI
import ActomatonStore
import SyncCounters

struct SyncCountersExample: Example
{
    var exampleIcon: Image { Image(systemName: "goforward.plus") }

    var exampleInitialState: Root.State.Current
    {
        .syncCounters(SyncCounters.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            actionPath: /Root.Action.syncCounters,
            statePath: /Root.State.Current.syncCounters,
            makeView: SyncCountersView.init
        )
    }
}
