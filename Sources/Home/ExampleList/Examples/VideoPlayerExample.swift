import SwiftUI
import ActomatonStore
import VideoPlayer
import AVFoundation

struct VideoPlayerExample: Example
{
    var exampleIcon: Image { Image(systemName: "film") }

    var exampleInitialState: Home.State.Current
    {
        .videoPlayer(VideoPlayer.State(label: ""))
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.videoPlayer,
            statePath: /Home.State.Current.videoPlayer,
            environment: { $0.videoPlayer },
            makeView: { store in
                VideoPlayerView(store: store)
                    .onAppear {
                        store.environment.setPlayer(makePlayer())
                        store.send(.subscribePlayer)
                        store.send(.start)
                    }
                    .onDisappear {
                        store.send(.stop)
                    }
            }
        )
    }
}

// MARK: - Private

private func makePlayer() -> AVPlayer {
    let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    let player = AVPlayer(url: URL(string: urlString)!)
    return player
}
