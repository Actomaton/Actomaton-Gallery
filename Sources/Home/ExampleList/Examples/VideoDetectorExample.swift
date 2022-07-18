import SwiftUI
import ActomatonUI
import VideoDetector

struct VideoDetectorExample: Example
{
    var exampleIcon: Image { Image(systemName: "video") }

    var exampleInitialState: Home.State.Current
    {
        .videoDetector(VideoDetector.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.videoDetector,
            statePath: /Home.State.Current.videoDetector,
            makeView: VideoDetectorView.init
        )
    }
}
