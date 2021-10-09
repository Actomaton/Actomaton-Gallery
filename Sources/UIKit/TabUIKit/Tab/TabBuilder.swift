import UIKit
import SwiftUI
import ActomatonStore
import ExampleListUIKit

public enum TabBuilder
{
    @MainActor
    public static func build() -> UIViewController
    {
        let tabItems: [TabItem] = [
            .init(
                title: "UIKit",
                image: UIImage(systemName: "applelogo")!,
                examples: [
                    CounterUIKitExample(),
                    CounterRouteUIKitExample(),
                ]
            ),
            .init(
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
            )
        ]

        let childVCs = tabItems.map { tabItem -> UIViewController in
            let vc = ExampleListBuilder.build(examples: tabItem.examples)
            vc.title = tabItem.title
            vc.tabBarItem = tabItem.tabBarItem

            let navC = UINavigationController(rootViewController: vc)
            navC.navigationBar.prefersLargeTitles = true
            return navC
        }

        let tabC: UITabBarController = {
            let tabC = UITabBarController()
            tabC.viewControllers = childVCs
            return tabC
        }()

        return tabC
    }
}
