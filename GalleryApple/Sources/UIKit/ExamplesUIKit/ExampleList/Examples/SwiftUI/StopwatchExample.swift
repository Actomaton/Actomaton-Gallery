import SwiftUI
import Stopwatch
import StopwatchUI
import ActomatonUI
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
            content: { StopwatchView(store: $0) }
        )
    }
}
