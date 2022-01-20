import Actomaton
import SettingsScene
import SettingsUIKit

// MARK: - Action

public enum Action<TabID>: Sendable
    where TabID: Equatable & Sendable
{
    case settings(SettingsScene.Action)

    case insertTab(TabItem<TabID>, index: Int)
    case removeTab(TabID)
    case changeTab(TabID)
}

// MARK: - State

public struct State<TabID>: Equatable, Sendable
    where TabID: Equatable & Sendable
{
    public var tabs: [TabItem<TabID>]
    public var currentTabID: TabID

    public var settings: SettingsScene.State

    public init(
        tabs: [TabItem<TabID>],
        currentTabID: TabID,
        settings: SettingsScene.State
    )
    {
        self.tabs = tabs
        self.currentTabID = currentTabID
        self.settings = settings
    }
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Reducer

public func reducer<TabID>() -> Reducer<Action<TabID>, State<TabID>, Environment>
    where TabID: Equatable
{
    .combine(
        changeTabReducer(),
        insertTabReducer(),
        removeTabReducer()
    )
}

private func changeTabReducer<TabID>()
    -> Reducer<Action<TabID>, State<TabID>, Environment>
    where TabID: Equatable
{
    .init { action, state, environment in
        guard case let .changeTab(tabID) = action else { return .empty }

        state.currentTabID = tabID
        return .empty
    }
}

private func insertTabReducer<TabID>()
    -> Reducer<Action<TabID>, State<TabID>, Environment>
    where TabID: Equatable
{
    .init { action, state, environment in
        guard case let .insertTab(tab, index) = action else { return .empty }

        state.tabs.insert(tab, at: min(max(index, 0), state.tabs.count))

        return .empty
    }
}

private func removeTabReducer<TabID>()
    -> Reducer<Action<TabID>, State<TabID>, Environment>
    where TabID: Equatable
{
    .init { action, state, environment in
        guard case let .removeTab(tabID) = action else { return .empty }

        if let index = state.tabs.firstIndex(where: { $0.id == tabID }) {
            state.tabs.remove(at: index)
        }

        return .empty
    }
}
