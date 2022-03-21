import SwiftUI
import ActomatonStore
import StateDiagram

struct StateDiagramExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.3.trianglepath") }

    var exampleInitialState: Home.State.Current
    {
        .stateDiagram(.loggedOut)
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.stateDiagram,
            statePath: /Home.State.Current.stateDiagram,
            makeView: StateDiagramView.init
        )
    }
}
