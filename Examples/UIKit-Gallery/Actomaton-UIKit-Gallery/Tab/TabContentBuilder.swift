import UIKit
import SwiftUI
import ActomatonStore

enum TabContentBuilder
{
    @MainActor
    static func build(tabItem: TabItem) -> UIViewController
    {
        let rootStore = RouteStore(
            state: .init(examples: tabItem.examples),
            reducer: Root.reducer,
            environment: ()
        )

        let rootVC = HostingViewController(
            store: rootStore,
            makeView: RootView.init
        )

        //        let rootVC = CounterUIKitExample().build()

        rootVC.title = tabItem.title
        rootVC.tabBarItem = tabItem.tabBarItem

        let navC = UINavigationController(rootViewController: rootVC)
        navC.navigationBar.prefersLargeTitles = true

        rootStore.subscribeRoutes { route in
            print("===> route = \(route)", Thread.current)

            switch route {
            case let .showExample(example):
                let vc = example.build()
                vc.navigationItem.largeTitleDisplayMode = .never
                navC.pushViewController(vc, animated: true)
            }
        }

        return navC
    }
}
