import Foundation
import ElemCellAutomaton
import CanvasPlayer
import CoreGraphics
import CommonInterfaces

/// Elementary cellular automaton SwiftUI screen entry point over the shared
/// `ElemCellAutomaton` reducer. All board evolution / canvas resizing / rule reseeding
/// lives in `ElemCellAutomaton`, shared verbatim with the WebAssembly screen.
/// https://en.wikipedia.org/wiki/Elementary_cellular_automaton

// MARK: - Action

public enum Action: Sendable
{
    case game(ElemCellAutomaton.Action)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    var game: ElemCellAutomaton.State

    public init(pattern: Pattern, cellLength: CGFloat, timerInterval: TimeInterval)
    {
        self.game = ElemCellAutomaton.State(rule: pattern.rule, cellLength: Double(cellLength), timerInterval: timerInterval)
    }
}

public func cancelAllEffectsPredicate(id: any EffectID) -> Bool
{
    CanvasPlayer.cancelAllEffectsPredicate(id: id)
}

// MARK: - Reducer

public func reducer() -> Reducer<Action, State, Environment>
{
    ElemCellAutomaton.reducer
        .contramap(action: /Action.game)
        .contramap(state: \State.game)
        .contramap(environment: { $0.game })
}
