import UIKit
import ActomatonStore

@MainActor
public enum HomeBuilder
{
    static func buildNavigation(environment: CardList._Environment) -> UIViewController
    {
        let store = RouteStore(
            state: CardList.State(showsFavoriteOnly: false),
            reducer: CardList.reducer(),
            environment: environment,
            routeType: CardList.Route.self
        )

        let vc = HostingViewController(store: store, makeView: CardListView.init)
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
                    )
                )
                navC?.pushViewController(vc, animated: true)
            }
        }

        return navC
    }
}
