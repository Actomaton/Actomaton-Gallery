import SwiftUI
import ActomatonUI
import Utilities

@MainActor
public struct AnimationDemoView: View
{
    private let store: Store<AnimationDemo.Action, AnimationDemo.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<AnimationDemo.Action, AnimationDemo.State>

    public init(
        store: Store<AnimationDemo.Action, AnimationDemo.State, Void>
    )
    {
        let _ = Debug.print("AnimationDemoView.init")

        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("AnimationDemoView.body")

        VStack {
            // Direct state binding + animation.
            Toggle("Toggle 1", isOn: viewStore.directBinding.isPresenting.animation())
                .frame(width: 200)

            // Indirect state binding + animation using `binding`.
            Toggle("Toggle 2", isOn: viewStore.binding(get: \.isPresenting, onChange: { _ in .tap }).animation())
                .frame(width: 200)

            // Manual action dispatch (send) + `withAnimation`.
            Button(viewStore.isPresenting ? "Hide" : "Show") {
                withAnimation() {
                    _ = self.store.send(.tap)
                }
            }
            .font(.largeTitle)

            if viewStore.isPresenting {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 200, height: 200)
                    .transition(.asymmetric(insertion: .scale, removal: .slide))
            }
        }
    }
}

public struct AnimationDemoView_Previews: PreviewProvider
{
    public static var previews: some View
    {
        AnimationDemoView(
            store: .init(
                state: .init(),
                reducer: AnimationDemo.reducer
            )
        )
    }
}
