import SwiftUI
import ActomatonUI
import Tab
import Home
import Root
import DebugRoot
import LiveEnvironments

/// Topmost container view of the app which holds `Store` as a single source of truth.
@MainActor
struct AppView: View
{
    private var store: Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>

    init()
    {
        self.store = Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>(
            state: DebugRoot.State(inner: Root.State.initialState),
            reducer: DebugRoot.reducer(inner: Root.reducer()),
            environment: .live,
            configuration: {
#if DEBUG
                .init(logFormat: LogFormat()) // Set log-format to enable reducer-logging.
#else
                .init()
#endif
            }()
        )
    }

    var body: some View
    {
        DebugRootView<RootView>(store: self.store)
    }
}

extension RootView: RootViewProtocol {}

extension Root.State: RootStateProtocol
{
    public var usesTimeTravel: Bool
    {
        self.homeState?.common.usesTimeTravel ?? false
    }
}
