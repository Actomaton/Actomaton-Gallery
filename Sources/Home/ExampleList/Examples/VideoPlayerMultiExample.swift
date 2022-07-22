import SwiftUI
import ActomatonUI
import VideoPlayerMulti
import AVFoundation

struct VideoPlayerMultiExample: Example
{
    var exampleIcon: Image { Image(systemName: "film") }

    var exampleInitialState: Home.State.Current
    {
        .videoPlayerMulti(VideoPlayerMulti.State(displayMode: .singleSyncedPlayer))
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.videoPlayerMulti,
            statePath: /Home.State.Current.videoPlayerMulti,
            environment: { $0.videoPlayerMulti },
            makeView: VideoPlayerMultiView.init
        )
    }
}
