import SwiftUI
import ActomatonStore
import VideoDetector

struct VideoDetectorExample: Example
{
    var exampleIcon: Image { Image(systemName: "video") }

    var exampleInitialState: Root.State.Current
    {
        .videoDetector(VideoDetector.State())
    }

    func exampleView(store: Store<Root.Action, Root.State>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            actionPath: /Root.Action.videoDetector,
            statePath: /Root.State.Current.videoDetector,
            makeView: VideoDetectorView.init
        )
    }
}
