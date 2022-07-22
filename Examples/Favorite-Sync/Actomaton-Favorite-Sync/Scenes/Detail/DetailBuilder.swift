import UIKit
import ActomatonUI

@MainActor
public enum DetailBuilder
{
    static func build(
        card: CardWithFavorite,
        environment: Detail._Environment,
        usesUIKit: Bool
    ) -> UIViewController
    {
        let store = RouteStore(
            state: Detail.State(card: card),
            reducer: Detail.reducer(),
            environment: environment,
            routeType: Detail.Route.self
        )

        let vc = usesUIKit
            ? DetailViewController(store: store)
            : HostingViewController.init(store: store.noEnvironment, content: DetailView.init)
        vc.title = "Detail"

        return vc
    }
}
