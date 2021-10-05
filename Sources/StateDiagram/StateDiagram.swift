import Foundation
import Actomaton

public enum Action: String, CustomStringConvertible
{
    case login
    case loginOK
    case logout
    case forceLogout
    case logoutOK

    public var description: String { return self.rawValue }
}

public enum State: String, CustomStringConvertible, Equatable
{
    case loggedOut
    case loggingIn
    case loggedIn
    case loggingOut

    public var description: String { return self.rawValue }
}

public struct LoginFlowEffectID: Newest1EffectQueueProtocol {}

public typealias Environment = ()

public var reducer: Reducer<Action, State, Environment>
{
    Reducer { action, state, environment in
        switch (action, state) {
        case (.login, .loggedOut):
            state = .loggingIn
            return Effect(id: LoginFlowEffectID()) {
                await Task.sleep(1_000_000_000)
                if Task.isCancelled {
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
            return Effect(id: LoginFlowEffectID()) {
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
