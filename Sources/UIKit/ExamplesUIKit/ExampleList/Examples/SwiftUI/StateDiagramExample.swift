import SwiftUI
import ActomatonUI
import StateDiagram
import ExampleListUIKit

public struct StateDiagramExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "arrow.3.trianglepath") }

    @MainActor
    public func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .loggedOut,
                reducer: StateDiagram.reducer,
                environment: ()
            ),
            makeView: StateDiagramView.init
        )
    }
}
