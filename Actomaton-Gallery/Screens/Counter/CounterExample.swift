import SwiftUI
import ActomatonStore

struct CounterExample: Example
{
    var exampleIcon: Image { Image(systemName: "goforward.plus") }

    var exampleInitialState: Root.State.Current
    {
        .counter(Counter.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        guard let currentBinding = Binding(store.$state.current),
            let stateBinding = Binding(currentBinding.counter) else
        {
            return EmptyView().toAnyView()
        }

        let substore = Store<Counter.Action, Counter.State>.Proxy(
            state: stateBinding,
            send: contramap(Root.Action.counter)(store.send)
        )

        return CounterView(store: substore).toAnyView()
    }
}
