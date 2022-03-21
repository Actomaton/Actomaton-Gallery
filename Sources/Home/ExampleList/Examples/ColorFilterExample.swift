import SwiftUI
import ActomatonStore
import ColorFilter

struct ColorFilterExample: Example
{
    var exampleIcon: Image { Image(systemName: "paintpalette") }

    var exampleInitialState: Home.State.Current
    {
        .colorFilter(ColorFilter.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.colorFilter,
            statePath: /Home.State.Current.colorFilter,
            makeView: ColorFilterView.init
        )
    }
}
