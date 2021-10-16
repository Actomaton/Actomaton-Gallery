import SwiftUI
import ActomatonStore
import Physics

struct PhysicsExample: Example
{
    var exampleIcon: Image { Image(systemName: "atom") }

    var exampleInitialState: Root.State.Current
    {
        .physics(PhysicsRoot.State(current: nil))
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Root.Action.physics,
            statePath: /Root.State.Current.physics,
            makeView: PhysicsRootView.init
        )
    }
}
