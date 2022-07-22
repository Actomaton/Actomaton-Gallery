import Actomaton
import TimeTravel

// MARK: - Action

public enum Action<InnerAction>: Sendable
    where InnerAction: Sendable
{
    case timeTravel(TimeTravel.Action<InnerAction>)

    #if !DEBUG
    // Workaround additional `case` for avoiding broken Action in 'Release' build,
    // which is likely due to Swift compiler bug that optimizes enum case (possibly when single case) in strange way.
    // https://github.com/inamiy/Actomaton-Gallery/issues/26
    case doNotUseThis(Never)
    #endif
}

// MARK: - State

public struct State<InnerState>: Equatable, Sendable
    where InnerState: RootStateProtocol & Equatable & Sendable
{
    public var timeTravel: TimeTravel.State<InnerState>

    public init(inner state: InnerState)
    {
        self.timeTravel = .init(inner: state)
    }
}

// MARK: - Reducer

public func reducer<InnerAction, InnerState, Environment>(
    inner: Reducer<InnerAction, InnerState, Environment>
) -> Reducer<Action<InnerAction>, State<InnerState>, Environment>
{
    let innerReducer: Reducer<Action<InnerAction>, State<InnerState>, Environment>
    innerReducer = inner
        .contramap(action: /TimeTravel.Action.inner)
        .contramap(action: /Action.timeTravel)
        .contramap(state: \TimeTravel.State.inner)
        .contramap(state: \State.timeTravel)

    let timeTravelReducer: Reducer<Action<InnerAction>, State<InnerState>, Environment>
    timeTravelReducer = TimeTravel.reducer()
        .contramap(action: /Action.timeTravel)
        .contramap(state: \State.timeTravel)
        .contramap(environment: { TimeTravel.Environment(inner: $0) })

    return .init { action, state, environment in
        // print("[DebugRoot] action", action)

        // IMPORTANT: Run `innerReducer` first for possible update of `usesTimeTravel`.
        let effect = innerReducer.run(action, &state, environment)

        var effect2: Effect<Action<InnerAction>>?

        // Important: TimeTravel reducer needs to be called after `innerReducer` (after `InnerState` changed).
        if state.timeTravel.inner.usesTimeTravel {
            effect2 = timeTravelReducer.run(action, &state, environment)
        }

        return effect + (effect2 ?? .empty)
    }
}

// MARK: - Private

extension String
{
    fileprivate var noAppPrefix: String
    {
        self.replacingOccurrences(of: "Actomaton_Gallery.", with: "")
    }
}
