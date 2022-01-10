import SwiftUI
import UIKit
import ActomatonStore

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            uiViewControllerToSwiftUI {
                let environment = CardList._Environment.live

                let childVCs: [UIViewController] = [
                    HomeBuilder.buildNavigation(environment: environment),
                    FavoriteBuilder.buildNavigation(environment: environment)
                ]

                let tabC = UITabBarController()
                tabC.setViewControllers(childVCs, animated: false)
                return tabC
            }
            .ignoresSafeArea()
        }
    }
}
