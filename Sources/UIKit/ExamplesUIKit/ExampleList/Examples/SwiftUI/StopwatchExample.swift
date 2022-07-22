import SwiftUI
import ActomatonUI
import Stopwatch
import ExampleListUIKit

public struct StopwatchExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "stopwatch") }

    @MainActor
    public func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(),
                reducer: Stopwatch.reducer,
                environment: .live
            )
            .noEnvironment,
            content: StopwatchView.init
        )
    }
}
