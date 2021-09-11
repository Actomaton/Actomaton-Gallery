import SwiftUI
import ActomatonStore
import StateDiagram

struct StateDiagramExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.3.trianglepath") }

    var exampleInitialState: Root.State.Current
    {
        .stateDiagram(.loggedOut)
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        exampleView(
            store: store,
            actionPath: /Root.Action.stateDiagram,
            statePath: \.stateDiagram,
            makeView: StateDiagramView.init
        )
    }
}
