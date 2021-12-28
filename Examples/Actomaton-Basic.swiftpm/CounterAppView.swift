import SwiftUI
import ActomatonStore

@MainActor
struct CounterAppView: View
{
    @StateObject
    private var store: Store<Action, State> = .init(
        state: State(),
        reducer: reducer()
    )

    init() {}

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        CounterView(store: self.store.proxy)
    }
}
