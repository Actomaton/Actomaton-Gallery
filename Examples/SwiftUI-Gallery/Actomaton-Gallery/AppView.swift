import SwiftUI
import ActomatonStore
import Home
import DebugRoot

/// Topmost container view of the app which holds `Store` as a single source of truth.
/// For the child views, pass `Store.Proxy` instead, so that we don't duplicate multiple `Store`s
/// but `Binding` and `Store.proxy.send` (sending message to `Store`) functionalities are still available.
@MainActor
struct AppView: View
{
    @StateObject
    private var store: Store<DebugRoot.Action, DebugRoot.State> = .init(
        state: DebugRoot.State(inner: initialRootState),
        reducer: DebugRoot.reducer(inner: Home.reducer),
        environment: .live
    )

    init() {}

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        DebugRootView<HomeView>(store: self.store.proxy)
    }
}

extension HomeView: RootViewProtocol {}

extension Home.State: RootStateProtocol {}

// MARK: - Private

/// App's initial state to quick start to the target screen (for debugging)
private let initialRootState: Home.State = .init(
//    current: .syncCounters(.init()),
//    current: .physics(.gravityUniverse),
//    current: .physics(.gravitySurface),
//    current: .physics(.collision),
//    current: .physics(.pendulum),
//    current: .physics(.doublePendulum),
//    current: .physics(.galtonBoard),
//    current: .gameOfLife(.init(pattern: .glider, cellLength: 5)),

    current: nil,
    usesTimeTravel: true
)
