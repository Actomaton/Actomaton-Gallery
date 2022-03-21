import AVFoundation
import SwiftUI
import AVKit
import ActomatonStore

@MainActor
public struct VideoPlayerView: View
{
    private let store: Store<Action, State, Environment>.Proxy

    public init(store: Store<Action, State, Environment>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
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

            if store.state.playingStatus == .paused || store.state.playingStatus == .unknown {
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
