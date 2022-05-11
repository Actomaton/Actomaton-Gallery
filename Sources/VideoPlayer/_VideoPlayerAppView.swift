import SwiftUI
import AVFoundation
import ActomatonStore

@MainActor
public struct VideoPlayerAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(label: ""),
            reducer: reducer,
            environment: .live
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        VideoPlayerView(store: self.store.proxy)
            .onAppear {
                store.environment.setPlayer(makePlayer())
                store.send(.subscribePlayer)
                store.send(.start)
            }
    }
}

// MARK: - Environment.live

extension Environment
{
    public static var live: Environment
    {
        /// Effectful references.
        class Refs {
            var player: AVPlayer?
        }

        let refs = Refs()

        return .init(
            getPlayer: { refs.player },
            setPlayer: { refs.player = $0 }
        )
    }
}

// MARK: - Private

private func makePlayer() -> AVPlayer {
    let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    let player = AVPlayer(url: URL(string: urlString)!)
    return player
}
