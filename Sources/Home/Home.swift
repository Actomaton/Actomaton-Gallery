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
import VideoDetector
import Physics

public enum Action
{
    case changeCurrent(State.Current?)
    case debugToggle(Bool)

    case universalLink(URL)

    case counter(Counter.Action)
    case syncCounters(SyncCounters.Action)
    case colorFilter(ColorFilter.Action)
    case stopwatch(Stopwatch.Action)
    case stateDiagram(StateDiagram.Action)
    case todo(Todo.Action)
    case github(GitHub.Action)
    case gameOfLife(GameOfLife.Root.Action)
    case videoDetector(VideoDetector.Action)
    case physics(PhysicsRoot.Action)
}

public struct State: Equatable
{
    /// Current example state.
    var current: Current?

    /// Flag to show TimeTravel.
    public var usesTimeTravel: Bool

    public init(current: State.Current?, usesTimeTravel: Bool)
    {
        self.current = current
        self.usesTimeTravel = usesTimeTravel
    }
}

public var reducer: Reducer<Action, State, Environment>
{
    .combine(
        debugToggleReducer(),
        changeCurrentReducer(),
        universalLinkReducer(),

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

private func debugToggleReducer() -> Reducer<Action, State, Environment>
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
                .map { Effect.cancel(ids: $0.cancelAllEffectsPredicate) } ?? .empty

        default:
            return .empty
        }
    }
}

private func universalLinkReducer() -> Reducer<Action, State, Environment>
{
    .init { action, state, environment in
        guard case let .universalLink(url) = action,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return .empty }

        let queryItems = urlComponents.queryItems ?? []

        print("[UniversalLink] url.pathComponents", url.pathComponents)
        print("[UniversalLink] queryItems", queryItems)

        switch url.pathComponents {
        case ["/"]:
            state.current = nil

        case ["/", "counter"]:
            let count = queryItems.first(where: { $0.name == "count" })
                .flatMap { $0.value }
                .flatMap(Int.init) ?? 0
            state.current = .counter(.init(count: count))

        case ["/", "physics"]:
            state.current = .physics(.init(current: nil))

        case ["/", "physics", "gravity-universe"]:
            state.current = .physics(.gravityUniverse)

        default:
            break
        }

        return .empty
    }
}

public typealias Environment = HomeEnvironment
