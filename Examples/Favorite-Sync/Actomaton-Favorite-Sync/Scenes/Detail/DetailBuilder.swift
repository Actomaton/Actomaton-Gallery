import UIKit
import ActomatonStore

@MainActor
public enum DetailBuilder
{
    static func build(card: CardWithFavorite, environment: Detail._Environment) -> UIViewController
    {
        let store = RouteStore(
            state: Detail.State(card: card),
            reducer: Detail.reducer(),
            environment: environment,
            routeType: Detail.Route.self
        )

        let vc = HostingViewController(store: store, makeView: DetailView.init)
        vc.title = "Detail"

        return vc
    }
}
