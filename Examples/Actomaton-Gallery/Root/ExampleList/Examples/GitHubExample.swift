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
        exampleView(
            store: store,
            actionPath: /Root.Action.github,
            statePath: \.github,
            makeView: GitHubView.init
        )
    }
}
