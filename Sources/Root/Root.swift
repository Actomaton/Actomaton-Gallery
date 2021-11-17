import Foundation
import SwiftUI
import Actomaton
import Tab
import Home
import Counter

public enum TabID: Hashable
{
    case home
    case counter(UUID)
}

public enum TabCaseAction
{
    case home(Home.Action)
    case counter(Counter.Action)
}

public enum TabCaseState: Equatable
{
    case home(Home.State)
    case counter(Counter.State)

    public var home: Home.State?
    {
        guard case let .home(value) = self else { return nil }
        return value
    }
}

// MARK: - Action

public enum Action
{
    case tab(Tab.Action<TabCaseAction, TabCaseState, TabID>)

    case universalLink(URL)

    /// Inserts random tab by tab index.
    case insertRandomTab(index: Int)

    /// Removes tab by tab index.
    /// - Note: If `index = nil`, random tab index will be removed.
    case removeTab(index: Int?)
}

// MARK: - State

public typealias State = Tab.State<TabCaseState, TabID>

extension State
{
    /// App's initial state to quick start to the target screen (for debugging)
    public static var initialState: State
    {
        var initialHomeState: Home.State
        {
            Home.State(
//                current: .syncCounters(.init()),
//                current: .physics(.gravityUniverse),
//                current: .physics(.gravitySurface),
//                current: .physics(.collision),
//                current: .physics(.pendulum),
//                current: .physics(.doublePendulum),
//                current: .physics(.galtonBoard),
//                current: .gameOfLife(.init(pattern: .glider, cellLength: 5)),

                current: nil,
                usesTimeTravel: true,
                isDebuggingTab: false
            )
        }

        return State(
            tabs: [
                Tab.TabItem(
                    id: .home,
                    state: .home(initialHomeState),
                    tabItemTitle: "Home",
                    tabItemIcon: Image(systemName: "house")
                ),
                counterTabItem(index: 0),
                counterTabItem(index: 1),
                counterTabItem(index: 2),
                counterTabItem(index: 3)
            ],
            currentTabID: .home
        )
    }

    public var homeState: Home.State?
    {
        self.tabs.first(where: { $0.id == .home })?.state.home
    }

    public mutating func updateHomeState(_ update: (inout Home.State) -> Void)
    {
        guard let tabIndex = self.tabs.firstIndex(where: { $0.id == .home }),
              var homeState = self.homeState else { return }

        update(&homeState)

        self.tabs[tabIndex].state = .home(homeState)
    }

    public var isDebuggingTab: Bool
    {
        self.homeState?.isDebuggingTab ?? false
    }
}

public func counterTabItem(index: Int) -> Tab.TabItem<TabCaseState, TabID>
{
    Tab.TabItem(
        id: .counter(UUID()),
        state: .counter(Counter.State(count: 0)),
        tabItemTitle: "Counter \(index)",
        tabItemIcon: Image(systemName: "\(index).square.fill")
    )
}

// MARK: - Environment

public typealias Environment = HomeEnvironment

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    return Reducer { action, state, environment in
        switch action {
        case let .insertRandomTab(index):
            return Effect {
                // Random alphabet "A" ... "Z".
                let char = (65 ... 90).map { String(UnicodeScalar($0)) }.randomElement()!

                return .tab(.insertTab(
                    Tab.TabItem(
                        id: .counter(UUID()),
                        state: .counter(.init(count: 0)),
                        tabItemTitle: "Tab \(char)",
                        tabItemIcon: Image(systemName: "\(char.lowercased()).circle")
                    ),
                    index: index
                ))
            }

        case let .removeTab(index):
            guard !state.tabs.isEmpty else { return .empty }

            // Always keep `TabID.home`.
            if state.tabs.count == 1
                && state.tabs.first!.id == .home
            {
                return .empty
            }

            let adjustedIndex: Int = {
                if let index = index {
                    return min(max(index, state.tabs.count - 1), 0)
                }
                else {
                    return Int.random(in: 0 ..< state.tabs.count)
                }
            }()

            let tabID = state.tabs[adjustedIndex].id

            guard tabID != .home else {
                // Retry with same `removeTab` action with `index = nil` as random index.
                return .nextAction(.removeTab(index: nil))
            }

            return .nextAction(.tab(.removeTab(tabID)))

        case .universalLink:
            return universalLinkReducer().run(action, &state, environment)

        case .tab:
            return tabReducer.run(action, &state, environment)
        }
    }
}

private var tabReducer: Reducer<Action, State, Environment>
{
    Tab
        .reducer(
            innerReducers: { tabID in
                switch tabID {
                case .home:
                    return Home.reducer
                        .contramap(action: /TabCaseAction.home)
                        .contramap(state: /TabCaseState.home)

                case .counter:
                    return Counter.reducer
                        .contramap(action: /TabCaseAction.counter)
                        .contramap(state: /TabCaseState.counter)
                        .contramap(environment: { _ in () })
                }
            }
        )
        .contramap(action: /Action.tab)
}

private func universalLinkReducer() -> Reducer<Action, State, Environment>
{
    .init { action, state, environment in
        guard case let .universalLink(url) = action,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return .empty }

        let queryItems = urlComponents.queryItems ?? []

        print("[UniversalLink] url.pathComponents", url.pathComponents)
        print("[UniversalLink] queryItems", queryItems)

        switch url.pathComponents {
        case ["/"]:
            state.updateHomeState {
                $0.current = nil
            }
            state.currentTabID = .home

        case ["/", "counter"]:
            let count = queryItems.first(where: { $0.name == "count" })
                .flatMap { $0.value }
                .flatMap(Int.init) ?? 0

            state.updateHomeState {
                $0.current = .counter(.init(count: count))
            }
            state.currentTabID = .home

        case ["/", "physics"]:
            state.updateHomeState {
                $0.current = .physics(.init(current: nil))
            }
            state.currentTabID = .home

        case ["/", "physics", "gravity-universe"]:
            state.updateHomeState {
                $0.current = .physics(.gravityUniverse)
            }
            state.currentTabID = .home

        case ["/", "tab"]:
            guard !state.tabs.isEmpty else { break }

            let index_ = queryItems.first(where: { $0.name == "index" })
                .flatMap { $0.value }
                .flatMap(Int.init)

            guard let index = index_ else { break }

            let adjustedIndex = min(max(index, 0), state.tabs.count - 1)
            state.currentTabID = state.tabs[adjustedIndex].id

        default:
            break
        }

        return .empty
    }
}
