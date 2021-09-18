import SwiftUI
import ActomatonStore
import Counter

struct CounterExample: Example
{
    var exampleIcon: Image { Image(systemName: "goforward.plus") }

    @MainActor
    func build() -> UIViewController
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
