import SwiftUI
import ActomatonStore
import GameOfLife

struct GameOfLifeExample: Example
{
    var exampleIcon: Image { Image(systemName: "checkmark.square") }

    var exampleInitialState: State.Current
    {
        .gameOfLife(GameOfLife.Root.State(pattern: .glider, cellLength: 5))
    }

    func exampleView(store: Store<Action, State, Environment>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Action.gameOfLife,
            statePath: /State.Current.gameOfLife,
            makeView: GameOfLife.RootView.init
        )
    }
}
