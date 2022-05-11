import SwiftUI
import ActomatonStore

@MainActor
public struct StateDiagramAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: .loggedOut,
            reducer: reducer,
            environment: ()
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        StateDiagramView(store: self.store.proxy)
    }
}
