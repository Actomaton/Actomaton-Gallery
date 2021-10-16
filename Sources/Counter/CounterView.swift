import SwiftUI
import ActomatonStore

@MainActor
public struct CounterView: View
{
    private let store: Store<Counter.Action, Counter.State>.Proxy

    public init(store: Store<Counter.Action, Counter.State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
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
            store: .init(
                state: .constant(.init()),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
