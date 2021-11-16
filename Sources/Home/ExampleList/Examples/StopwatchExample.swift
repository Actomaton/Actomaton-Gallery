import SwiftUI
import ActomatonStore
import Stopwatch

struct StopwatchExample: Example
{
    var exampleIcon: Image { Image(systemName: "stopwatch") }

    var exampleInitialState: Home.State.Current
    {
        .stopwatch(Stopwatch.State())
    }

    func exampleView(store: Store<Home.Action, Home.State>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.stopwatch,
            statePath: /Home.State.Current.stopwatch,
            makeView: StopwatchView.init
        )
    }
}
