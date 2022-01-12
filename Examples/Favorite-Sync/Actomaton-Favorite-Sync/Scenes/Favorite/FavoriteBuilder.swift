import UIKit
import ActomatonStore

@MainActor
public enum FavoriteBuilder
{
    static func buildNavigation(
        environment: CardList._Environment,
        usesUIKit: Bool
    ) -> UIViewController
    {
        let store = RouteStore(
            state: CardList.State(showsFavoriteOnly: true),
            reducer: CardList.reducer(),
            environment: environment,
            routeType: CardList.Route.self
        )

        let vc = usesUIKit
            ? CardListViewController(store: store)
            : HostingViewController(store: store, makeView: CardListView.init)
        vc.title = "Favorite"
        vc.tabBarItem = UITabBarItem(
            title: "Favorite",
            image: UIImage(systemName: "star")!,
            selectedImage: UIImage(systemName: "star.fill")!
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
