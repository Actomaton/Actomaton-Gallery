import SwiftUI
import ActomatonStore

@MainActor
struct CounterAppView: View
{
    @StateObject
    private var store: Store<Action, State>

    init()
    {
        let store = Store<Action, State>(
            state: State(),
            reducer: reducer()
        )
        self._store = StateObject(wrappedValue: store)
    }

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        CounterView(store: self.store.proxy)
    }
}
