import SwiftUI
import ActomatonUI
import GameOfLifeUI
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
                reducer: GameOfLifeUI.Root.reducer(),
                environment: .live
            )
            .noEnvironment,
            content: { GameOfLifeUI.RootView(store: $0) }
        )
    }
}
