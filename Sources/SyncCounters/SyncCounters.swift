import Foundation
import Actomaton
import Counter

// MARK: - Action

public enum Action
{
    case addChild
    case removeChild
    case child(Counter.Action)
}

// MARK: - State

public struct State: Equatable
{
    private var _count: Int = 0

    /// Computed getter/setter property to delegate (synchronize) `count` state to children.
    public var count: Int
    {
        get {
            self._count
        }
        set {
            self._count = newValue

            for i in 0 ..< self.children.count {
                self.children[i].counterState.count = newValue
            }
        }
    }

    public var children: [CounterState] = [.init(count: 0)]

    public init() {}

    public var canAddChild: Bool
    {
        self.children.count < 5
    }

    public var canRemoveChild: Bool
    {
        !self.children.isEmpty
    }

    // MARK: - CounterState

    public struct CounterState: Hashable, Identifiable
    {
        public let id = UUID()

        public var counterState: Counter.State

        public init(count: Int)
        {
            self.counterState = .init(count: count)
        }

        public func hash(into hasher: inout Hasher)
        {
            hasher.combine(id)
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
            state.children.append(.init(count: state.count))
            return .empty

        case .removeChild:
            if !state.children.isEmpty {
                state.children.removeLast()
            }
            return .empty

        case .child(.increment):
            state.count += 1
            return .empty

        case .child(.decrement):
            state.count -= 1
            return .empty
        }
    }
}
