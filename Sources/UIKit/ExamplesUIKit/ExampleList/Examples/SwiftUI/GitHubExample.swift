import SwiftUI
import ActomatonUI
import GitHub
import ExampleListUIKit
import LiveEnvironments

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
            )
            .noEnvironment,
            content: GitHubView.init
        )
    }
}
