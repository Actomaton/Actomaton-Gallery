import SwiftUI
import UserSession
import Tab
import Home

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
//                current: .videoPlayerMulti(.init(mode: .singleSyncedPlayer)),

                current: nil,
                usesTimeTravel: true,
                isDebuggingTab: false
            )
        }

        let user = User.makeSample()

        return State(
            tab: .init(
                tabs: [
                    Tab.TabItem(
                        id: .home,
                        inner: .home(initialHomeState),
                        tabItemTitle: "Home",
                        tabItemIcon: Image(systemName: "house")
                    ),
                    Tab.TabItem(
                        id: .animationDemo,
                        inner: .animationDemo(.init()),
                        tabItemTitle: "Animation",
                        tabItemIcon: Image(systemName: "pip.swap")
                    ),
                    Tab.TabItem(
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
