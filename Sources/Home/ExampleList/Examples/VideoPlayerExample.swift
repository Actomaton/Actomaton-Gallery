import SwiftUI
import ActomatonUI
import VideoPlayer
import AVFoundation

struct VideoPlayerExample: Example
{
    var exampleIcon: Image { Image(systemName: "film") }

    var exampleInitialState: Home.State.Current
    {
        .videoPlayer(VideoPlayer.State(label: ""))
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>) -> AnyView
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
                        // Tear down synchronously: action route may not reach the
                        // reducer if the Store is being deallocated alongside the view.
                        store.environment.getPlayer()?.pause()
                        store.environment.setPlayer(nil)
                    }
            }
        )
    }
}

// MARK: - Private

private func makePlayer() -> AVPlayer {
    let urlString = "https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"
    let player = AVPlayer(url: URL(string: urlString)!)
    return player
}
