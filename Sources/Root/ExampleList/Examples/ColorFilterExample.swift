import SwiftUI
import ActomatonStore
import ColorFilter

struct ColorFilterExample: Example
{
    var exampleIcon: Image { Image(systemName: "paintpalette") }

    var exampleInitialState: Root.State.Current
    {
        .colorFilter(ColorFilter.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Root.Action.colorFilter,
            statePath: /Root.State.Current.colorFilter,
            makeView: ColorFilterView.init
        )
    }
}
