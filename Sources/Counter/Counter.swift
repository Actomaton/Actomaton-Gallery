import Actomaton

// MARK: - Action

public enum Action: String, CustomStringConvertible
{
    case increment
    case decrement

    public var description: String { return self.rawValue }
}

// MARK: - State

public struct State: Equatable
{
    public var count: Int = 0

    public init() {}
}

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

public typealias Environment = ()
