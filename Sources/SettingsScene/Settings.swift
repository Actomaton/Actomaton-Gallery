import Actomaton
import UserSession

// MARK: - Action

public enum Action
{
    case logout
    case onboarding
}

// MARK: - State

public struct State: Equatable
{
    public var user: User?

    public init(user: User?)
    {
        self.user = user
    }
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .empty
}
