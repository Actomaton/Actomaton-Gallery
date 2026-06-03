import ElementaryUI

@View
struct HttpBinPage
{
    @State var machine: HttpBinDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeHttpBinDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "HttpBin" }
            h2(.class("counter-heading")) { "Real Network Fetch" }
            p(.class("counter-copy")) {
                "Tap Fetch to call GET https://httpbin.org/ip through the shared HttpBin reducer. "
                "The effect performs a genuine browser fetch via JavaScriptKit (CORS-permitted)."
            }

            div(.class("httpbin-controls")) {
                button(.type(.button), .class("counter-action is-primary")) { "Fetch" }
                    .onClick { _ in machine.send(.fetch) }
                button(.type(.button), .class("counter-action")) { "Cancel" }
                    .onClick { _ in machine.send(.cancel) }
            }

            div(.class("httpbin-result")) {
                if machine.state.httpBin.isLoading {
                    p(.class("httpbin-loading")) { "Loading…" }
                }
                else {
                    p(.class("httpbin-text")) { machine.state.httpBin.text }
                }
            }
        }
    }
}
