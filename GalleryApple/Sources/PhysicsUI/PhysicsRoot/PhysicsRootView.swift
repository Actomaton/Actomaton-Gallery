import SwiftUI
import ActomatonUI
import Utilities
import Physics

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
                    List(PhysicsExampleID.objectWorldExamples, id: \.self) { example in
                        navigationLink(example: example)
                    }
                } header: {
                    Text(PhysicsExampleSection.objectWorld.title)
                } footer: {
                    Text("Tap to add new. Drag to move.").font(.caption)
                }

                Section {
                    List(PhysicsExampleID.pendulumWorldExamples, id: \.self) { example in
                        navigationLink(example: example)
                    }
                } header: {
                    Text(PhysicsExampleSection.pendulumWorld.title)
                }
            }
            |> { self.withToolbarItems($0) }


            Δt_slider
        }
    }

    private func navigationLink(example: PhysicsExampleID) -> some View
    {
        NavigationLink(
            destination: VStack {
                example.detailView(store: self.store)
                    .navigationBarTitle(
                        "\(example.title)",
                        displayMode: .inline
                    )
                |> { self.withToolbarItems($0) }

                Δt_slider
            },
            isActive: viewStore
                .binding(get: \.current, onChange: PhysicsRoot.Action.changeCurrent)
                .transform(
                    get: { $0?.exampleID == example },
                    set: { _, isPresenting in
                        isPresenting ? example.initialState : nil
                    }
                )
        ) {
            HStack(alignment: .firstTextBaseline) {
                example.exampleIcon
                    .frame(width: 44)
                Text(example.title)
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
    public static func makePreviews(
        state: PhysicsRoot.State = .init(current: nil),
        environment: PhysicsRoot.Environment,
        isMultipleScreens: Bool
    ) -> some View
    {
        let physicsView = PhysicsRootView(
            store: Store<PhysicsRoot.Action, PhysicsRoot.State, PhysicsRoot.Environment>(
                state: state,
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
