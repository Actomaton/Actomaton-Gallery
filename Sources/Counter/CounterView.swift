import SwiftUI
import ActomatonStore
import Utilities

@MainActor
public struct CounterView: View
{
    private let store: Store<Counter.Action, Counter.State, Void>.Proxy

    public init(store: Store<Counter.Action, Counter.State, Void>.Proxy)
    {
        let _ = Debug.print("CounterView.init")
        self.store = store
    }

    public var body: some View
    {
        let _ = Debug.print("CounterView.body")

        HStack(spacing: 20) {
            HStack(spacing: 20) {
                Button(action: { self.store.send(.decrement) }) {
                    Image(systemName: "minus.circle")
                }

                Text("\(store.state.count)")
                    .frame(width: 100)

                Button(action: { self.store.send(.increment) }) {
                    Image(systemName: "plus.circle")
                }
            }
            .font(.system(size: 64))
        }
    }
}

struct CounterView_Previews: PreviewProvider
{
    static var previews: some View
    {
        CounterView(
            store: .mock(
                state: .constant(.init()),
                environment: ()
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
