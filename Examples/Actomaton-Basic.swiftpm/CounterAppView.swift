import SwiftUI
import ActomatonUI

@MainActor
struct CounterAppView: View
{
    private let store: Store<Action, State, Void>

    init()
    {
        self.store = Store<Action, State, Void>(
            state: State(),
            reducer: reducer()
        )
    }

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        CounterView(store: self.store)
    }
}
