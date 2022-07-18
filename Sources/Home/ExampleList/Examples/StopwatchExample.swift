import SwiftUI
import ActomatonUI
import Stopwatch

struct StopwatchExample: Example
{
    var exampleIcon: Image { Image(systemName: "stopwatch") }

    var exampleInitialState: Home.State.Current
    {
        .stopwatch(Stopwatch.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.stopwatch,
            statePath: /Home.State.Current.stopwatch,
            makeView: StopwatchView.init
        )
    }
}
