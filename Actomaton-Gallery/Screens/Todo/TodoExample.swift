import SwiftUI
import ActomatonStore

struct TodoExample: Example
{
    var exampleIcon: Image { Image(systemName: "checkmark.square") }

    var exampleInitialState: Root.State.Current
    {
        .todo(Todo.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        guard let currentBinding = Binding(store.$state.current),
            let stateBinding = Binding(currentBinding.todo) else
        {
            return EmptyView().toAnyView()
        }

        let substore = Store<Todo.Action, Todo.State>.Proxy(
            state: stateBinding,
            send: contramap(Root.Action.todo)(store.send)
        )

        return TodoView(store: substore).toAnyView()
    }
}
