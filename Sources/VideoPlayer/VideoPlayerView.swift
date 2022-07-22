import AVFoundation
import SwiftUI
import AVKit
import ActomatonUI
import Utilities

@MainActor
public struct VideoPlayerView: View
{
    private let store: Store<Action, State, Environment>

    @ObservedObject
    private var viewStore: ViewStore<Action, State>

    public init(store: Store<Action, State, Environment>)
    {
        let _ = Debug.print("VideoPlayerView.init")

        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("VideoPlayerView.body")

        VStack(spacing: 16) {
            AVKit.VideoPlayer(player: store.environment.getPlayer())
                .background(Color.black)

            controlsView
        }
    }

    @ViewBuilder
    private var controlsView: some View
    {
        HStack(spacing: 16) {
            Button(action: { store.send(.backward(seconds: 5)) }) {
                Image(systemName: "gobackward.5")
            }

            if viewStore.playingStatus == .paused || viewStore.playingStatus == .unknown {
                Button(action: { store.send(.start) }) {
                    Image(systemName: "play.circle")
                }
            }
            else {
                Button(action: { store.send(.stop) }) {
                    Image(systemName: "pause.circle")
                }
            }

            Button(action: { store.send(.forward(seconds: 5)) }) {
                Image(systemName: "goforward.5")
            }
        }
        .font(.largeTitle)
    }
}

// MARK: - Preview

public struct VideoPlayerView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: Environment, isMultipleScreens: Bool) -> some View
    {
        let store = Store<Action, State, Environment>(
            state: .init(label: "label"),
            reducer: reducer,
            environment: environment
        )

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

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                getPlayer: { nil },
                setPlayer: { _ in }
            ),
            isMultipleScreens: true
        )
    }
}

private func makePlayer() -> AVPlayer
{
    let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    let player = AVPlayer(url: URL(string: urlString)!)
    return player
}
