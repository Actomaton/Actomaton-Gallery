import Actomaton
import TimeTravel

// MARK: - Action

public enum Action<InnerAction>
{
    case timeTravel(TimeTravel.Action<InnerAction>)
}

// MARK: - State

public struct State<InnerState>: Equatable
    where InnerState: RootStateProtocol & Equatable
{
    public var timeTravel: TimeTravel.State<InnerState>

    public init(inner state: InnerState)
    {
        self.timeTravel = .init(inner: state)
    }

    var usesTimeTravel: Bool
    {
        self.timeTravel.inner.usesTimeTravel
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
        // IMPORTANT: Run `innerReducer` first for possible update of `usesTimeTravel`.
        let effect = innerReducer.run(action, &state, environment)

        var effect2: Effect<Action<InnerAction>>?

        // Important: TimeTravel reducer needs to be called after `innerReducer` (after `InnerState` changed).
        if state.usesTimeTravel {
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
