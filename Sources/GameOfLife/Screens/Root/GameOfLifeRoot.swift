import Foundation
import CoreGraphics
import Actomaton

/// Conway's Game-of-Life root namespace.
///
/// - SeeAlso:
///   - https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
///   - https://www.conwaylife.com/wiki/Category:Patterns
///   - https://apps.apple.com/us/app/game-of-life/id1377718068?mt=12
public enum Root {}

extension Root
{
    // MARK: - Action

    public enum Action: Sendable
    {
        case presentPatternSelect
        case dismissPatternSelect

        case game(Game.Action)
        case favorite(Favorite.Action)
        case patternSelect(PatternSelect.Action)
    }

    // MARK: - State

    public struct State: Equatable, Sendable
    {
        var game: Game.State
        var favorite: Favorite.State
        var patternSelect: PatternSelect.State?

        public init(pattern: Pattern, cellLength: CGFloat, timerInterval: TimeInterval = 0.05)
        {
            self.game = Game.State(pattern: pattern, cellLength: cellLength, timerInterval: timerInterval)
            self.favorite = Favorite.State()
        }

        var isFavoritePattern: Bool
        {
            self.favorite.patternNames.contains(self.game.selectedPattern.title)
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
        .combine(
            self._reducer(),

            Game.reducer()
                .contramap(action: /Root.Action.game)
                .contramap(state: \Root.State.game)
                .contramap(environment: { $0.game }),

            Favorite.reducer()
                .contramap(action: /Root.Action.favorite)
                .contramap(state: \Root.State.favorite)
                .contramap(environment: { $0.favorite }),

            PatternSelect.reducer()
                .contramap(action: /Action.patternSelect)
                .contramap(state: /PatternSelect.State?.some)
                .contramap(state: \State.patternSelect)
                .contramap(environment: { $0.patternSelect })
        )
    }

    private static func _reducer() -> Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case .presentPatternSelect:
                state.patternSelect = PatternSelect.State(favoritePatternNames: state.favorite.patternNames)
                return .empty

            case .dismissPatternSelect:
                state.patternSelect = nil
                return .empty

            case let .patternSelect(.didParsePatternFile(pattern)):
                state.patternSelect = nil

                var gameEffect: Effect<Action> = .empty

                // FIXME:
                // This logic basically tee-ing `Reducer` between `Root` (parent) and `Game` (child),
                // which could possibly be improved by more elegant `Reducer` composition.
                if let pattern = pattern {
                    let effect = Game.reducer()
                        .run(.updatePattern(pattern), &state.game, environment.game)

                    gameEffect = effect.map { Root.Action.game($0) }
                }
                else {
                    // TODO: show parse failure alert
                }

                return .empty + gameEffect

            case let .patternSelect(.favorite(.addFavorite(patternName))):
                state.favorite.patternNames.append(patternName)
                return .empty

            case let .patternSelect(.favorite(.removeFavorite(patternName))):
                state.favorite.patternNames.removeAll { $0 == patternName }
                return .empty

            case .game,
                .favorite,
                .patternSelect:
                return .empty
            }
        }
    }
}
