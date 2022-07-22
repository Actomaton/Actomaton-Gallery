import SwiftUI
import ActomatonUI

@MainActor
struct ExampleListView: View
{
    private let store: Store<ExampleList.Action, ExampleList.State, Void>

    init(store: Store<ExampleList.Action, ExampleList.State, Void>)
    {
        self.store = store
    }

    var body: some View
    {
        WithViewStore(store.indirectMap(state: \.examples), areStatesEqual: examplesAreEqual) { viewStore in
            VStack {
//                Button(action: { self.store.send(.debugIncrement) }) {
//                    Text("\(self.store.state.debugCount)")
//                }

                List(viewStore.state, id: \.exampleTitle) { example in
                    exampleButton(example)
                }
            }
        }
    }

    private func exampleButton(_ example: AnyExample) -> some View
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
                store: RouteStore(
                    state: ExampleList.State(examples: []),
                    reducer: ExampleList.reducer
                )
                .noEnvironment
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("ExampleList")

            ExampleListView(
                store: RouteStore(
                    state: ExampleList.State(examples: []),
                    reducer: ExampleList.reducer
                )
                .noEnvironment
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Intro")
        }
    }
}
