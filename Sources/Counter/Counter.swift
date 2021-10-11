import Actomaton

// MARK: - Action

public enum Action
{
    case increment
    case decrement
}

// MARK: - State

public struct State: Equatable
{
    public var count: Int

    public init(count: Int = 0)
    {
        self.count = count
    }
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .init { action, state, _ in
        switch action {
        case .increment:
            state.count += 1
            return .empty
        case .decrement:
            state.count -= 1
            return .empty
        }
    }
}
