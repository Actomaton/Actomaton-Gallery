import SwiftUI
import ActomatonStore

@MainActor
public struct RootAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: .initialState,
            reducer: reducer(),
            environment: .live(commonEffects: .live)
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        RootView(store: self.store.proxy)
    }
}
