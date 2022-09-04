import TokamakShim
import ActomatonUI

@MainActor
public struct CounterView: View
{
    private let store: Store<Action, State, Void>

    @ObservedObject
    private var viewStore: ViewStore<Action, State>

    public init(store: Store<Action, State, Void>)
    {
        self.store = store
        self._viewStore = ObservedObject(wrappedValue: store.viewStore)
    }

    public var body: some View
    {
        HStack(spacing: 20) {
            Button(action: { self.store.send(.decrement) }) {
                Text("-")
            }

            Text("\(viewStore.count)")
                .font(Font.system(size: 64).monospacedDigit())
                .frame(minWidth: 100)

            Button(action: { self.store.send(.increment) }) {
                Text("+")
            }
        }
        .font(.system(size: 64))
    }
}

