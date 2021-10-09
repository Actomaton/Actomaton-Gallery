import UIKit
import SwiftUI
import ActomatonStore

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

        let childVCs = tabItems.map { TabContentBuilder.build(tabItem: $0) }

        let tabC: UITabBarController = {
            let tabC = UITabBarController()
            tabC.viewControllers = childVCs
            return tabC
        }()

        return tabC
    }
}