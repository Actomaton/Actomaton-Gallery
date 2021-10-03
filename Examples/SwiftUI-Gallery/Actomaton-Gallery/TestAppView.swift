import SwiftUI
import ActomatonStore
import GameOfLife

struct TestAppView: View
{
    @StateObject
    private var store: Store<GameOfLife.Root.Action, GameOfLife.Root.State> = .init(
        state: GameOfLife.Root.State(pattern: .glider, cellLength: 5),
        reducer: GameOfLife.Root.reducer(),
        environment: .live
    )

    init() {}

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        GameOfLife.RootView(store: self.store.proxy)
    }
}
