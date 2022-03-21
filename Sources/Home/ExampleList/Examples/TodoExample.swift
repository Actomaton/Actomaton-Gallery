import SwiftUI
import ActomatonStore
import Todo

struct TodoExample: Example
{
    var exampleIcon: Image { Image(systemName: "checkmark.square") }

    var exampleInitialState: Home.State.Current
    {
        .todo(Todo.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.todo,
            statePath: /Home.State.Current.todo,
            makeView: TodoView.init
        )
    }
}
