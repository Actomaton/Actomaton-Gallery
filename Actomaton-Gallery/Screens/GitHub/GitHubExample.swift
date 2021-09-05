import SwiftUI
import ActomatonStore

struct GitHubExample: Example
{
    var exampleIcon: Image { Image(systemName: "g.circle.fill") }

    var exampleInitialState: Root.State.Current
    {
        .github(GitHub.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        guard let currentBinding = Binding(store.$state.current),
            let stateBinding = Binding(currentBinding.github) else
        {
            return EmptyView().toAnyView()
        }

        let substore = Store<GitHub.Action, GitHub.State>.Proxy(
            state: stateBinding,
            send: contramap(Root.Action.github)(store.send)
        )

        return GitHubView(store: substore).toAnyView()
    }
}
