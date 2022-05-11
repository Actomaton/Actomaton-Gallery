import SwiftUI
import ActomatonStore

@MainActor
public struct VideoPlayerMultiAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(displayMode: .multiplePlayers),
            reducer: reducer,
            environment: .live
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        VideoPlayerMultiView(store: self.store.proxy)
    }
}
