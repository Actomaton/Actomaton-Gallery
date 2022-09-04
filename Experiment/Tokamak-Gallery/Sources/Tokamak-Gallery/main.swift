import TokamakShim
import ActomatonUI
import Counter

@MainActor
struct TokamakApp: App
{
    var body: some Scene
    {
        WindowGroup("Tokamak App") {
            ContentView()
        }
    }
}

@MainActor
struct ContentView: View
{
    let store = Store<Counter.Action, Counter.State, Counter.Environment>(
        state: .init(),
        reducer: reducer
    )

    var body: some View
    {
        CounterView(store: store)
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
TokamakApp.main()
