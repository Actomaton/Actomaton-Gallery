import SwiftUI
import ActomatonUI
import ColorFilterBindingUI

struct ColorFilterBindingExample: Example
{
    var exampleIcon: Image { Image(systemName: "paintpalette") }

    var exampleInitialState: Home.State.Current
    {
        .colorFilterBinding(ColorFilterBindingUI.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.colorFilterBinding,
            statePath: /Home.State.Current.colorFilterBinding,
            makeView: ColorFilterBindingView.init
        )
    }
}
