import SwiftUI
import ActomatonUI
import Todo
import ExampleListUIKit

public struct TodoExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "checkmark.square") }

    @MainActor
    public func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(),
                reducer: Todo.reducer,
                environment: ()
            ),
            content: TodoView.init
        )
    }
}
