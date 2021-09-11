import Actomaton
import TimeTravel

// MARK: - Action

public enum Action<InnerAction: RootActionProtocol>
{
    case timeTravel(TimeTravel.Action<InnerAction>)
}

// MARK: - State

public struct State<InnerState>: Equatable where InnerState: Equatable
{
    public var timeTravel: TimeTravel.State<InnerState>
    public var usesTimeTravel: Bool

    public init(inner state: InnerState, usesTimeTravel: Bool)
    {
        self.timeTravel = .init(inner: state)
        self.usesTimeTravel = usesTimeTravel
    }
}

// MARK: - Reducer

public func reducer<InnerAction, InnerState, Environment>(
    inner: Reducer<InnerAction, InnerState, Environment>
) -> Reducer<Action<InnerAction>, State<InnerState>, Environment>
{
    let rootReducer: Reducer<Action<InnerAction>, State<InnerState>, Environment>
    rootReducer = .combine(
        inner
            .contramap(action: /TimeTravel.Action.inner)
            .contramap(action: /Action.timeTravel)
            .contramap(state: \TimeTravel.State.inner)
            .contramap(state: \State.timeTravel),

        debugToggleReducer()
    )

    func combinedReducer(usesTimeTravel: Bool)
        -> Reducer<Action<InnerAction>, State<InnerState>, Environment>
    {
        if usesTimeTravel {
            return .combine(
                rootReducer,

                // Important: TimeTravel reducer needs to be called after `rootReducer` (after `InnerState` changed).
                TimeTravel.reducer()
                    .contramap(environment: { TimeTravel.Environment(inner: $0) })
                    .contramap(action: /Action.timeTravel)
                    .contramap(state: \State.timeTravel)
            )
        }
        else {
            return rootReducer
        }
    }

    return .init { action, state, environment in
        return combinedReducer(usesTimeTravel: state.usesTimeTravel)
            .run(action, &state, environment)
    }
}

private func debugToggleReducer<InnerAction, InnerState, Environment>()
    -> Reducer<Action<InnerAction>, State<InnerState>, Environment>
{
    .init { action, state, environment in
        switch action {
        case let Action.timeTravel(TimeTravel.Action.inner(innerAction)):
            if let isDebug = innerAction.debugToggle {
                state.usesTimeTravel = isDebug
            }
        default:
            break
        }
        return .empty
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
