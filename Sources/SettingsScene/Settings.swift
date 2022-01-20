import Actomaton
import UserSession

// MARK: - Action

public enum Action: Sendable
{
    case logout
    case onboarding

    case insertTab
    case removeTab
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public var user: User

    public init(user: User)
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
