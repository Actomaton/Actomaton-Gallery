import SwiftUI
import ActomatonUI
import GitHub

struct GitHubExample: Example
{
    var exampleIcon: Image { Image(systemName: "g.circle.fill") }

    var exampleInitialState: Home.State.Current
    {
        .github(GitHub.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.github,
            statePath: /Home.State.Current.github,
            makeView: GitHubView.init
        )
    }
}
