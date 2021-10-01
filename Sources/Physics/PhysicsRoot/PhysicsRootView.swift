import SwiftUI
import ActomatonStore
import Utilities

@MainActor
public struct PhysicsRootView: View
{
    private let store: Store<PhysicsRoot.Action, PhysicsRoot.State>.Proxy

    public init(store: Store<PhysicsRoot.Action, PhysicsRoot.State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        Form {
            Section {
                List(worldExampleList, id: \.exampleTitle) { example in
                    navigationLink(example: example)
                }
            } header: {
                Text("Object World")
            } footer: {
                Text("Tap to add new. Drag to move.").font(.caption)
            }

            Section {
                List(pendulumObjectWorldExampleList, id: \.exampleTitle) { example in
                    navigationLink(example: example)
                }
            } header: {
                Text("Pendulum World")
            }
        }
        |> { self.withToolbarItems($0) }
    }

    private func navigationLink(example: Example) -> some View
    {
        NavigationLink(
            destination: example.exampleView(store: self.store)
                .navigationBarTitle(
                    "\(example.exampleTitle)",
                    displayMode: .inline
                )
                |> { self.withToolbarItems($0) },
            isActive: self.store.current
                .stateBinding(onChange: PhysicsRoot.Action.changeCurrent)
                .transform(
                    get: { $0?.example.exampleTitle == example.exampleTitle },
                    set: { _, isPresenting in
                        isPresenting ? example.exampleInitialState : nil
                    }
                )
        ) {
            HStack(alignment: .firstTextBaseline) {
                example.exampleIcon
                    .frame(width: 44)
                Text(example.exampleTitle)
            }
            .font(.body)
            .padding(5)
        }
    }

    @MainActor
    private func withToolbarItems<Content: View>(_ content: Content) -> some View
    {
        content.toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Toggle(isOn: store.configuration.showsVelocityArrows.directStateBinding) {
                    Image(systemName: "v.square")
                }
                Toggle(isOn: store.configuration.showsForceArrows.directStateBinding) {
                    Image(systemName: "f.square")
                }
            }
        }
    }
}
