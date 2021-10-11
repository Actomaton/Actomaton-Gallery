import Foundation
import Actomaton

// MARK: - Action

public enum Action
{
    case login
    case loginOK
    case logout
    case forceLogout
    case logoutOK
}

// MARK: - State

public enum State: Equatable
{
    case loggedOut
    case loggingIn
    case loggedIn
    case loggingOut
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Effect

public struct LoginFlowEffectQueue: Newest1EffectQueueProtocol {}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    Reducer { action, state, environment in
        switch (action, state) {
        case (.login, .loggedOut):
            state = .loggingIn

            return Effect(queue: LoginFlowEffectQueue()) {
                await Task.sleep(1_000_000_000)
                if Task.isCancelled {
                    print("===> loggingIn cancelled")
                    return nil
                }
                return .loginOK
            }

        case (.loginOK, .loggingIn):
            state = .loggedIn
            return .empty

        case (.logout, .loggedIn),
            (.forceLogout, .loggingIn),
            (.forceLogout, .loggedIn):
            state = .loggingOut

            return Effect(queue: LoginFlowEffectQueue()) {
                await Task.sleep(1_000_000_000)
                return .logoutOK
            }

        case (.logoutOK, .loggingOut):
            state = .loggedOut
            return .empty

        default:
            return .empty
        }

    }
}
