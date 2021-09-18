import SwiftUI
import ActomatonStore

@MainActor
struct RootView: View
{
    private let store: Store<Root.Action, Root.State>.Proxy

    init(store: Store<Root.Action, Root.State>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        VStack {
//            Button(action: { self.store.send(.debugIncrement) }) {
//                Text("\(self.store.state.debugCount)")
//            }

            List(self.store.state.examples, id: \.exampleTitle) { example in
                exampleButton(example)
            }
        }
    }

    private func exampleButton(_ example: Example) -> some View
    {
        Button(action: { self.store.send(.showExample(example)) }) {
            HStack(alignment: .firstTextBaseline) {
                example.exampleIcon
                    .frame(width: 44)
                Text(example.exampleTitle)
            }
            .font(.body)
            .padding(5)
            .foregroundColor(.black)
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
                    state: .constant(Root.State(examples: [])),
                    send: { _ in }
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Root")

            RootView(
                store: .init(
                    state: .constant(Root.State(examples: [])),
                    send: { _ in }
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Intro")
        }
    }
}
