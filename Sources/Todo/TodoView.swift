import SwiftUI
import ActomatonUI
import Utilities

@MainActor
public struct TodoView: View
{
    private let store: Store<Todo.Action, Todo.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<Todo.Action, Todo.State>

    public init(store: Store<Todo.Action, Todo.State, Void>)
    {
        let _ = Debug.print("TodoView.init")

        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("TodoView.body")

        VStack {
            newItemTextField()

            Divider()

            List {
                ForEach(self.viewStore.visibleItems.indices, id: \.self) { index in
                    self.itemRow(at: index, isEditing: self.viewStore.isEditing)
                }
                .onDelete(perform: { self.store.send(.delete($0)) })
            }

            picker()
        }
        .navigationBarItems(
            trailing: Button(action: { self.store.send(.toggleEdit) }) {
                if self.viewStore.isEditing {
                    Text("Done")
                }
                else {
                    Text("Edit")
                }
            }
        )
    }

    private func newItemTextField() -> some View
    {
        HStack {
            Image(systemName: "square.and.pencil")
                .onTapGesture { self.store.send(.createTodo) }

            TextField(
                "Create a new TODO",

                // IMPORTANT:
                // Explicit subscript access helper is required to avoid
                // `SwiftUI.BindingOperations.ForceUnwrapping` failure crash.
                // This issue occurs when `TodoView` is navigation-poped.
                //text: self.store.$state[\.newText],

                // Or, use `binding(onChange:)` with providing an explicit next `Action`.
                // NOTE: This also allows to time-travel each character inputting.
                text: self.viewStore.binding(get: \.newText, onChange: Todo.Action.updateNewText),
                onCommit: { self.store.send(.createTodo) }
            )
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }

    private func itemRow(at visibleIndex: Int, isEditing: Bool) -> some View
    {
        let textBinding = self.viewStore
            .binding(
                get: { $0.visibleItems[visibleIndex] },
                onChange: { .updateText($0.id, $0.text) }
            )
            .text

        let item = self.viewStore.visibleItems[visibleIndex]

        return HStack {
            if isEditing {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .onTapGesture {
                        self.store.send(.delete([visibleIndex]))
                    }
            }
            else {
                self.checkbox(isCompleted: item.isCompleted)
                    .onTapGesture {
                        self.store.send(.toggleCompleted(item.id))
                }
            }

            TextField(
                item.text,
                text: textBinding,
                onCommit: { self.store.send(.updateText(item.id, item.text)) }
            )
        }
    }

    private func checkbox(isCompleted: Bool) -> some View
    {
        isCompleted
            ? Image(systemName: "checkmark.circle").foregroundColor(Color.green)
            : Image(systemName: "circle").foregroundColor(Color.gray)
    }

    private func picker() -> some View
    {
        let selection = self.viewStore
            .binding(get: \.displayMode, onChange: Todo.Action.updateDisplayMode)

        return Picker("Picker", selection: selection) {
            ForEach(Todo.DisplayMode.allCases, id: \.self) {
                Text(verbatim: "\($0)")
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

public struct TodoView_Previews: PreviewProvider
{
    public static var previews: some View
    {
        TodoView(
            store: .init(
                state: .init(),
                reducer: Todo.reducer
            )
        )
    }
}
