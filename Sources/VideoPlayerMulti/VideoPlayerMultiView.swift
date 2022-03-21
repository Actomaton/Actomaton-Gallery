import AVFoundation
import SwiftUI
import ActomatonStore
import VideoPlayer

@MainActor
public struct VideoPlayerMultiView: View
{
    private let store: Store<Action, State, Environment>.Proxy

    @SwiftUI.State private var isInitial: Bool = true

    public init(store: Store<Action, State, Environment>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        let childStore1 = store.videoPlayer1
            .contramap(action: Action.videoPlayer1)
            .map(environment: \.videoPlayer1)

        let childStore2 = store.videoPlayer2
            .contramap(action: Action.videoPlayer2)
            .map(environment: { () -> (Environment) -> VideoPlayer.Environment in
                switch store.state.displayMode {
                case .singleSyncedPlayer:
                    return \.videoPlayer1
                case .multiplePlayers:
                    return \.videoPlayer2
                }
            }())

        VStack(spacing: 16) {
            Picker("", selection: store.$state.displayMode) {
                Text("Single Synced Player")
                    .tag(State.DisplayMode.singleSyncedPlayer)
                Text("Multiple Players")
                    .tag(State.DisplayMode.multiplePlayers)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            videoPlayerView(childStore: childStore1)
            videoPlayerView(childStore: childStore2)
        }
        .onAppear {
            if isInitial {
                isInitial = false

                store.environment.videoPlayer1.setPlayer(makePlayer())
                store.environment.videoPlayer2.setPlayer(makePlayer())
            }
        }
        .onChange(of: store.state.displayMode) { _ in
            // Re-subscribe each player on `displayMode` changes.
            childStore1.send(.subscribePlayer)
            childStore2.send(.subscribePlayer)
        }
    }

    @ViewBuilder
    private func videoPlayerView(
        childStore: Store<VideoPlayer.Action, VideoPlayer.State, VideoPlayer.Environment>.Proxy
    ) -> some View
    {
        VideoPlayerView(store: childStore)
            .onAppear {
                childStore.send(.subscribePlayer)
                childStore.send(.start)
            }
            .onDisappear {
                childStore.send(.stop)
            }
    }
}

// MARK: - Private

private func makePlayer() -> AVPlayer {
    let urlString = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
    let player = AVPlayer(url: URL(string: urlString)!)
    return player
}
