import SwiftUI
import ActomatonStore
import Tab
import Home
import SettingsScene
import Counter
import Onboarding
import Login
import UserSession
import AnimationDemo

@MainActor
public struct RootView: View
{
    private let store: Store<Action, State, Environment>.Proxy

    public init(store: Store<Action, State, Environment>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        let isPresented = self.store.userSession.error
            .isPresented(onDismiss: Action.userSession(.forceLogout))

        if #available(iOS 15.0, *) {
            self.switchingView
                .alert(
                    "Force Logout",
                    isPresented: isPresented,
                    actions: {},
                    message: {
                        let msg = self.store.state.userSession.error?.localizedDescription ?? "Unknown error."
                        Text("\(msg)")
                    }
                )
        }
        else {
            self.switchingView
                .alert(isPresented: isPresented) {
                    Alert(
                        title: Text("Force Logout"),
                        dismissButton: .default(Text("OK"))
                    )
                }
        }
    }

    @ViewBuilder
    private var switchingView: some View
    {
        if !self.store.state.isOnboardingComplete {
            OnboardingView(
                isOnboardingComplete: self.store.isOnboardingComplete
                    .stateBinding(onChange: { $0 ? .didFinishOnboarding : nil })
            )
        }
        else {
            switch self.userSessionStore.state.authStatus {
            case .loggedOut:
                LoginView(onAction: { self.store.send(Action.loggedOut($0)) })

            case let .loggedIn(user):
                self.tabView(user: user)

            case .loggingIn:
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Logging in...")
                }

            case .loggingOut:
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Logging out...")
                }
            }
        }
    }

    // MARK: - Logged In

    /// Screen for logged-in users.
    @ViewBuilder
    private func tabView(user: User) -> some View
    {
        VStack {
            Tab.TabView(store: self.store.tab.contramap(action: Action.tab)) { tabID, childStore in
                if let childStore_ = childStore
                    .contramap(action: TabCaseAction.home)[casePath: /TabCaseState.home]
                    .traverse(\.self)
                {
                    HomeView(store: childStore_)
                }
                else if let childStore_ = childStore
                    .map(environment: { _ in () })
                    .contramap(action: TabCaseAction.settings)[casePath: /TabCaseState.settings]
                    .traverse(\.self)
                {
                    SettingsView(store: childStore_, usesNavigationView: true)
                }
                else if let childStore_ = childStore
                    .map(environment: { _ in () })
                    .contramap(action: TabCaseAction.counter)[casePath: /TabCaseState.counter]
                    .traverse(\.self)
                {
                    CounterView(store: childStore_)
                }
                else if let childStore_ = childStore
                            .map(environment: { _ in () })
                            .contramap(action: TabCaseAction.animationDemo)[casePath: /TabCaseState.animationDemo]
                            .traverse(\.self)
                {
                    AnimationDemoView(store: childStore_)
                }
                else {
                    Text("Should never reach here")
                }
            }

            if self.store.state.isDebuggingTab {
                self.tabDebugView()
            }
        }
        .onOpenURL { url in
            print("[openURL]", url)
            self.store.send(.universalLink(url))
        }
    }

    private func tabDebugView() -> some View
    {
        HStack {
            Text(Image(systemName: "sidebar.squares.left")).bold() + Text(" TAB").bold()
            Spacer()
            Button("Insert Tab") {
                self.store.send(.insertRandomTab(index: Int.random(in: 0 ... 4)))
            }
            Spacer()
            Button("Delete Tab") {
                self.store.send(.removeTab(index: Int.random(in: 0 ... 4)))
            }
            Spacer()
        }
        .padding()
    }

    // MARK: - SubStore

    private var userSessionStore: Store<UserSession.Action, UserSession.State, Environment>.Proxy
    {
        self.store.userSession.contramap(action: Action.userSession)
    }
}
