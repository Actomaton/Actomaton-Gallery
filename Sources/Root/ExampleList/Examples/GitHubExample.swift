import SwiftUI
import ActomatonStore
import GitHub

struct GitHubExample: Example
{
    var exampleIcon: Image { Image(systemName: "g.circle.fill") }

    var exampleInitialState: Root.State.Current
    {
        .github(GitHub.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Root.Action.github,
            statePath: /Root.State.Current.github,
            makeView: GitHubView.init
        )
    }
}
