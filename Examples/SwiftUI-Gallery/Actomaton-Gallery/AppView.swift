import SwiftUI
import ActomatonUI
import Tabs
import Home
import Root
import DebugRoot
import UserSession
import CommonEffects
import LiveEnvironments
import Inject

// Additional examples import.
import Counter
import SyncCounters
import AnimationDemo
import ColorFilter
import Todo
import StateDiagram
import Stopwatch
import HttpBin
import GitHub
import Downloader
import VideoPlayer
import VideoPlayerMulti
import VideoDetector
import ElemCellAutomaton
import GameOfLife
import Physics

/// Topmost container view of the app which holds `Store` as a single source of truth.
@MainActor
struct AppView: View
{
    let store: Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>

    var body: some View
    {
        DebugRootView<Root.RootView>(store: self.store)
    }

    static func makeStore() -> Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>
    {
        let initialHomeState = Home.State(
//            current: .counter(.init(count: 0)),
//            current: .syncCounters(.init(common: .init(numberOfCounters: 1), counterState: .init(count: 0))),
//            current: .physics(.init(current: nil)),
//            current: .physics(.gravityUniverse),
//            current: .physics(.gravitySurface),
//            current: .physics(.collision),
//            current: .physics(.pendulum),
//            current: .physics(.doublePendulum),
//            current: .physics(.galtonBoard),
//            current: .elemCellAutomaton(.init(pattern: .init(rule: 110), cellLength: 5, timerInterval: 0.05)),
//            current: .gameOfLife(.init(pattern: .glider, cellLength: 5, timerInterval: 0.05)),
//            current: .videoPlayerMulti(.init(displayMode: .singleSyncedPlayer)),

            current: nil,
            usesTimeTravel: true,
            isDebuggingTab: false
        )

        return Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>(
            state: DebugRoot.State(inner: Root.State.initialState(homeState: initialHomeState)),
            reducer: DebugRoot.reducer(inner: Root.reducer()),
            environment: .live,
            configuration: {
#if DEBUG && false
                .init(logFormat: LogFormat()) // Set log-format to enable reducer-logging.
#else
                .init()
#endif
            }()
        )
    }
}

extension Root.RootView: @retroactive RootViewProtocol {}

extension Root.State: @retroactive RootStateProtocol
{
    public var usesTimeTravel: Bool
    {
        self.homeState?.common.usesTimeTravel ?? false
    }
}

// MARK: - initialState

extension Root.State
{
    /// App's initial state to quick start to the target screen (for debugging)
    public static func initialState(homeState: Home.State) -> Root.State
    {
        let user = User.makeSample()

        return State(
            tab: .init(
                tabs: [
                    Tabs.TabItem(
                        id: .home,
                        inner: .home(homeState),
                        tabItemTitle: "Home",
                        tabItemIcon: Image(systemName: "house")
                    ),
//                    Tabs.TabItem(
//                        id: .animationDemo,
//                        inner: .animationDemo(.init()),
//                        tabItemTitle: "Animation",
//                        tabItemIcon: Image(systemName: "pip.swap")
//                    ),
                    Tabs.TabItem(
                        id: .settings,
                        inner: .settings(.init(user: user)),
                        tabItemTitle: "Settings",
                        tabItemIcon: Image(systemName: "gear")
                    ),
//                    counterTabItem(index: 0),
//                    counterTabItem(index: 1),
//                    counterTabItem(index: 2)
                ],
                currentTabID: .home
            ),
            userSession: .init(authStatus: .loggedIn(user)),
            isOnboardingComplete: true
        )
    }
}
