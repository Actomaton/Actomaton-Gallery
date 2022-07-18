import SwiftUI
import ActomatonUI
import Counter
import ExampleListUIKit

public struct CounterExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "goforward.plus") }

    @MainActor
    public func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(),
                reducer: Counter.reducer,
                environment: ()
            ),
            makeView: CounterView.init
        )
    }
}
