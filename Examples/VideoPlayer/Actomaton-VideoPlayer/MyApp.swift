import AVFoundation
import SwiftUI
import UIKit
import ActomatonUI

@MainActor
@main
struct MyApp: App
{
    private let store: Store<RootAction, RootState, RootEnvironment>

    init()
    {
        @MainActor
        class Player: Sendable {
            let avPlayer = AVPlayer()
        }

        let player = Player()

        self.store = Store(
            state: .init(),
            reducer: rootReducer(),
            environment: RootEnvironment(
                getPlayer: { player.avPlayer },
//                testMode: .single(videoURL: {
//                    Constants.videoURLs.randomElement()!
//                })
                testMode: .composition(videoURLs: {
                    Array(Constants.shortVideoURLs.shuffled().prefix(2))
                })
            )
        )
    }

    var body: some Scene
    {
        WindowGroup {
            ZStack(alignment: .bottomTrailing) {
                RootView(store: store)
            }
        }
    }
}
