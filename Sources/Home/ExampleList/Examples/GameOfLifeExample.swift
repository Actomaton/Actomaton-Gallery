import SwiftUI
import ActomatonUI
import GameOfLife

struct GameOfLifeExample: Example
{
    var exampleIcon: Image { Image(systemName: "square.grid.3x3.middle.filled") }

    var exampleInitialState: State.Current
    {
        .gameOfLife(GameOfLifeRoot.State(pattern: .glider, cellLength: 5, timerInterval: 0.05))
    }

    func exampleView(store: Store<Action, State, Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Action.gameOfLife,
            statePath: /State.Current.gameOfLife,
            makeView: GameOfLife.RootView.init
        )
    }
}
