import UIKit
import ActomatonUI

// MARK: - Action

public enum Action: Sendable
{
    case requestImage(url: URL)
    case _cacheImage(url: URL, image: UIImage)
    case cancelRequest(url: URL)
    case removeImage(url: URL)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public var images: [URL: UIImage] = [:]
    public var isRequesting: [URL: Bool] = [:]

    public init() {}
}

// MARK: - Environment

public struct Environment: Sendable
{
    let fetchImage: @Sendable (URL) async -> UIImage?

    public init(fetchImage: @escaping @Sendable (URL) async -> UIImage?)
    {
        self.fetchImage = fetchImage
    }
}

// MARK: - EffectID

public struct ImageEffectID: EffectIDProtocol {}

public struct ImageEffectQueue: Oldest1SuspendNewEffectQueueProtocol {}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .init { action, state, environment in
        switch action {
        case let .requestImage(url):
            // Skip if there is already cached image.
            if state.images[url] != nil { return .empty }

            if !state.isRequesting[url, default: false] {
                state.isRequesting[url] = true

                // Fetch & cache image.
                return Effect(id: ImageEffectID(), queue: ImageEffectQueue()) {
                    // Slight delay to simulate the network delay.
                    try await Task.sleep(nanoseconds: 300_000_000)

                    guard let image = await environment.fetchImage(url) else {
                        return nil
                    }

                    return ._cacheImage(url: url, image: image)
                }
            }
            else {
                return .empty
            }

        case let ._cacheImage(url, image):
            state.isRequesting[url] = false
            state.images[url] = image

        case let .cancelRequest(url):
            state.isRequesting[url] = false
            return Effect.cancel(id: ImageEffectID())

        case let .removeImage(url):
            state.images[url] = .none
        }

        return .empty
    }
}

public struct Request
{
    public let url: URL
}

public struct Response
{
    public let image: UIImage
}

// MARK: - @unchecked Sendable

// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.
extension URL: @unchecked Sendable {}
extension UIImage: @unchecked Sendable {}
