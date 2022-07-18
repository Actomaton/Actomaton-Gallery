import AVFoundation
import SwiftUI
import ActomatonUI
import VideoPlayer

@MainActor
public struct VideoPlayerMultiView: View
{
    private let store: Store<Action, State, Environment>

    @ObservedObject
    private var viewStore: ViewStore<Action, State>

    @SwiftUI.State
    private var isInitial: Bool = true

    public init(store: Store<Action, State, Environment>)
    {
        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let childStore1 = store
            .map(state: \.videoPlayer1)
            .contramap(action: Action.videoPlayer1)
            .map(environment: \.videoPlayer1)

        let childStore2 = store
            .map(state: \.videoPlayer2)
            .contramap(action: Action.videoPlayer2)
            .map(environment: { () -> (Environment) -> VideoPlayer.Environment in
                switch viewStore.displayMode {
                case .singleSyncedPlayer:
                    return \.videoPlayer1
                case .multiplePlayers:
                    return \.videoPlayer2
                }
            }())

        VStack(spacing: 16) {
            Picker("", selection: viewStore.directBinding.displayMode) {
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
        .onChange(of: viewStore.displayMode) { _ in
            // Re-subscribe each player on `displayMode` changes.
            childStore1.send(.subscribePlayer)
            childStore2.send(.subscribePlayer)
        }
    }

    @ViewBuilder
    private func videoPlayerView(
        childStore: Store<VideoPlayer.Action, VideoPlayer.State, VideoPlayer.Environment>
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

// MARK: - Preview

public struct VideoPlayerMultiView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: Environment, isMultipleScreens: Bool) -> some View
    {
        let store = Store<Action, State, Environment>(
            state: State(displayMode: .multiplePlayers),
            reducer: reducer,
            environment: environment
        )

        VideoPlayerMultiView(store: store)
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                description: "description",
                videoPlayer1: .init(
                    getPlayer: { nil },
                    setPlayer: { _ in }
                ),
                videoPlayer2: .init(
                    getPlayer: { nil },
                    setPlayer: { _ in }
                )
            ),
            isMultipleScreens: true
        )
    }
}

// MARK: - Private

private func makePlayer() -> AVPlayer {
    let urlString = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
    let player = AVPlayer(url: URL(string: urlString)!)
    return player
}
