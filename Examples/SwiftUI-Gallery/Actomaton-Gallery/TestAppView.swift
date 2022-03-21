import SwiftUI
import ActomatonStore
import GameOfLife

@MainActor
struct TestAppView: View
{
    @StateObject
    private var store: Store<GameOfLife.Root.Action, GameOfLife.Root.State, GameOfLife.Root.Environment>

    init()
    {
        let store = Store<GameOfLife.Root.Action, GameOfLife.Root.State, GameOfLife.Root.Environment>(
            state: GameOfLife.Root.State(pattern: .glider, cellLength: 5),
            reducer: GameOfLife.Root.reducer(),
            environment: .live
        )
        self._store = StateObject(wrappedValue: store)
    }

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        GameOfLife.RootView(store: self.store.proxy.map(environment: { _ in () }))
    }
}
