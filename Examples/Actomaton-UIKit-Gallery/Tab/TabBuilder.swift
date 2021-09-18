import UIKit
import SwiftUI
import ActomatonStore

enum TabBuilder
{
    @MainActor
    static func build() -> UIViewController
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
                    GameOfLifeExample()
                ]
            )
        ]

        let childVCs = tabItems.map { TabContentBuilder.build(tabItem: $0) }

        let tabC: UITabBarController = {
            let tabC = UITabBarController()
            tabC.viewControllers = childVCs
            return tabC
        }()

        return tabC
    }
}
