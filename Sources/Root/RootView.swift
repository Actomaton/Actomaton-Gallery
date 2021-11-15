import SwiftUI
import ActomatonStore

@MainActor
public struct RootView: View
{
    private let store: Store<Action, State>.Proxy

    public init(store: Store<Action, State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        return VStack {
            NavigationView {
                List(exampleList, id: \.exampleTitle) { example in
                    navigationLink(example: example)
                }
                .navigationBarTitle(Text("🎭 Actomaton Gallery 🖼️"), displayMode: .large)
                .toolbar {
                    Toggle(isOn: store.usesTimeTravel.stateBinding(onChange: { .debugToggle($0) })) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            // IMPORTANT:
            // iOS 15's default `NavigationView` causes broken state management.
            // To workaround, `.navigationViewStyle(.stack)` is required.
            // https://github.com/inamiy/iOS15-SwiftUI-Navigation-Bug
            // https://twitter.com/chriseidhof/status/1441330150872735745
            .navigationViewStyle(.stack)
        }
        .onOpenURL { url in
            print("[openURL]", url)
            store.send(.universalLink(url))
        }
    }

    private func navigationLink(example: Example) -> some View
    {
        NavigationLink(
            destination: example.exampleView(store: self.store)
                .navigationBarTitle(
                    "\(example.exampleTitle)",
                    displayMode: .inline
                ),
            isActive: self.store.current
                .stateBinding(onChange: Action.changeCurrent)
                .transform(
                    get: { $0?.example.exampleTitle == example.exampleTitle },
                    set: { _, isPresenting in
                        isPresenting ? example.exampleInitialState : nil
                    }
                )
                // Comment-Out: `removeDuplictates()` introduced in #3 seems not needed in iOS 15.
                // https://github.com/inamiy/Harvest-SwiftUI-Gallery/pull/3
                //
                // Workaround for SwiftUI's duplicated `isPresenting = false` calls per 1 dismissal.
                // .removeDuplictates()
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
}

struct RootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        return Group {
            RootView(
                store: .init(
                    state: .constant(State(current: nil, usesTimeTravel: true)),
                    send: { _ in }
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Root")

            RootView(
                store: .init(
                    state: .constant(State(current: .counter(.init()), usesTimeTravel: true)),
                    send: { _ in }
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Intro")
        }
    }
}
