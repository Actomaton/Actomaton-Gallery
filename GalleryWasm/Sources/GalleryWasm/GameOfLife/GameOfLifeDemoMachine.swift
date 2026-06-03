import Foundation
import Actomaton
import CommonEffects
import GameOfLife
import Reactivity

@Reactive
final class GameOfLifeState
{
    var game: GameOfLife.State = .init(pattern: .glider, cellLength: 8, timerInterval: 0.08)
}

typealias GameOfLifeDemoMachine = MealyDriver<GameOfLife.Action, GameOfLifeState, Never>

func makeGameOfLifeDemoMachine(state: GameOfLifeState = GameOfLifeState()) -> GameOfLifeDemoMachine
{
    GameOfLifeDemoMachine(
        state: state,
        reducer: GameOfLife.reducer()
            .contramap(state: \GameOfLifeState.game),
        environment: GameOfLife.Environment(timer: CommonEffects.timer)
    )
}
