import SwiftUI
import ActomatonStore
import Todo

struct TodoExample: Example
{
    var exampleIcon: Image { Image(systemName: "checkmark.square") }

    var exampleInitialState: Root.State.Current
    {
        .todo(Todo.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        exampleView(
            store: store,
            actionPath: /Root.Action.todo,
            statePath: /Root.State.Current.todo,
            makeView: TodoView.init
        )
    }
}
