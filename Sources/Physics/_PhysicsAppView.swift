import SwiftUI
import ActomatonStore
import CommonEffects

@MainActor
public struct PhysicsAppView: View
{
    @StateObject
    private var store: Store<PhysicsRoot.Action, PhysicsRoot.State, PhysicsRoot.Environment>

    public init()
    {
        let store = Store<PhysicsRoot.Action, PhysicsRoot.State, PhysicsRoot.Environment>(
            state: PhysicsRoot.State.collision,
            reducer: PhysicsRoot.reducer,
            environment: .live(commonEffects: .live)
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        NavigationView {
            PhysicsRootView(store: self.store.proxy.noEnvironment)
        }
    }
}

// MARK: - Environment.live

extension PhysicsRoot.Environment
{
    public static func live(commonEffects: CommonEffects) -> PhysicsRoot.Environment
    {
        PhysicsRoot.Environment(timer: commonEffects.timer)
    }
}
