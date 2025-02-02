import Foundation
import CoreGraphics
import Actomaton

/// Elementary cellular automaton game engine namespace.
/// https://en.wikipedia.org/wiki/Elementary_cellular_automaton
public enum ElemCellAutomatonRoot {}

extension ElemCellAutomatonRoot
{
    // MARK: - Action

    public enum Action: Sendable
    {
        case game(Game.Action)
    }

    // MARK: - State

    public struct State: Equatable, Sendable
    {
        var game: Game.State

        public init(pattern: Pattern, cellLength: CGFloat, timerInterval: TimeInterval)
        {
            self.game = Game.State(pattern: pattern, cellLength: cellLength, timerInterval: timerInterval)
        }
    }

    // MARK: - Environment

    public typealias Environment = RootEnvironment

    public static func cancelAllEffectsPredicate(id: EffectID) -> Bool
    {
        Game.cancelAllEffectsPredicate(id: id)
    }

    // MARK: - Reducer

    public static func reducer() -> Reducer<Action, State, Environment>
    {
        Game.reducer()
            .contramap(action: /ElemCellAutomatonRoot.Action.game)
            .contramap(state: \ElemCellAutomatonRoot.State.game)
            .contramap(environment: { $0.game })
    }
}
