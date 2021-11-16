import SwiftUI
import ActomatonStore

protocol Example
{
    var exampleTitle: String { get }
    var exampleIcon: Image { get }
    var exampleInitialState: Home.State.Current { get }

    @MainActor
    func exampleView(store: Store<Home.Action, Home.State>.Proxy) -> AnyView
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
    /// Helper method to transform parent `Store` into child `Store`, then `makeView`.
    @MainActor
    static func exampleView<ChildAction, ChildState, V: View>(
        store: Store<Home.Action, Home.State>.Proxy,
        action: @escaping (ChildAction) -> Home.Action,
        statePath: CasePath<Home.State.Current, ChildState>,
        makeView: @MainActor (Store<ChildAction, ChildState>.Proxy) -> V
    ) -> AnyView
    {
        @MainActor
        @ViewBuilder
        func _exampleView() -> some View
        {
            if let substore = store.current
                .traverse(\.self)?[casePath: statePath]
                .traverse(\.self)?
                .contramap(action: action)
            {
                makeView(substore)
            }
        }

        return AnyView(_exampleView())
    }
}
