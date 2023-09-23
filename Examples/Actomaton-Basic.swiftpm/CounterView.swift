import SwiftUI
import ActomatonUI

@MainActor
struct CounterView: View
{
    private let store: Store<Action, State, Void>

    init(store: Store<Action, State, Void>)
    {
        self.store = store
    }

    var body: some View
    {
        WithViewStore(self.store) { viewStore in
            HStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button(action: { self.store.send(.decrement) }) {
                        Image(systemName: "minus.circle")
                    }

                    Text("\(viewStore.state.count)")
                        .frame(width: 100)

                    Button(action: { self.store.send(.increment) }) {
                        Image(systemName: "plus.circle")
                    }
                }
                .font(.system(size: 64))
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider
{
    static var previews: some View
    {
        CounterView(
            store: Store(state: State(count: 123), reducer: reducer())
        )
        .previewLayout(.sizeThatFits)
    }
}
