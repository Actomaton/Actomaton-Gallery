import SwiftUI
import ActomatonStore

@MainActor
public struct CounterAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(),
            reducer: reducer,
            environment: ()
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        CounterView(store: self.store.proxy)
    }
}
