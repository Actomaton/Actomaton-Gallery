import SwiftUI
import ActomatonUI
import Physics

struct PhysicsExample: Example
{
    var exampleIcon: Image { Image(systemName: "atom") }

    var exampleInitialState: Home.State.Current
    {
        .physics(PhysicsRoot.State(current: nil))
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.physics,
            statePath: /Home.State.Current.physics,
            makeView: PhysicsRootView.init
        )
    }
}
