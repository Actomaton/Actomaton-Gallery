import SwiftUI
import ActomatonStore
import GameOfLife

struct GameOfLifeExample: Example
{
    var exampleIcon: Image { Image(systemName: "checkmark.square") }

    var exampleInitialState: Root.State.Current
    {
        .gameOfLife(GameOfLife.Root.State(pattern: .glider, cellLength: 5))
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            actionPath: /Root.Action.gameOfLife,
            statePath: /Root.State.Current.gameOfLife,
            makeView: GameOfLife.RootView.init
        )
    }
}
