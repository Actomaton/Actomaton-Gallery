import SwiftUI
import ActomatonUI
import Counter

struct CounterExample: Example
{
    var exampleIcon: Image { Image(systemName: "goforward.plus") }

    var exampleInitialState: Home.State.Current
    {
        .counter(Counter.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.counter,
            statePath: /Home.State.Current.counter,
            makeView: CounterView.init
        )
    }
}
