import Foundation
import ElementaryUI

@View
struct StopwatchPage
{
    @State var machine: StopwatchDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeStopwatchDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "Stopwatch" }
            h2(.class("counter-heading")) { "Recurring Timer Effect" }
            p(.class("counter-copy")) {
                "Start the stopwatch to drive Stopwatch from a browser-native AsyncStream "
                "timer effect (Task.sleep), updating ~100 times per second."
            }

            div(.class("stopwatch-card")) {
                p(.class("stopwatch-time")) { timeString(machine.state.stopwatch.status.elapsedTime) }

                div(.class("stopwatch-actions")) {
                    if machine.state.stopwatch.status.isRunning {
                        button(.type(.button), .class("counter-action")) { "Lap" }
                            .onClick { _ in machine.send(.lap) }
                        button(.type(.button), .class("counter-action is-primary")) { "Stop" }
                            .onClick { _ in machine.send(.stop) }
                    }
                    else {
                        if machine.state.stopwatch.status.isPaused {
                            button(.type(.button), .class("counter-action")) { "Reset" }
                                .onClick { _ in machine.send(.reset) }
                        }
                        button(.type(.button), .class("counter-action is-primary")) { "Start" }
                            .onClick { _ in machine.send(.start) }
                    }
                }
            }

            ul(.class("stopwatch-laps")) {
                for index in machine.state.stopwatch.laps.indices.reversed() {
                    StopwatchLapRow(
                        label: "Lap \(machine.state.stopwatch.laps[index].id)",
                        time: timeString(machine.state.stopwatch.laps[index].time),
                        cssClass: lapClass(index)
                    )
                }
            }
        }
    }

    private func lapClass(_ index: Int) -> String
    {
        let lap = machine.state.stopwatch.laps[index]
        if lap.id == machine.state.stopwatch.fastestLapID { return "stopwatch-lap is-fastest" }
        if lap.id == machine.state.stopwatch.slowestLapID { return "stopwatch-lap is-slowest" }
        return "stopwatch-lap"
    }

    private func timeString(_ time: TimeInterval) -> String
    {
        let totalCentis = Int((time * 100).rounded())
        let centis = totalCentis % 100
        let totalSecs = totalCentis / 100
        let secs = totalSecs % 60
        let mins = totalSecs / 60
        return "\(pad2(mins)):\(pad2(secs)).\(pad2(centis))"
    }

    private func pad2(_ n: Int) -> String
    {
        n < 10 ? "0\(n)" : "\(n)"
    }
}

@View
struct StopwatchLapRow
{
    var label: String
    var time: String
    var cssClass: String

    var body: some View
    {
        li(.class(cssClass)) {
            span(.class("lap-id")) { label }
            span(.class("lap-time")) { time }
        }
    }
}
