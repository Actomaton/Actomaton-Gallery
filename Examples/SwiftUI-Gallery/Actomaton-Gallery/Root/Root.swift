import Actomaton
import Counter
import ColorFilter
import Todo
import StateDiagram
import Stopwatch
import GitHub
import GameOfLife
import VideoDetector

/// Root namespace.
/// - Todo: Move to Swift Package (but compile doesn't work well in Xcode 13 beta 5)
enum Root {}

extension Root
{
    public enum Action
    {
        case changeCurrent(State.Current?)
        case debugToggle(Bool)

        case counter(Counter.Action)
        case colorFilter(ColorFilter.Action)
        case stopwatch(Stopwatch.Action)
        case stateDiagram(StateDiagram.Action)
        case todo(Todo.Action)
        case github(GitHub.Action)
        case gameOfLife(GameOfLife.Root.Action)
        case videoDetector(VideoDetector.Action)
    }

    public struct State: Equatable
    {
        /// Current example state.
        var current: Current?

        /// Flag to show TimeTravel.
        var usesTimeTravel: Bool
    }

    public static var reducer: Reducer<Action, State, Environment>
    {
        .combine(
            debugToggleReducer(),
            previousEffectCancelReducer(),

            // NOTE: Make sub-reducer combining for better type-inference
            Reducer<Action, State, Environment>.combine(
                Counter.reducer
                    .contramap(action: /Action.counter)
                    .contramap(state: /State.Current.counter)
                    .contramap(state: \State.current)
                    .contramap(environment: { _ in () }),

                ColorFilter.reducer
                    .contramap(action: /Action.colorFilter)
                    .contramap(state: /State.Current.colorFilter)
                    .contramap(state: \State.current)
                    .contramap(environment: { _ in () }),

                Todo.reducer
                    .contramap(action: /Action.todo)
                    .contramap(state: /State.Current.todo)
                    .contramap(state: \State.current)
                    .contramap(environment: { _ in () }),

                StateDiagram.reducer
                    .contramap(action: /Action.stateDiagram)
                    .contramap(state: /State.Current.stateDiagram)
                    .contramap(state: \State.current)
                    .contramap(environment: { _ in () }),

                Stopwatch.reducer
                    .contramap(action: /Action.stopwatch)
                    .contramap(state: /State.Current.stopwatch)
                    .contramap(state: \State.current)
                    .contramap(environment: { $0.stopwatch }),

                GitHub.reducer
                    .contramap(action: /Action.github)
                    .contramap(state: /State.Current.github)
                    .contramap(state: \State.current)
                    .contramap(environment: { $0.github })
            ),

            Reducer<Action, State, Environment>.combine(
                GameOfLife.Root.reducer()
                    .contramap(action: /Action.gameOfLife)
                    .contramap(state: /State.Current.gameOfLife)
                    .contramap(state: \State.current)
                    .contramap(environment: { $0.gameOfLife }),

                VideoDetector.reducer
                    .contramap(action: /Action.videoDetector)
                    .contramap(state: /State.Current.videoDetector)
                    .contramap(state: \State.current)
                    .contramap(environment: { _ in () })
            )
        )
    }

    private static func debugToggleReducer() -> Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case let .debugToggle(isDebug):
                state.usesTimeTravel = isDebug
                return .empty
            default:
                return .empty
            }
        }
    }

    /// When navigating to example, cancel its previous running effects.
    private static func previousEffectCancelReducer() -> Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case let .changeCurrent(current):
                state.current = current

                // Cancel previous effects when revisiting the same screen.
                //
                // NOTE:
                // We sometimes don't want to cancel previous effects at example screen's
                // `onAppear`, `onDisappear`, `init`, `deinit`, etc,
                // because we want to keep them running
                // (e.g. Stopwatch temporarily visiting child screen),
                // so `.changeCurrent` (revisiting the same screen) is
                // the best timing to cancel them.
                return current
                    .map { Effect.cancel(ids: $0.cancelAllEffectsPredicate) } ?? .empty

            default:
                return .empty
            }
        }
    }

    typealias Environment = RootEnvironment
}
