import SwiftUI
import ActomatonStore
import CommonEffects

@MainActor
public struct StopwatchAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(),
            reducer: reducer,
            environment: .live(commonEffects: .live)
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        StopwatchView(store: self.store.proxy.noEnvironment)
    }
}

// MARK: - Environment.live

extension Stopwatch.Environment
{
    public static func live(commonEffects: CommonEffects) -> Stopwatch.Environment
    {
        return Environment(
            getDate: commonEffects.now,
            timer: {
                Timer.publish(every: $0, tolerance: $0 * 0.1, on: .main, in: .common)
                    .autoconnect()
                    .toAsyncStream()
            }
        )
    }
}
