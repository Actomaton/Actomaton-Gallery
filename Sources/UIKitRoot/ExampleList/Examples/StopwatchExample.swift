import SwiftUI
import ActomatonStore
import Stopwatch

struct StopwatchExample: Example
{
    var exampleIcon: Image { Image(systemName: "stopwatch") }

    @MainActor
    func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(),
                reducer: Stopwatch.reducer,
                environment: .live
            ),
            makeView: StopwatchView.init
        )
    }
}
