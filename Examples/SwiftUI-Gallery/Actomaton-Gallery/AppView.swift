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
import GameOfLife
import Physics

@MainActor
struct InjectedAppView: View
{
    @ObserveInjection var inject

    var body: some View
    {
        AppView()

//        RootView_Previews.makePreviews(state: .initialState, environment: .live, isMultipleScreens: false)
//        HomeView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//
//        ----------------------------------------
//        Per screen
//        ----------------------------------------
//        CounterView_Previews.previews
//        SyncCountersView_Previews.previews
//        AnimationDemoView_Previews.previews
//        ColorFilterView_Previews.previews
//        TodoView_Previews.previews
//        StateDiagramView_Previews.previews
//        StopwatchView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        HttpBinView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        GitHubView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        DownloaderView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        VideoPlayerView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        VideoPlayerMultiView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        VideoDetectorView_Previews.previews
//        GameOfLife_RootView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        PhysicsRootView_Previews.makePreviews(state: .doublePendulum, environment: .live, isMultipleScreens: false)
    }
}

/// Topmost container view of the app which holds `Store` as a single source of truth.
@MainActor
struct AppView: View
{
    private var store: Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>

    init()
    {
            let initialHomeState = Home.State(
//                current: .counter(.init(count: 0)),
//                current: .syncCounters(.init(common: .init(numberOfCounters: 1), counterState: .init(count: 0))),
//                current: .physics(.init(current: nil)),
//                current: .physics(.gravityUniverse),
//                current: .physics(.gravitySurface),
//                current: .physics(.collision),
//                current: .physics(.pendulum),
//                current: .physics(.doublePendulum),
//                current: .physics(.galtonBoard),
//                current: .gameOfLife(.init(pattern: .glider, cellLength: 5)),
//                current: .videoPlayerMulti(.init(displayMode: .singleSyncedPlayer)),

                current: nil,
                usesTimeTravel: true,
                isDebuggingTab: false
            )

        self.store = Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>(
            state: DebugRoot.State(inner: Root.State.initialState(homeState: initialHomeState)),
            reducer: DebugRoot.reducer(inner: Root.reducer()),
            environment: .live,
            configuration: {
#if DEBUG
                .init(logFormat: LogFormat()) // Set log-format to enable reducer-logging.
#else
                .init()
#endif
            }()
        )
    }

    var body: some View
    {
        DebugRootView<Root.RootView>(store: self.store)
    }
}

extension Root.RootView: RootViewProtocol {}

extension Root.State: RootStateProtocol
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
