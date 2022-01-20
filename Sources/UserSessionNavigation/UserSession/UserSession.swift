import Foundation
import ActomatonStore

// MARK: - Action

public enum Action: Sendable
{
    case login
    case loginOK(User)
    case logout
    case logoutOK
    case loginError(Error)
    case forceLogout
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public var authStatus: AuthStatus

    public var error: Error?

    public init(authStatus: AuthStatus)
    {
        self.authStatus = authStatus
    }

    public var loggedInUser: User?
    {
        self.authStatus.loggedIn
    }

    // MARK: - State.AuthStatus

    public enum AuthStatus: Equatable, Sendable
    {
        case loggedOut
        case loggingIn
        case loggedIn(User)
        case loggingOut

        public var loggedIn: User?
        {
            guard case let .loggedIn(value) = self else { return nil }
            return value
        }
    }
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Effect

public struct LoginFlowEffectQueue: Newest1EffectQueueProtocol {}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    Reducer { action, state, environment in
        switch (action, state.authStatus) {
        case (.login, .loggedOut):
            state.authStatus = .loggingIn

            return Effect(queue: LoginFlowEffectQueue()) {
                try await Task.sleep(nanoseconds: 300_000_000)
                print("===> Login effect isCancelled", Task.isCancelled)

                if Task.isCancelled {
                    return nil
                }

                let user = User.makeSample()
                return .loginOK(user)
            }

        case let (.loginOK(user), .loggingIn):
            state.authStatus = .loggedIn(user)
            return .empty

        case let (.loginError(error), .loggingIn),
            let (.loginError(error), .loggedIn):
            state.error = error
            return Effect(queue: LoginFlowEffectQueue()) { nil }

        case (.forceLogout, .loggingIn) where state.error != nil,
            (.forceLogout, .loggedIn) where state.error != nil:
            state.error = nil
            fallthrough

        case (.logout, .loggedIn):
            state.authStatus = .loggingOut

            return Effect(queue: LoginFlowEffectQueue()) {
                try await Task.sleep(nanoseconds: 300_000_000)
                return .logoutOK
            }

        case (.logoutOK, .loggingOut):
            state.authStatus = .loggedOut
            state.error = nil
            return .empty

        default:
            return .empty
        }
    }
}
