import Foundation
import Tabs
import Home
import SettingsScene
import Counter
import AnimationDemo

public enum TabID: Hashable, Sendable
{
    case home
    case settings
    case counter(UUID)
    case animationDemo

    static let protectedTabIDs: Set<TabID> = [.home, .settings]
}

public enum TabCaseAction: Sendable
{
    case home(Home.Action)
    case settings(SettingsScene.Action)
    case counter(Counter.Action)
    case animationDemo(AnimationDemo.Action)
}

public enum TabCaseState: Equatable, Sendable
{
    case home(Home.State)
    case settings(SettingsScene.State)
    case counter(Counter.State)
    case animationDemo(AnimationDemo.State)

    public var home: Home.State?
    {
        guard case let .home(value) = self else { return nil }
        return value
    }

    public var settings: SettingsScene.State?
    {
        guard case let .settings(value) = self else { return nil }
        return value
    }
}
