import SwiftUI
import ActomatonStore

@MainActor
public struct SettingsAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(user: .makeSample()),
            reducer: reducer,
            environment: ()
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        SettingsView(store: self.store.proxy, usesNavigationView: true)
    }
}
