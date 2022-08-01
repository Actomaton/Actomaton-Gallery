import SwiftUI
import ActomatonUI
import HttpBin

struct HttpBinExample: Example
{
    var exampleIcon: Image { Image(systemName: "h.circle.fill") }

    var exampleInitialState: Home.State.Current
    {
        .httpbin(HttpBin.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.httpbin,
            statePath: /Home.State.Current.httpbin,
            makeView: HttpBinView.init
        )
    }
}
