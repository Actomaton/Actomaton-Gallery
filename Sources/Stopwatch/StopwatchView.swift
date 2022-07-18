import SwiftUI
import ActomatonUI

@MainActor
public struct StopwatchView: View
{
    private let store: Store<Stopwatch.Action, Stopwatch.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<Stopwatch.Action, Stopwatch.State>

    public init(store: Store<Stopwatch.Action, Stopwatch.State, Void>)
    {
        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        VStack {
            largeTime()
            buttons()
            Divider()
            lapList()
        }
    }

    private func largeTime() -> some View
    {
        Text("\(self.viewStore.status.timeString)")
            //.font(.system(size: 64, design: .monospaced))
            .font(Font.system(size: 64).monospacedDigit())
            .padding(.horizontal)
            .padding(.vertical, 60)
    }

    private func buttons() -> some View
    {
        HStack {
            if self.viewStore.status.isRunning {
                Button(action: { self.store.send(.lap) }) {
                    Text("Lap").font(.title)
                }

                Spacer()

                Button(action: { self.store.send(.stop) }) {
                    Text("Stop").font(.title)
                }
            }
            else {
                if self.viewStore.status.isPaused {
                    Button(action: { self.store.send(.reset) }) {
                        Text("Reset").font(.title)
                    }
                }
                else { // isIdle
                    Button(action: {}) {
                        Text("Lap").font(.title).disabled(true)
                    }
                }

                Spacer()

                Button(action: { self.store.send(.start) }) {
                    Text("Start") // or Stop
                        .font(.title)
                }
            }
        }
        .padding(.horizontal)
    }

    private func lapList() -> some View
    {
        List(self.viewStore.laps.reversed()) { lap in
            HStack {
                Text("Lap \(lap.id)")
                    .font(Font.body.monospacedDigit())
                Spacer()
                Text("\(lap.timeString)")
                    .font(Font.body.monospacedDigit())
            }
            .foregroundColor(
                lap.id == self.viewStore.fastestLapID
                ? Color.green
                : lap.id == self.viewStore.slowestLapID
                ? Color.red
                : nil
            )
        }
    }
}

public struct StopwatchView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: Stopwatch.Environment, isMultipleScreens: Bool) -> some View
    {
        StopwatchView(
            store: Store(
                state: .init(
                    status: .idle,
                    laps: [
                        .init(id: 0, time: 0.01),
                        .init(id: 1, time: 0.5),
                        .init(id: 2, time: 1.0),
                    ]
                ),
                reducer: Stopwatch.reducer,
                environment: environment
            )
            .noEnvironment
        )
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: Environment(
                getDate: { Date.init(timeIntervalSince1970: 0) },
                timer: { _ in
                    AsyncStream(unfolding: { nil })
                }
            ),
            isMultipleScreens: true
        )
    }
}

// MARK: - Private

extension Stopwatch.State.Status
{
    var timeString: String
    {
        switch self {
        case .idle, .preparing:
            return DateUtil.timeString(time: 0)

        case let .running(time, start, current):
            return DateUtil.timeString(time: time + current.timeIntervalSince1970 - start.timeIntervalSince1970)

        case let .paused(time):
            return DateUtil.timeString(time: time)
        }
    }
}

extension Stopwatch.State.Lap
{
    var timeString: String
    {
        DateUtil.timeString(time: self.time)
    }
}
