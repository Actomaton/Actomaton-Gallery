import SwiftUI
import ActomatonUI
import ElemCellAutomaton

struct ElemCellAutomatonExample: Example
{
    var exampleIcon: Image { Image(systemName: "square.grid.3x2") }

    var exampleInitialState: State.Current
    {
        .elemCellAutomaton(.init(pattern: .init(rule: 110), cellLength: 5, timerInterval: 0.05))
    }

    func exampleView(store: Store<Action, State, Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Action.elemCellAutomaton,
            statePath: /State.Current.elemCellAutomaton,
            makeView: ElemCellAutomaton.RootView.init
        )
    }
}
