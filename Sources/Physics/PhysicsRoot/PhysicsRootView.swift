import SwiftUI
import ActomatonUI
import Utilities

@MainActor
public struct PhysicsRootView: View
{
    private let store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<PhysicsRoot.Action, PhysicsRoot.State>

    public init(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>)
    {
        self.store = store
        self.viewStore = store.viewStore
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
            isActive: viewStore
                .binding(get: \.current, onChange: PhysicsRoot.Action.changeCurrent)
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
            value: self.viewStore.binding(get: \.Δt, onChange: PhysicsRoot.Action.changeΔt),
            in: 0.01 ... 1,
            step: 0.01,
            label: {},
            minimumValueLabel: { Image(systemName: "tortoise") },
            maximumValueLabel: { Image(systemName: "hare") }
        )
            .padding(.horizontal)
    }

    private func withToolbarItems<Content: View>(_ content: Content) -> some View
    {
        content.toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Toggle(isOn: viewStore.directBinding.configuration.showsVelocityArrows) {
                    Image(systemName: "v.square")
                }
                Toggle(isOn: viewStore.directBinding.configuration.showsForceArrows) {
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

// MARK: - Preview

public struct PhysicsRootView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: PhysicsRoot.Environment, isMultipleScreens: Bool) -> some View
    {
        let physicsView = PhysicsRootView(
            store: Store<PhysicsRoot.Action, PhysicsRoot.State, PhysicsRoot.Environment>(
                state: .init(current: nil),
                reducer: PhysicsRoot.reducer,
                environment: environment
            )
            .noEnvironment
        )

        NavigationView {
            physicsView
                .previewDisplayName("Portrait")
//                .previewInterfaceOrientation(.portrait)
        }

        if isMultipleScreens {
//            NavigationView {
//                physicsView
//                    .previewDisplayName("Landscape")
//                    .previewInterfaceOrientation(.landscapeRight)
//            }
        }
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                timer: { _ in AsyncStream { nil } }
            ),
            isMultipleScreens: true
        )
    }
}
