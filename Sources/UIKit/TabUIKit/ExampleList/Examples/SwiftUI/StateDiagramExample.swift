import SwiftUI
import ActomatonStore
import StateDiagram
import ExampleListUIKit

struct StateDiagramExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.3.trianglepath") }

    @MainActor
    func build() -> UIViewController
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
