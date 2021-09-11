import SwiftUI
import ActomatonStore

protocol Example
{
    var exampleTitle: String { get }
    var exampleIcon: Image { get }
    var exampleInitialState: Root.State.Current { get }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
}

extension Example
{
    var exampleTitle: String
    {
        let title = String(describing: self)
        if let index = title.range(of: "Example")?.lowerBound { // trim "-Example()"
            return String(title.prefix(upTo: index))
        }
        else {
            return title
        }
    }
}

extension Example
{
    func exampleView<ChildAction, ChildState, V: View>(
        store: Store<Root.Action, Root.State>.Proxy,
        actionPath: CasePath<Root.Action, ChildAction>,
        statePath: CasePath<Root.State.Current, ChildState>,
        makeView: (Store<ChildAction, ChildState>.Proxy) -> V
    ) -> AnyView
    {
        guard let currentBinding = Binding(store.$state.current),
              let stateBinding = Binding(currentBinding[casePath: statePath])
        else {
            return EmptyView().toAnyView()
        }

        let substore = Store<ChildAction, ChildState>.Proxy(
            state: stateBinding,
            send: { childAction in
                store.send(actionPath.embed(childAction))
            }
        )

        return makeView(substore).toAnyView()
    }
}

// MARK: - Private

extension View
{
    fileprivate func toAnyView() -> AnyView
    {
        AnyView(self)
    }
}
