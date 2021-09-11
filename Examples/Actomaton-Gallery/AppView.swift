import SwiftUI
import Actomaton
import ActomatonStore
import DebugRoot

/// Topmost container view of the app which holds `Store` as a single source of truth.
/// For the child views, pass `Store.Proxy` instead, so that we don't duplicate multiple `Store`s
/// but `Binding` and `Store.proxy.send` (sending message to `Store`) functionalities are still available.
struct AppView: View
{
    @StateObject
    private var store: Store<DebugRoot.Action, DebugRoot.State> = .init(
        state: DebugRoot.State(inner: .init(isDebug: true), usesTimeTravel: true),
        reducer: DebugRoot.reducer(inner: Root.reducer),
        environment: .live
    )

    init() {}

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        DebugRootView<RootView>(store: self.store.proxy)
    }
}

extension RootView: RootViewProtocol {}

extension Root.Action: RootActionProtocol
{
    public var debugToggle: Bool?
    {
        guard case let .debugToggle(value) = self else { return nil }
        return value
    }
}
