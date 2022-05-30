import Foundation
import Actomaton
import Counter

// MARK: - Action

public enum Action: Sendable
{
    case addChild
    case removeChild
    case child(Counter.Action)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public var commonCounterState: Counter.State = .init(count: 0)

    internal fileprivate(set) var numberOfCounters: Int = 1

    public init() {}

    public var canAddChild: Bool
    {
        self.numberOfCounters < 5
    }

    public var canRemoveChild: Bool
    {
        self.numberOfCounters > 0
    }
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .init { action, state, _ in
        switch action {
        case .addChild:
            state.numberOfCounters = max(state.numberOfCounters + 1, 0)
            return .empty

        case .removeChild:
            state.numberOfCounters = max(state.numberOfCounters - 1, 0)
            return .empty

        case .child(.increment):
            state.commonCounterState.count += 1
            return .empty

        case .child(.decrement):
            state.commonCounterState.count -= 1
            return .empty
        }
    }
}

// MARK: - @unchecked Sendable

// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.
extension UUID: @unchecked Sendable {}
