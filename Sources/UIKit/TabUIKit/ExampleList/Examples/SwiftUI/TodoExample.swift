import SwiftUI
import ActomatonStore
import Todo
import ExampleListUIKit

struct TodoExample: Example
{
    var exampleIcon: Image { Image(systemName: "checkmark.square") }

    @MainActor
    func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(),
                reducer: Todo.reducer,
                environment: ()
            ),
            makeView: TodoView.init
        )
    }
}
