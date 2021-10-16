import SwiftUI
import ActomatonStore
import Stopwatch

struct StopwatchExample: Example
{
    var exampleIcon: Image { Image(systemName: "stopwatch") }

    var exampleInitialState: Root.State.Current
    {
        .stopwatch(Stopwatch.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Root.Action.stopwatch,
            statePath: /Root.State.Current.stopwatch,
            makeView: StopwatchView.init
        )
    }
}
