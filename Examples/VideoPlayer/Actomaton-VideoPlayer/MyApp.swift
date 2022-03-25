import AVFoundation
import SwiftUI
import UIKit
import ActomatonStore

@MainActor
@main
struct MyApp: App
{
    @StateObject
    private var store: Store<RootAction, RootState, RootEnvironment>

    init()
    {
        @MainActor
        class Player: Sendable {
            let avPlayer = AVPlayer()
        }

        let player = Player()

        self._store = StateObject(
            wrappedValue: Store(
                state: .init(),
                reducer: rootReducer(),
                environment: RootEnvironment(
                    getPlayer: { player.avPlayer },
                    getRandomVideoURL: { Constants.videoURLs.randomElement()! }
                )
            )
        )
    }

    var body: some Scene
    {
        WindowGroup {
            ZStack(alignment: .bottomTrailing) {
                RootView(store: store.proxy)
            }
        }
    }
}
