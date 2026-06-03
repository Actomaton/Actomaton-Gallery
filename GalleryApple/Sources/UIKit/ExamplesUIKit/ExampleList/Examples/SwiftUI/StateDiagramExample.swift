import SwiftUI
import StateDiagram
import StateDiagramUI
import ActomatonUI
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
            content: { StateDiagramView(store: $0) }
        )
    }
}
