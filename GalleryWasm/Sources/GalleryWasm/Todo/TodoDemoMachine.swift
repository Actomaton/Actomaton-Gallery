import Actomaton
import Todo
import Reactivity

@Reactive
final class TodoState
{
    var todo: Todo.State = .init()
}

typealias TodoDemoMachine = MealyDriver<Todo.Action, TodoState, Never>

func makeTodoDemoMachine(state: TodoState = TodoState()) -> TodoDemoMachine
{
    TodoDemoMachine(
        state: state,
        reducer: Todo.reducer
            .contramap(state: \TodoState.todo),
        environment: ()
    )
}
