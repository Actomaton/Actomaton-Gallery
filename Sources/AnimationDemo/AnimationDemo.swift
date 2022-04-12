import Actomaton

// MARK: - Action

public enum Action: Sendable
{
    case tap
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public var isPresenting: Bool = false

    public init() {}
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .init { action, state, _ in
        switch action {
        case .tap:
            state.isPresenting.toggle()
            return .empty
        }
    }
}
