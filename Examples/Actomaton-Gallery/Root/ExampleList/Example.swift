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
    static func exampleView<ChildAction, ChildState, V: View>(
        store: Store<Root.Action, Root.State>.Proxy,
        actionPath: CasePath<Root.Action, ChildAction>,
        statePath: CasePath<Root.State.Current, ChildState>,
        makeView: (Store<ChildAction, ChildState>.Proxy) -> V
    ) -> AnyView
    {
        @ViewBuilder
        func _exampleView() -> some View
        {
            if let substore = store.current
                .sequence?[casePath: statePath]
                .sequence?
                .map(action: actionPath)
            {
                makeView(substore)
            }
        }

        return _exampleView().toAnyView()
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
