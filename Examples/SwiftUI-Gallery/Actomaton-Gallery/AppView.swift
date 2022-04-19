import SwiftUI
import ActomatonStore
import Tab
import Home
import Root
import DebugRoot

/// Topmost container view of the app which holds `Store` as a single source of truth.
/// For the child views, pass `Store.Proxy` instead, so that we don't duplicate multiple `Store`s
/// but `Binding` and `Store.proxy.send` (sending message to `Store`) functionalities are still available.
@MainActor
struct AppView: View
{
    @StateObject
    private var store: Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>

    init()
    {
        let store = Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>(
            state: DebugRoot.State(inner: Root.State.initialState),
            reducer: DebugRoot.reducer(inner: Root.reducer()),
            environment: HomeEnvironment.live,
            configuration: .init(updatesStateImmediately: true)
        )
        self._store = StateObject(wrappedValue: store)
    }

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        DebugRootView<RootView>(store: self.store.proxy)
    }
}

extension RootView: RootViewProtocol {}

extension Root.State: RootStateProtocol
{
    public var usesTimeTravel: Bool
    {
        self.homeState?.usesTimeTravel ?? false
    }
}
