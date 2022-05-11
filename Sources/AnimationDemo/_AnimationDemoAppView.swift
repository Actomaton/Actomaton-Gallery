import SwiftUI
import ActomatonStore

@MainActor
public struct AnimationDemoAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(),
            reducer: reducer,
            environment: (),
            configuration: .init(updatesStateImmediately: true) // Required for animation.
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        AnimationDemoView(store: self.store.proxy)
    }
}
