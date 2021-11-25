import SwiftUI
import ActomatonStore
import GameOfLife
import ExampleListUIKit

public struct GameOfLifeExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "checkmark.square") }

    @MainActor
    public func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(pattern: .glider, cellLength: 5),
                reducer: GameOfLife.Root.reducer(),
                environment: .live
            ),
            makeView: GameOfLife.RootView.init
        )
    }
}
