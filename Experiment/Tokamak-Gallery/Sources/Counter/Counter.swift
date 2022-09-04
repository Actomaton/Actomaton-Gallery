import Actomaton

// MARK: - Action

public enum Action: Sendable
{
    case increment
    case decrement
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public var count: Int

    public init(count: Int = 0)
    {
        self.count = count
    }
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Effect

struct EffectQueue: Newest1EffectQueueProtocol {}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .init { action, state, _ in
        switch action {
        case .increment:
            state.count += 1
            return Effect(queue: EffectQueue()) {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                return .increment // async recursion
            }

        case .decrement:
            state.count -= 1
            return Effect(queue: EffectQueue()) {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                return .decrement // async recursion
            }
        }
    }
}
