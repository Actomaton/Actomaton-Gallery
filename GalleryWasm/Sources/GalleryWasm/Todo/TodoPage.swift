import Foundation
import ElementaryUI

@View
struct TodoPage
{
    @State var machine: TodoDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeTodoDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "Todo" }
            h2(.class("counter-heading")) { "Shared Todo Demo" }
            p(.class("counter-copy")) {
                "Add, toggle, filter, and delete items. All transitions delegate to the "
                "shared Todo reducer."
            }

            div(.class("todo-input-row")) {
                input(.type(.text), .class("todo-input"), .placeholder("Add a TODO"))
                    .bindValue(
                        Binding(
                            get: { machine.state.todo.newText },
                            set: { machine.send(.updateNewText($0)) }
                        )
                    )

                button(.type(.button), .class("counter-action is-primary")) { "Add" }
                    .onClick { _ in
                        machine.send(.createTodo)
                    }
            }

            div(.class("todo-filters")) {
                button(.type(.button), .class(machine.state.todo.displayMode == .all ? "todo-filter is-selected" : "todo-filter")) { "All" }
                    .onClick { _ in machine.send(.updateDisplayMode(.all)) }
                button(.type(.button), .class(machine.state.todo.displayMode == .active ? "todo-filter is-selected" : "todo-filter")) { "Active" }
                    .onClick { _ in machine.send(.updateDisplayMode(.active)) }
                button(.type(.button), .class(machine.state.todo.displayMode == .completed ? "todo-filter is-selected" : "todo-filter")) { "Completed" }
                    .onClick { _ in machine.send(.updateDisplayMode(.completed)) }
            }

            ul(.class("todo-list")) {
                for index in machine.state.todo.visibleItems.indices {
                    TodoRow(
                        text: machine.state.todo.visibleItems[index].text,
                        isCompleted: machine.state.todo.visibleItems[index].isCompleted,
                        onToggle: { machine.send(.toggleCompleted(machine.state.todo.visibleItems[index].id)) },
                        onDelete: { machine.send(.delete(IndexSet(integer: index))) }
                    )
                }
            }
        }
    }
}

@View
struct TodoRow
{
    var text: String
    var isCompleted: Bool
    var onToggle: () -> Void
    var onDelete: () -> Void

    var body: some View
    {
        li(.class(isCompleted ? "todo-item is-done" : "todo-item")) {
            button(.type(.button), .class("todo-toggle")) { isCompleted ? "☑" : "☐" }
                .onClick { _ in onToggle() }

            span(.class("todo-text")) { text }

            button(.type(.button), .class("todo-delete")) { "✕" }
                .onClick { _ in onDelete() }
        }
    }
}
