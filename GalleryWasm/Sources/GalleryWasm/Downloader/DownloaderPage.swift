import ElementaryUI

@View
struct DownloaderPage
{
    @State var machine: DownloaderDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeDownloaderDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "Downloader" }
            h2(.class("counter-heading")) { "Effect Queue + Cancellation" }
            p(.class("counter-copy")) {
                "Concurrent fake downloads driven by the shared Downloader reducer. Each item's "
                "progress comes from a browser-native Task.sleep AsyncStream effect; pause/resume/cancel "
                "exercise effect cancellation."
            }

            div(.class("dl-controls")) {
                button(.type(.button), .class("counter-action is-primary")) { "Download All" }
                    .onClick { _ in machine.send(.downloadAll) }
                button(.type(.button), .class("counter-action")) { "Cancel All" }
                    .onClick { _ in machine.send(.cancelAll) }
            }

            ul(.class("dl-list")) {
                for id in machine.state.downloader.runningTasks.keys.sorted() {
                    DownloaderRow(
                        id: id,
                        progress: machine.state.downloader.runningTasks[id, default: .waiting(progress: 0)].progressValue,
                        status: machine.state.downloader.runningTasks[id, default: .waiting(progress: 0)].description,
                        canRun: machine.state.downloader.runningTasks[id, default: .waiting(progress: 0)].canRun,
                        canPause: machine.state.downloader.runningTasks[id, default: .waiting(progress: 0)].canPause,
                        onRun: { machine.send(.resume(id: id)) },
                        onPause: { machine.send(.pause(id: id)) },
                        onCancel: { machine.send(.cancel(id: id)) }
                    )
                }
            }
        }
    }
}

@View
struct DownloaderRow
{
    var id: String
    var progress: Float
    var status: String
    var canRun: Bool
    var canPause: Bool
    var onRun: () -> Void
    var onPause: () -> Void
    var onCancel: () -> Void

    var body: some View
    {
        li(.class("dl-item")) {
            div(.class("dl-info")) {
                span(.class("dl-id")) { id }
                span(.class("dl-status")) { status }
            }

            div(.class("dl-bar")) {
                div(.class("dl-fill"), .custom(name: "style", value: "width: \(Int(progress * 100))%")) { "" }
            }

            div(.class("dl-actions")) {
                if canRun {
                    button(.type(.button), .class("dl-action")) { "▶" }
                        .onClick { _ in onRun() }
                }
                else if canPause {
                    button(.type(.button), .class("dl-action")) { "⏸" }
                        .onClick { _ in onPause() }
                }

                button(.type(.button), .class("dl-action")) { "✕" }
                    .onClick { _ in onCancel() }
            }
        }
    }
}
