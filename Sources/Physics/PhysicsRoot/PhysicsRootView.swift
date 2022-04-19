import SwiftUI
import ActomatonStore
import Utilities

@MainActor
public struct PhysicsRootView: View
{
    private let store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>.Proxy

    public init(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        VStack {
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


            Δt_slider
        }
    }

    private func navigationLink(example: Example) -> some View
    {
        NavigationLink(
            destination: VStack {
                example.exampleView(store: self.store)
                    .navigationBarTitle(
                        "\(example.exampleTitle)",
                        displayMode: .inline
                    )
                |> { self.withToolbarItems($0) }

                Δt_slider
            },
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

    private var Δt_slider: some View
    {
        Slider(
            value: self.store.Δt.stateBinding(onChange: PhysicsRoot.Action.changeΔt),
            in: 0.01 ... 1,
            step: 0.01
        )
            .padding(.horizontal)
    }

    private func withToolbarItems<Content: View>(_ content: Content) -> some View
    {
        content.toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Toggle(isOn: store.configuration.showsVelocityArrows.$state) {
                    Image(systemName: "v.square")
                }
                Toggle(isOn: store.configuration.showsForceArrows.$state) {
                    Image(systemName: "f.square")
                }
            }

            // Broken Slider in toolbar : SwiftUI
            // https://www.reddit.com/r/SwiftUI/comments/jdn6di/broken_slider_in_toolbar/
//            ToolbarItemGroup(placement: .bottomBar) {
//                Δt_slider
//            }
        }
    }
}
