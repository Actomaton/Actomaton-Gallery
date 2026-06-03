import ElementaryUI

@View
struct SyncCountersPage
{
    @State var machine: SyncCountersDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeSyncCountersDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "SyncCounters" }
            h2(.class("counter-heading")) { "Reducer Composition Demo" }
            p(.class("counter-copy")) {
                "Add or remove counters. Every counter shares one Counter.State, "
                "so incrementing keeps them all in sync."
            }

            div(.class("sync-controls")) {
                button(.type(.button), .class("counter-action")) { "Remove" }
                    .onClick { _ in
                        machine.send(.removeChild)
                    }

                span(.class("sync-count-label")) {
                    "\(machine.state.syncCounters.common.numberOfCounters) counters"
                }

                button(.type(.button), .class("counter-action is-primary")) { "Add" }
                    .onClick { _ in
                        if machine.state.syncCounters.common.canAddChild {
                            machine.send(.addChild)
                        }
                    }
            }

            div(.class("sync-counters")) {
                for _ in 0 ..< machine.state.syncCounters.common.numberOfCounters {
                    SyncCounterRow(
                        value: machine.state.syncCounters.counterState.count,
                        onDecrement: { machine.send(.child(.decrement)) },
                        onIncrement: { machine.send(.child(.increment)) }
                    )
                }
            }
        }
    }
}

@View
struct SyncCounterRow
{
    var value: Int
    var onDecrement: () -> Void
    var onIncrement: () -> Void

    var body: some View
    {
        div(.class("sync-counter-card")) {
            button(.type(.button), .class("counter-action")) { "−" }
                .onClick { _ in onDecrement() }

            span(.class("sync-counter-value")) { "\(value)" }

            button(.type(.button), .class("counter-action is-primary")) { "+" }
                .onClick { _ in onIncrement() }
        }
    }
}
