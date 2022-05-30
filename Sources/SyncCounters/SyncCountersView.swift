import SwiftUI
import ActomatonStore
import Counter

@MainActor
public struct SyncCountersView: View
{
    private let store: Store<SyncCounters.Action, SyncCounters.State, Void>.Proxy

    public init(store: Store<SyncCounters.Action, SyncCounters.State, Void>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        VStack {
            ForEach(0 ..< store.state.numberOfCounters, id: \.self) { _ in
                CounterView(
                    store: store.commonCounterState
                        .contramap(action: SyncCounters.Action.child)
                )
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
            store: .mock(
                state: .constant(.init()),
                environment: ()
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
