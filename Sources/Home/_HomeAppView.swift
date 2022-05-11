import SwiftUI
import ActomatonStore

@MainActor
public struct HomeAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(current: nil, usesTimeTravel: false, isDebuggingTab: false),
            reducer: reducer,
            environment: .live(commonEffects: .live)
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        HomeView(store: self.store.proxy)
    }
}
