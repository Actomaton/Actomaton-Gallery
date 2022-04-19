import SwiftUI
import ActomatonStore

@MainActor
struct ExampleListView: View
{
    private let store: Store<ExampleList.Action, ExampleList.State, Void>.Proxy

    init(store: Store<ExampleList.Action, ExampleList.State, Void>.Proxy)
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

struct ExampleListView_Previews: PreviewProvider
{
    static var previews: some View
    {
        return Group {
            ExampleListView(
                store: .mock(
                    state: .constant(ExampleList.State(examples: [])),
                    environment: ()
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("ExampleList")

            ExampleListView(
                store: .mock(
                    state: .constant(ExampleList.State(examples: [])),
                    environment: ()
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Intro")
        }
    }
}
