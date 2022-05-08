import SwiftUI
import ActomatonStore

@MainActor
public struct DownloaderAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(),
            reducer: reducer,
            environment: .live
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        DownloaderView(store: self.store.proxy.map(environment: { _ in () }))
    }
}
