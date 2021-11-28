import ActomatonStore
import SettingsScene

public typealias Action = SettingsScene.Action
public typealias State = SettingsScene.State
public typealias Environment = SettingsScene.Environment
public typealias Route = SettingsScene.Action

// MARK: - Reducer

public var reducer: Reducer<Action, State, SendRouteEnvironment<Environment, Route>>
{
    .forwardActions()
}
