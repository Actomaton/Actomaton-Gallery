import ElementaryUI

@View
struct CounterPage
{
    @State var machine: CounterDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeCounterDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "Counter" }
            h2(.class("counter-heading")) { "Shared Reducer Demo" }
            p(.class("counter-copy")) {
                "This screen uses a demo-side @Reactive state object as MealyDriver state, "
                "while the transitions delegate to the shared Counter reducer."
            }

            div(.class("counter-card")) {
                p(.class("counter-value")) { "\(machine.state.counter.count)" }
                div(.class("counter-actions")) {
                    button(.type(.button), .class("counter-action")) { "−" }
                        .onClick { _ in
                            machine.send(.decrement)
                        }

                    button(.type(.button), .class("counter-action is-primary")) { "+" }
                        .onClick { _ in
                            machine.send(.increment)
                        }
                }
            }
        }
    }
}
