import SwiftUI
import ActomatonStore

@MainActor
public struct GameOfLifeAppView: View
{
    @StateObject
    private var store: Store<GameOfLife.Root.Action, GameOfLife.Root.State, GameOfLife.Root.Environment>

    public init()
    {
        let store = Store<GameOfLife.Root.Action, GameOfLife.Root.State, GameOfLife.Root.Environment>(
            state: GameOfLife.Root.State(pattern: .glider, cellLength: 5),
            reducer: GameOfLife.Root.reducer(),
            environment: .live
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        GameOfLife.RootView(store: self.store.proxy.noEnvironment)
    }
}
