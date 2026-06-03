import Foundation
import Actomaton
import HttpBin
import Reactivity
import JavaScriptKit
import JavaScriptEventLoop

@Reactive
final class HttpBinState
{
    var httpBin: HttpBin.State = .init()
}

typealias HttpBinDemoMachine = MealyDriver<HttpBin.Action, HttpBinState, Never>

func makeHttpBinDemoMachine(state: HttpBinState = HttpBinState()) -> HttpBinDemoMachine
{
    HttpBinDemoMachine(
        state: state,
        reducer: HttpBin.reducer
            .contramap(state: \HttpBinState.httpBin),
        environment: HttpBin.Environment(fetch: browserFetch)
    )
}

/// Real browser `fetch` to `https://httpbin.org/ip` via JavaScriptKit, decoding the JSON with
/// `JSONDecoder` (httpbin.org sends `Access-Control-Allow-Origin: *`, so the browser allows it).
/// This is the first WASM example doing genuine network IO.
@Sendable
private func browserFetch() async throws -> HttpBin.HttpBinResponse
{
    // Artificial delay so the loading state is visible (WASM demo only).
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 sec

    let response = try await JSPromise(JSObject.global.fetch!("https://httpbin.org/ip").object!)!.value
    let textValue = try await JSPromise(response.object!.text!().object!)!.value
    let text = textValue.string ?? ""
    return try JSONDecoder().decode(HttpBin.HttpBinResponse.self, from: Data(text.utf8))
}
