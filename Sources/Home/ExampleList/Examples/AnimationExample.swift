import SwiftUI
import ActomatonStore
import AnimationDemo

struct AnimationExample: Example
{
    var exampleIcon: Image { Image(systemName: "pip.swap") }

    var exampleInitialState: Home.State.Current
    {
        .animationDemo(AnimationDemo.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.animationDemo,
            statePath: /Home.State.Current.animationDemo,
            makeView: {
                AnimationDemoView(
                    store: $0,
                    footnote: #"NOTE: This screen is placed inside SwiftUI NavigationView which causes animation not working properly. See "Animation" tab instead."#
                )
            }
        )
    }
}
