import SwiftUI
import Inject

@main
struct DemoApp: App
{
    /// Owned here (not in `AppView`) so it survives Inject hot-reload redraws.
    /// If the `Store` were constructed inside a view that `@ObserveInjection`
    /// re-renders, every code edit would tear down the old `Store` while its
    /// in-flight Actomaton effects were still running, racing into a crash.
    @State private var store = AppView.makeStore()

    var body: some Scene
    {
        WindowGroup {
            InjectedAppView(store: store)
        }
    }
}
