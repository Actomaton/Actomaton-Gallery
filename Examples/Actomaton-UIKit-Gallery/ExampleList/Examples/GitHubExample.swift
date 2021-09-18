import SwiftUI
import ActomatonStore
import GitHub

struct GitHubExample: Example
{
    var exampleIcon: Image { Image(systemName: "g.circle.fill") }

    @MainActor
    func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(),
                reducer: GitHub.reducer,
                environment: .live
            ),
            makeView: GitHubView.init
        )
    }
}
