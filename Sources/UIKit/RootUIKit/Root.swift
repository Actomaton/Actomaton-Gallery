import UIKit
import SwiftUI
import Actomaton
import UserSession
import Login
import TabsUIKit

// MARK: - Action

public enum Action: Sendable
{
    case tab(TabsUIKit.Action<TabID>)

    case userSession(UserSession.Action)
    case loggedOut(Login.Action)

    // TODO:
//    case universalLink(URL)

    case didFinishOnboarding
    case resetOnboarding

    /// Inserts random tab by tab index.
    case insertRandomTab(index: Int)

    /// Removes tab by tab index.
    /// - Note: If `index = nil`, random tab index will be removed.
    case removeTab(index: Int?)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public var tab: TabsUIKit.State<TabID>

    public var userSession: UserSession.State
    {
        // NOTE: Uses `didSet` to also update Settings state.
        didSet {
            if let user = self.userSession.loggedInUser {
                self.tab.settings.user = user
            }
        }
    }

    public var isOnboardingComplete: Bool

    public init(
        tab: TabsUIKit.State<TabID>,
        userSession: UserSession.State,
        isOnboardingComplete: Bool
    )
    {
        self.tab = tab
        self.userSession = userSession
        self.isOnboardingComplete = isOnboardingComplete
    }
}

// MARK: - Environment

public struct Environment: Sendable
{
    /// - Note: View-traversal from root `window` is often needed for dirty hacks.
    public let window: UIWindow

    public init(
        window: UIWindow
    )
    {
        self.window = window
    }
}

// MARK: - Reducer

public func reducer() -> Reducer<Action, State, Environment>
{
    .combine(
        TabsUIKit.reducer()
            .contramap(action: /Action.tab)
            .contramap(state: \.tab)
            .contramap(environment: { _ in () }),

        UserSession.reducer
            .contramap(action: /Action.userSession)
            .contramap(state: \.userSession)
            .contramap(environment: { _ in () }),

        // TODO:
//        universalLinkReducer(),

        onboardingReducer(),
        loggedOutReducer,

        debugTabInsertRemoveReducer
    )
}

private func onboardingReducer() -> Reducer<Action, State, Environment>
{
    .init { action, state, environment in
        switch action {
        case .didFinishOnboarding:
            state.isOnboardingComplete = true

        case .resetOnboarding:
            state.isOnboardingComplete = false

        default:
            break
        }

        return .empty
    }
}

private var loggedOutReducer: Reducer<Action, State, Environment>
{
    .init { action, state, environment in
        guard case let .loggedOut(action) = action else { return .empty }

        switch action {
        case .login:
            return .nextAction(Action.userSession(.login))

        case .loginError:
            return .nextAction(Action.userSession(.loginError(.loginFailed)))

        case .onboarding:
            return .nextAction(.resetOnboarding)
        }
    }
}

private var debugTabInsertRemoveReducer: Reducer<Action, State, Environment>
{
    Reducer { action, state, environment in
        switch action {
        case let .insertRandomTab(index):
            return Effect { @MainActor in
                // Random alphabet "A" ... "Z".
                let char = (65 ... 90).map { String(UnicodeScalar($0)) }.randomElement()!

                return .tab(.insertTab(
                    TabsUIKit.TabItem(
                        id: .other(UUID()),
                        title: "Tab \(char)",
                        image: UIImage(systemName: "\(char.lowercased()).circle")!,
                        view: {
                            Text("Tab \(char)")
                        }
                    ),
                    index: index
                ))
            }

        case let .removeTab(index):
            guard !state.tab.tabs.isEmpty else { return .empty }

            // Always keep `TabID.settings`.
            if state.tab.tabs.count == TabID.protectedTabIDs.count {
                return .empty
            }

            let adjustedIndex: Int = {
                if let index = index {
                    return min(max(index, state.tab.tabs.count - 1), 0)
                }
                else {
                    return Int.random(in: 0 ..< state.tab.tabs.count)
                }
            }()

            let tabID = state.tab.tabs[adjustedIndex].id

            if TabID.protectedTabIDs.contains(tabID) {
                // Retry with same `removeTab` action with `index = nil` as random index.
                return .nextAction(.removeTab(index: nil))
            }

            return .nextAction(.tab(.removeTab(tabID)))

        default:
            return .empty
        }
    }
}
