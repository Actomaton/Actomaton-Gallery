import SwiftUI
import ActomatonStore

@MainActor
public struct AnimationDemoView: View
{
    private let store: Store<AnimationDemo.Action, AnimationDemo.State, Void>.Proxy
    private let footnote: String?

    public init(
        store: Store<AnimationDemo.Action, AnimationDemo.State, Void>.Proxy,
        footnote: String? = nil
    )
    {
        self.store = store
        self.footnote = footnote
    }

    public var body: some View
    {
        VStack {
            // Direct state binding + animation.
            Toggle("Toggle 1", isOn: store.$state.isPresenting.animation())
                .frame(width: 200)

            // Indirect state binding + animation using `stateBinding`.
            Toggle("Toggle 2", isOn: store.isPresenting.stateBinding(onChange: { _ in .tap }).animation())
                .frame(width: 200)

            // Manual action dispatch (send) + `withAnimation`.
            Button(store.state.isPresenting ? "Hide" : "Show") {
                withAnimation() {
                    _ = self.store.send(.tap)
                }
            }
            .font(.largeTitle)

            if store.state.isPresenting {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 200, height: 200)
                    .transition(.asymmetric(insertion: .scale, removal: .slide))
            }

            if let footnote = footnote {
                Spacer().frame(height: 100)

                Text(footnote)
            }
        }
    }
}

struct AnimationDemoView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AnimationDemoView(
            store: .init(
                state: .constant(.init()),
                environment: (),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
