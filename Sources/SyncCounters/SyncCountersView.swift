import SwiftUI
import ActomatonStore
import Counter

public struct SyncCountersView: View
{
    private let store: Store<SyncCounters.Action, SyncCounters.State>.Proxy

    public init(store: Store<SyncCounters.Action, SyncCounters.State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        VStack {
            ForEach(Array(store.state.children.enumerated()), id: \.element) { i, child in
                let childStore = store.children[i].counterState.contramap(action: SyncCounters.Action.child)

                CounterView(store: childStore)
                Text("Counter \(i)")
            }

            Spacer()

            HStack {
                Spacer()

                Button(action: { store.send(.addChild) }) {
                    Text("Add")
                }
                .disabled(!store.state.canAddChild)

                Spacer(minLength: 20)

                Button(action: { store.send(.removeChild) }) {
                    Text("Remove")
                }
                .disabled(!store.state.canRemoveChild)

                Spacer()
            }
            .font(.title)
        }
    }
}

struct SyncCountersView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SyncCountersView(
            store: .init(
                state: .constant(.init()),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
