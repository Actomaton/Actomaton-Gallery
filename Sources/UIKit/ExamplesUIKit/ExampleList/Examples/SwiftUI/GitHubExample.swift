import SwiftUI
import ActomatonStore
import GitHub
import ExampleListUIKit

public struct GitHubExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "g.circle.fill") }

    @MainActor
    public func build() -> UIViewController
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
