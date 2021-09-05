import SwiftUI
import ActomatonStore

struct RootView: View
{
    private let store: Store<Root.Action, Root.State>.Proxy

    init(store: Store<Root.Action, Root.State>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        return VStack {
            NavigationView {
                //
                // Comment-Out:
                // As of Xcode 12.3, `List` or `ForEach` iteration here will cause
                // `NavigationLink`'s destination view not get updated when its state changes
                // for some reason...
                //
//                List(allExamples, id: \.exampleTitle) { example in
//                    navigationLink(example: example)
//                }

                // To workaround this, create `NavigationLink` one by one. Doh.
                List {
                    navigationLink(example: allExamples[0])
                    navigationLink(example: allExamples[1])
                    navigationLink(example: allExamples[2])
                    navigationLink(example: allExamples[3])
                    navigationLink(example: allExamples[4])
                }
                .navigationBarTitle(Text("🎭 Actomaton Gallery 🖼️"), displayMode: .large)
            }
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
                .stateBinding(onChange: Root.Action.changeCurrent)
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
}

struct RootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        return Group {
            RootView(
                store: .init(
                    state: .constant(Root.State()),
                    send: { _ in }
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Root")

            RootView(
                store: .init(
                    state: .constant(Root.State(current: .counter(.init()))),
                    send: { _ in }
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Intro")
        }
    }
}
