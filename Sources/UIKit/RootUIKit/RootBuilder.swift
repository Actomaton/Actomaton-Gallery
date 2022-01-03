import UIKit
import SwiftUI
import ActomatonStore
import UserSession
import TabUIKit
import ExampleListUIKit
import ExamplesUIKit
import SettingsScene
import SettingsUIKit

public enum RootBuilder
{
    @MainActor
    public static func build(
        environment: Environment
    ) -> UIViewController
    {
        let user = User.makeSample()
        weak var weakRootStore: Store<Action, State>?

        let tabItems: [TabItem<TabID>] = [
            TabItem(
                id: .uiKit,
                title: "UIKit",
                image: UIImage(systemName: "applelogo")!,
                examples: [
                    CounterUIKitExample(),
                    CounterRouteUIKitExample(),
                ]
            ),
            TabItem(
                id: .swiftUIHosting,
                title: "SwiftUI + Host",
                image: UIImage(systemName: "swift")!,
                examples: [
                    CounterExample(),
                    TodoExample(),
                    StateDiagramExample(),
                    StopwatchExample(),
                    GitHubExample(),
                    GameOfLifeExample(),
                    VideoDetectorExample(),
                    PhysicsExample()
                ]
            ),
            TabItem(
                id: .settings,
                title: "Settings",
                image: UIImage(systemName: "gear")!,
                build: {
                    guard let rootStore = weakRootStore else { fatalError() }

                    let user = rootStore.state.tab.settings.user

                    let settingsStore = RouteStore<SettingsScene.Action, SettingsScene.State, SettingsScene.Action>(
                        state: .init(user: user),
                        reducer: SettingsUIKit.reducer,
                        environment: ()
                    )

                    // IMPORTANT:
                    // This is where `settingsStore` (as `RouteStore`) converts `settingsStore`'s `Route`
                    // to `rootStore`'s `Action` and sends it to `rootStore`.
                    //
                    // NOTE:
                    // This impl (and `RouteStore`) may perhaps be improved by strictly re-defining `settingsStore`
                    // which is destructured from `rootStore` using `WritableKeyPath` and `CasePath` that is
                    // just same as SwiftUI demo app, which may be applicable in this UIKit demo too.
                    settingsStore.subscribeRoutes { route in
                        switch route {
                        case .logout:
                            rootStore.send(.userSession(.logout))
                        case .onboarding:
                            rootStore.send(.resetOnboarding)
                        case .insertTab:
                            let randomTabIndex = Int.random(in: 0 ... 4)
                            rootStore.send(.insertRandomTab(index: randomTabIndex))
                        case .removeTab:
                            let randomTabIndex = Int.random(in: 0 ... 4)
                            rootStore.send(.removeTab(index: randomTabIndex))
                        }
                    }

                    return HostingViewController(
                        store: settingsStore,
                        makeView: { store in
                            SettingsView(
                                store: store,
                                usesNavigationView: false
                            )
                        }
                    )
                }
            )
        ]

        let state = RootUIKit.State(
            tab: .init(
                tabs: tabItems,
                currentTabID: TabID.settings,
                settings: .init(user: user)
            ),
            userSession: .init(authStatus: .loggedIn(user)),
            isOnboardingComplete: true
        )

        let rootStore = Store<Action, State>(
            state: state,
            reducer: reducer(),
            environment: environment
        )
        weakRootStore = rootStore

        let rootVC = RootViewController(store: rootStore)
        return rootVC
    }
}

public enum AlertBuilder
{
    @MainActor
    public static func build(
        title: String? = nil,
        message: String? = nil,
        actions: [UIAlertAction] = []
    ) -> UIViewController
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            alert.addAction(action)
        }

        return alert
    }
}

