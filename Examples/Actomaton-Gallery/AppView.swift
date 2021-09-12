import SwiftUI
import ActomatonStore
import DebugRoot

private let initialRootState: Root.State = .init(
    current: nil, //.gameOfLife(.init(pattern: .glider)),
    usesTimeTravel: true
)

/// Topmost container view of the app which holds `Store` as a single source of truth.
/// For the child views, pass `Store.Proxy` instead, so that we don't duplicate multiple `Store`s
/// but `Binding` and `Store.proxy.send` (sending message to `Store`) functionalities are still available.
struct AppView: View
{
    @StateObject
    private var store: Store<DebugRoot.Action, DebugRoot.State> = .init(
        state: DebugRoot.State(inner: initialRootState),
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

extension Root.State: RootStateProtocol {}
