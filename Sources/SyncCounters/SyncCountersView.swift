import SwiftUI
import ActomatonUI
import Counter
import Utilities

@MainActor
public struct SyncCountersView: View
{
    private let store: Store<SyncCounters.Action, SyncCounters.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<SyncCounters.Action, SyncCounters.State.Common>

    public init(store: Store<SyncCounters.Action, SyncCounters.State, Void>)
    {
        let _ = Debug.print("SyncCountersView.init")
        self.store = store
        self.viewStore = store.map(state: \.common).viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("SyncCountersView.body")

        VStack {
            ForEach(0 ..< viewStore.numberOfCounters, id: \.self) { _ in
                CounterView(
                    store: store.map(state: \.counterState)
                        .contramap(action: SyncCounters.Action.child)
                )
            }

            Spacer()

            HStack {
                Spacer()

                Button(action: { store.send(.addChild) }) {
                    Text("Add")
                }
                .disabled(!viewStore.canAddChild)

                Spacer(minLength: 20)

                Button(action: { store.send(.removeChild) }) {
                    Text("Remove")
                }
                .disabled(!viewStore.state.canRemoveChild)

                Spacer()
            }
            .font(.title)
        }
    }
}

public struct SyncCountersView_Previews: PreviewProvider
{
    public static var previews: some View
    {
        SyncCountersView(
            store: .init(
                state: .init(),
                reducer: SyncCounters.reducer
            )
        )
        .previewDisplayName("Initial")

        SyncCountersView(
            store: .init(
                state: .init(
                    common: .init(numberOfCounters: 3),
                    counterState: .init(count: 10)
                ),
                reducer: SyncCounters.reducer
            )
        )
        .previewDisplayName("numberOfCounters = 3")
    }
}
