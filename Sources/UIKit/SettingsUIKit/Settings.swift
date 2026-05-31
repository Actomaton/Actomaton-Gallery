import CommonInterfaces
import SettingsScene

public typealias Action = SettingsScene.Action
public typealias State = SettingsScene.State
public typealias Environment = SettingsScene.Environment
public typealias Route = SettingsScene.Action

// MARK: - Reducer

public var reducer: Reducer<Action, State, SendRouteEnvironment<Environment, Route>>
{
    .init { action, state, env in
        Effect.fireAndForget { _ in
            env.sendRoute(action)
        }
    }
}
