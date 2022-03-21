import Foundation
import Actomaton
import Counter
import SyncCounters
import ColorFilter
import Todo
import StateDiagram
import Stopwatch
import GitHub
import GameOfLife
import VideoPlayer
import VideoPlayerMulti
import VideoDetector
import Physics

public enum Action: Sendable
{
    case changeCurrent(State.Current?)

    case counter(Counter.Action)
    case syncCounters(SyncCounters.Action)
    case colorFilter(ColorFilter.Action)
    case stopwatch(Stopwatch.Action)
    case stateDiagram(StateDiagram.Action)
    case todo(Todo.Action)
    case github(GitHub.Action)
    case gameOfLife(GameOfLife.Root.Action)
    case videoPlayer(VideoPlayer.Action)
    case videoPlayerMulti(VideoPlayerMulti.Action)
    case videoDetector(VideoDetector.Action)
    case physics(PhysicsRoot.Action)

    case debugToggleTimeTravel(Bool)
    case debugToggleTab(Bool)
}

public struct State: Equatable, Sendable
{
    /// Current example state.
    public var current: Current?

    /// Flag to show TimeTravel.
    public var usesTimeTravel: Bool

    /// Flag to show Tab insert/remove Debug UI.
    public var isDebuggingTab: Bool

    public init(current: State.Current?, usesTimeTravel: Bool, isDebuggingTab: Bool)
    {
        self.current = current
        self.usesTimeTravel = usesTimeTravel
        self.isDebuggingTab = isDebuggingTab
    }
}

public var reducer: Reducer<Action, State, Environment>
{
    .combine(
        debugToggleTimeTravelReducer(),
        debugToggleTabReducer(),
        changeCurrentReducer(),

        // NOTE: Make sub-reducer combining for better type-inference
        Reducer<Action, State, Environment>.combine(
            Counter.reducer
                .contramap(action: /Action.counter)
                .contramap(state: /State.Current.counter)
                .contramap(state: \State.current)
                .contramap(environment: { _ in () }),

            SyncCounters.reducer
                .contramap(action: /Action.syncCounters)
                .contramap(state: /State.Current.syncCounters)
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

            VideoPlayer.reducer
                .contramap(action: /Action.videoPlayer)
                .contramap(state: /State.Current.videoPlayer)
                .contramap(state: \State.current)
                .contramap(environment: \.videoPlayer),

            VideoPlayerMulti.reducer
                .contramap(action: /Action.videoPlayerMulti)
                .contramap(state: /State.Current.videoPlayerMulti)
                .contramap(state: \State.current)
                .contramap(environment: \.videoPlayerMulti),

            VideoDetector.reducer
                .contramap(action: /Action.videoDetector)
                .contramap(state: /State.Current.videoDetector)
                .contramap(state: \State.current)
                .contramap(environment: { _ in () }),

            PhysicsRoot.reducer
                .contramap(action: /Action.physics)
                .contramap(state: /State.Current.physics)
                .contramap(state: \State.current)
                .contramap(environment: { .init(timer: $0.timer) })
        )
    )
}

private func debugToggleTimeTravelReducer() -> Reducer<Action, State, Environment>
{
    .init { action, state, environment in
        switch action {
        case let .debugToggleTimeTravel(isDebug):
            state.usesTimeTravel = isDebug
            return .empty
        default:
            return .empty
        }
    }
}

private func debugToggleTabReducer() -> Reducer<Action, State, Environment>
{
    .init { action, state, environment in
        switch action {
        case let .debugToggleTab(isDebug):
            state.isDebuggingTab = isDebug
            return .empty
        default:
            return .empty
        }
    }
}

private func changeCurrentReducer() -> Reducer<Action, State, Environment>
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
                .map { current in
                    Effect.cancel(ids: { current.cancelAllEffectsPredicate($0) })
                } ?? .empty

        default:
            return .empty
        }
    }
}


public typealias Environment = HomeEnvironment
