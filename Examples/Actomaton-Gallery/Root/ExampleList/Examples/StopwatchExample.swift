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
        exampleView(
            store: store,
            actionPath: /Root.Action.stopwatch,
            statePath: \.stopwatch,
            makeView: StopwatchView.init
        )
    }
}
