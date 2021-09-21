import SwiftUI
import ActomatonStore
import Counter

struct CounterAppView: View
{
    @StateObject
    private var store: Store<Counter.Action, Counter.State> = .init(
        state: Counter.State(),
        reducer: Counter.reducer
    )

    init() {}

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        CounterView(store: self.store.proxy)
    }
}
