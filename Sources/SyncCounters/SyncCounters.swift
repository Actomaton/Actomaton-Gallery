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
    public var common: Common
    public var counterState: Counter.State

    public init(
        common: Common = .init(),
        counterState: Counter.State = .init(count: 0)
    )
    {
        self.counterState = counterState
        self.common = common
    }

    public struct Common: Equatable, Sendable
    {
        internal fileprivate(set) var numberOfCounters: Int

        public init(numberOfCounters: Int = 1)
        {
            self.numberOfCounters = numberOfCounters
        }

        public var canAddChild: Bool
        {
            self.numberOfCounters < 5
        }

        public var canRemoveChild: Bool
        {
            self.numberOfCounters > 0
        }
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
            state.common.numberOfCounters = max(state.common.numberOfCounters + 1, 0)
            return .empty

        case .removeChild:
            state.common.numberOfCounters = max(state.common.numberOfCounters - 1, 0)
            return .empty

        case .child(.increment):
            state.counterState.count += 1
            return .empty

        case .child(.decrement):
            state.counterState.count -= 1
            return .empty
        }
    }
}

// MARK: - @unchecked Sendable

// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.
extension UUID: @unchecked Sendable {}
