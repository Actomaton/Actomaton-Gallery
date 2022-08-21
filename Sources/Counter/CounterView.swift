import SwiftUI
import ActomatonUI
import Utilities

@MainActor
public struct CounterView: View
{
    private let store: Store<Counter.Action, Counter.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<Counter.Action, Counter.State>

    public init(store: Store<Counter.Action, Counter.State, Void>)
    {
        let _ = Debug.print("CounterView.init")
        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("CounterView.body")

        HStack(spacing: 20) {
            HStack(spacing: 20) {
                Button(action: { self.store.send(.decrement) }) {
                    Image(systemName: "minus.circle")
                }

                Text("\(viewStore.count)")
                    .font(Font.system(size: 64).monospacedDigit())
                    .frame(minWidth: 100)

                Button(action: { self.store.send(.increment) }) {
                    Image(systemName: "plus.circle")
                }
            }
            .font(.system(size: 64))
        }
    }
}

public struct CounterView_Previews: PreviewProvider
{
    public static var previews: some View
    {
        CounterView(
            store: .init(
                state: .init(count: 123),
                reducer: Counter.reducer
            )
        )
    }
}
