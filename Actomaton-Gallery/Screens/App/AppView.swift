import SwiftUI
import Actomaton
import ActomatonStore

/// Topmost container view of the app which holds `Store` as a single source of truth.
/// For the child views, pass `Store.Proxy` instead, so that we don't duplicate multiple `Store`s
/// but `Binding` and `Store.proxy.send` (sending message to `Store`) functionalities are still available.
struct AppView: View
{
    @StateObject
    private var store: Store<DebugRoot.Action, DebugRoot.State> = .init(
        state: DebugRoot.State(inner: .init(), usesTimeTravel: true),
        reducer: DebugRoot.reducer(),
        environment: DebugRoot.Environment(urlSession: .shared, getDate: { Date() })
    )

    init() {}

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        DebugRootView(store: self.store.proxy)
    }
}
