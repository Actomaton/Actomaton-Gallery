import SwiftUI
import ActomatonStore
import GameOfLife

struct GameOfLifeExample: Example
{
    var exampleIcon: Image { Image(systemName: "checkmark.square") }

    @MainActor
    func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(pattern: .glider, cellLength: 5, timerInterval: 0.01),
                reducer: GameOfLife.Root.reducer(),
                environment: .live
            ),
            makeView: GameOfLife.RootView.init
        )
    }
}
