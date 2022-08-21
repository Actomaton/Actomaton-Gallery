import SwiftUI
import ActomatonUI
import GameOfLife
import ExampleListUIKit
import LiveEnvironments

public struct GameOfLifeExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "checkmark.square") }

    @MainActor
    public func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(pattern: .glider, cellLength: 5, timerInterval: 0.05),
                reducer: GameOfLife.GameOfLifeRoot.reducer(),
                environment: .live
            )
            .noEnvironment,
            content: GameOfLife.RootView.init
        )
    }
}
