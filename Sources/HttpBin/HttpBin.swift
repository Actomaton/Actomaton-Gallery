import UIKit
import Actomaton
import Utilities
import ImageLoader

// MARK: - Action

/// Simple API request example using https://httpbin.org/ .
public enum Action: Sendable
{
    case fetch
    case cancel

    case _showText(String)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    var text: String
    var isLoading: Bool

    public init(text: String = "", isLoading: Bool = false)
    {
        self.text = text
        self.isLoading = isLoading
    }
}

// MARK: - Environment

public struct Environment: Sendable
{
    let fetch: @Sendable () async throws -> HttpBinResponse

    public init(
        fetch: @escaping @Sendable () async throws -> HttpBinResponse
    )
    {
        self.fetch = fetch
    }
}

// MARK: - EffectID

public struct HttpBinRequestID: EffectIDProtocol {}

public struct HttpBinRequestQueue: Oldest1DiscardNewEffectQueueProtocol {}

public func cancelAllEffectsPredicate(id: EffectID) -> Bool
{
    id.value is HttpBinRequestID
}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    Reducer<Action, State, Environment> { action, state, environment in
        switch action {

        case .fetch:
            state.isLoading = true

            return Effect(id: HttpBinRequestID(), queue: HttpBinRequestQueue()) {
                do {
                    let response = try await environment.fetch()
                    return ._showText("IP is \(response.origin)")
                }
                catch {
                    return ._showText(error.localizedDescription)
                }
            }

        case .cancel:
            state.isLoading = false
            return Effect.cancel(id: HttpBinRequestID())

        case let ._showText(text):
            state.isLoading = false
            state.text = text
            return .empty
        }
    }
}
