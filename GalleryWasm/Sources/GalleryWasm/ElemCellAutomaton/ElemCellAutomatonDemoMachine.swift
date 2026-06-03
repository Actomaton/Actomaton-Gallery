import Foundation
import Actomaton
import CommonEffects
import ElemCellAutomaton
import Reactivity

@Reactive
final class ElemCellAutomatonState
{
    // `cellLength` = pixels per cell; the grid sizes itself to the canvas (see `ElemCellAutomatonPage`).
    var elemCellAutomaton: ElemCellAutomaton.State = .init(cellLength: 6, timerInterval: 0.05)
}

typealias ElemCellAutomatonDemoMachine = MealyDriver<ElemCellAutomaton.Action, ElemCellAutomatonState, Never>

func makeElemCellAutomatonDemoMachine(state: ElemCellAutomatonState = ElemCellAutomatonState()) -> ElemCellAutomatonDemoMachine
{
    ElemCellAutomatonDemoMachine(
        state: state,
        reducer: ElemCellAutomaton.reducer
            .contramap(state: \ElemCellAutomatonState.elemCellAutomaton),
        environment: ElemCellAutomaton.Environment(timer: CommonEffects.timer)
    )
}
