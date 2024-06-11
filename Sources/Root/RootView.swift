import SwiftUI
import ActomatonUI
import Tabs
import Home
import SettingsScene
import Counter
import Onboarding
import Login
import UserSession
import AnimationDemo
import Utilities

@MainActor
public struct RootView: View
{
    private let store: Store<Action, State, Environment>

    public init(store: Store<Action, State, Environment>)
    {
        let _ = Debug.print("RootView.init")
        self.store = store
    }

    public var body: some View
    {
        let _ = Debug.print("RootView.body")

        WithViewStore(store.map(state: \.userSession.error)) { viewStore in
            let isPresented = viewStore
                .isPresented(onDismiss: Action.userSession(.forceLogout))

            if #available(iOS 15.0, *) {
                self.switchingView
                    .alert(
                        "Force Logout",
                        isPresented: isPresented,
                        actions: {},
                        message: {
                            let msg = viewStore.state?.localizedDescription ?? "Unknown error."
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
    }

    @ViewBuilder
    private var switchingView: some View
    {
        WithViewStore(store.map(state: \.isOnboardingComplete)) { viewStore in
            if !viewStore.state {
                OnboardingView(
                    isOnboardingComplete: viewStore
                        .binding(onChange: { $0 ? .didFinishOnboarding : nil })
                )
            }
            else {
                WithViewStore(userSessionStore.map(state: \.authStatus)) { viewStore in
                    switch viewStore.state {
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
        }
    }

    // MARK: - Logged In

    /// Screen for logged-in users.
    @ViewBuilder
    private func tabView(user: User) -> some View
    {
        VStack {
            Tabs.TabView(store: tabStore) { tabID, childStore in
                if let childStore_ = childStore
                    .contramap(action: TabCaseAction.home)
                    .caseMap(state: /TabCaseState.home)
                    .optionalize()
                {
                    HomeView(store: childStore_)
                }
                else if let childStore_ = childStore
                    .map(environment: { _ in () })
                    .contramap(action: TabCaseAction.settings)
                    .caseMap(state: /TabCaseState.settings)
                    .optionalize()
                {
                    SettingsView(store: childStore_, usesNavigationView: true)
                }
                else if let childStore_ = childStore
                    .map(environment: { _ in () })
                    .contramap(action: TabCaseAction.counter)
                    .caseMap(state: /TabCaseState.counter)
                    .optionalize()
                {
                    CounterView(store: childStore_)
                }
                else if let childStore_ = childStore
                    .map(environment: { _ in () })
                    .contramap(action: TabCaseAction.animationDemo)
                    .caseMap(state: /TabCaseState.animationDemo)
                    .optionalize()
                {
                    AnimationDemoView(store: childStore_)
                }
                else {
                    Text("Should never reach here")
                }
            }

            WithViewStore(store.indirectMap(state: \.isDebuggingTab)) { viewStore in
                if viewStore.state {
                    self.tabDebugView()
                }
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

    private var tabStore: Store<Tabs.Action<TabCaseAction, TabCaseState, TabID>, Tabs.State<TabCaseState, TabID>, Environment>
    {
        self.store
            .map(state: \.tab)
            .contramap(action: Action.tab)
    }

    private var userSessionStore: Store<UserSession.Action, UserSession.State, Environment>
    {
        self.store
            .map(state: \.userSession)
            .contramap(action: Action.userSession)
    }
}

// MARK: - Previews

public struct RootView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(
        state: State = .defaultInitialState,
        environment: Environment,
        isMultipleScreens: Bool
    ) -> some View
    {
        RootView(
            store: Store(
                state: state,
                reducer: Root.reducer(),
                environment: environment
            )
        )
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            state: .defaultInitialState,
            environment: .init(
                getDate: { Date() },
                timer: { _ in AsyncStream { nil } },
                fetchRequest: { _ in throw CancellationError() },
                stopwatch: .init(
                    getDate: { Date() },
                    timer: { _ in AsyncStream { nil } }
                ),
                httpbin: .init(
                    fetch: { throw CancellationError() }
                ),
                github: .init(
                    fetchRepositories: { _ in throw CancellationError() },
                    fetchImage: { _ in nil },
                    searchRequestDelay: 0.3,
                    imageLoadMaxConcurrency: 1
                ),
                downloader: .init(
                    download: { _, _ in AsyncStream { nil } }
                ),
                videoPlayer: .init(
                    getPlayer: { nil },
                    setPlayer: { _ in }
                ),
                videoPlayerMulti: .init(
                    description: "description",
                    videoPlayer1: .init(
                        getPlayer: { nil },
                        setPlayer: { _ in }
                    ),
                    videoPlayer2: .init(
                        getPlayer: { nil },
                        setPlayer: { _ in }
                    )
                ),
                gameOfLife: .init(
                    loadFavorites: { [] },
                    saveFavorites: { _ in },
                    loadPatterns: { [] },
                    parseRunLengthEncoded: { _ in .empty },
                    timer: { _ in AsyncStream { nil } }
                )
            ),
            isMultipleScreens: true
        )
    }
}

extension State
{
    /// App's initial state to quick start to the target screen (for debugging)
    public static var defaultInitialState: State
    {
        let user = User.makeSample()

        return State(
            tab: .init(
                tabs: [
                    Tabs.TabItem(
                        id: .home,
                        inner: .home(
                            Home.State(
                                current: nil,
                                usesTimeTravel: true,
                                isDebuggingTab: false
                            )
                        ),
                        tabItemTitle: "Home",
                        tabItemIcon: Image(systemName: "house")
                    ),
                    Tabs.TabItem(
                        id: .settings,
                        inner: .settings(.init(user: User.makeSample())),
                        tabItemTitle: "Settings",
                        tabItemIcon: Image(systemName: "gear")
                    ),
                ],
                currentTabID: .home
            ),
            userSession: .init(authStatus: .loggedIn(user)),
            isOnboardingComplete: true
        )
    }
}
