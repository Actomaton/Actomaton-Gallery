import SwiftUI
import ActomatonUI
import AnimationDemo

struct AnimationExample: Example
{
    var exampleIcon: Image { Image(systemName: "pip.swap") }

    var exampleInitialState: Home.State.Current
    {
        .animationDemo(AnimationDemo.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.animationDemo,
            statePath: /Home.State.Current.animationDemo,
            makeView: AnimationDemoView.init
        )
    }
}
