import UIKit
import ActomatonStore

@MainActor
public enum HomeBuilder
{
    static func buildNavigation(
        environment: CardList._Environment,
        usesUIKit: Bool
    ) -> UIViewController
    {
        let store = RouteStore(
            state: CardList.State(showsFavoriteOnly: false),
            reducer: CardList.reducer(),
            environment: environment,
            routeType: CardList.Route.self
        )

        let vc = usesUIKit
            ? CardListViewController(store: store)
            : HostingViewController(store: store, makeView: CardListView.init)
        vc.title = "Home"
        vc.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house")!,
            selectedImage: UIImage(systemName: "house.fill")!
        )

        let navC = UINavigationController(rootViewController: vc)

        store.subscribeRoutes { [weak navC] route in
            print("===> route", route)
            switch route {
            case let .showDetail(card):
                let vc = DetailBuilder.build(
                    card: card,
                    environment: .init(
                        cardStore: environment.cardStore,
                        favoriteStore: environment.favoriteStore,
                        sleep: environment.sleep
                    ),
                    usesUIKit: usesUIKit
                )
                navC?.pushViewController(vc, animated: true)
            }
        }

        return navC
    }
}
