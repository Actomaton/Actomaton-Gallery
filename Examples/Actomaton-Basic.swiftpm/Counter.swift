import Actomaton

// MARK: - Action

enum Action
{
    case increment
    case decrement
}

// MARK: - State

struct State: Equatable
{
    var count: Int

    init(count: Int = 0)
    {
        self.count = count
    }
}

// MARK: - Environment

typealias Environment = ()

// MARK: - Reducer

func reducer() -> Reducer<Action, State, Environment>
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
