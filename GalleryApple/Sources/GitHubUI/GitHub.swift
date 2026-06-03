import Foundation
import UIKit
import CommonInterfaces
import GitHub
import ImageLoader

// GitHub example = platform-agnostic `GitHub` (search) + Apple-only `ImageLoader` (avatar images).
// The module keeps the same public surface (`State`/`Action`/`Environment`/`reducer`/`cancelAllEffectsPredicate`)
// so `Home`/`LiveEnvironments` wiring is unchanged.

// MARK: - Action

public enum Action: Sendable
{
    case core(GitHub.Action)
    case imageLoader(ImageLoader.Action)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public var core: GitHub.State
    public var imageLoader: ImageLoader.State

    public init(
        core: GitHub.State = .init(),
        imageLoader: ImageLoader.State = .init()
    )
    {
        self.core = core
        self.imageLoader = imageLoader
    }
}

// MARK: - Environment

public struct Environment: Sendable
{
    let fetchRepositories: @Sendable (_ searchText: String) async throws -> SearchRepositoryResponse
    let fetchImage: @Sendable (URL) async -> UIImage?

    var searchRequestDelay: TimeInterval
    var imageLoadMaxConcurrency: Int

    public init(
        fetchRepositories: @Sendable @escaping (_ searchText: String) async throws -> SearchRepositoryResponse,
        fetchImage: @Sendable @escaping (URL) async -> UIImage?,
        searchRequestDelay: TimeInterval,
        imageLoadMaxConcurrency: Int
    )
    {
        self.fetchRepositories = fetchRepositories
        self.fetchImage = fetchImage
        self.searchRequestDelay = searchRequestDelay
        self.imageLoadMaxConcurrency = imageLoadMaxConcurrency
    }
}

// MARK: - EffectID

public func cancelAllEffectsPredicate(id: any EffectID) -> Bool
{
    GitHub.cancelAllEffectsPredicate(id: id) || id is ImageLoader.ImageEffectID
}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .combine(
        GitHub.reducer
            .contramap(action: /Action.core)
            .contramap(state: \State.core)
            .contramap(environment: {
                GitHub.Environment(
                    fetchRepositories: $0.fetchRepositories,
                    searchRequestDelay: $0.searchRequestDelay
                )
            }),

        // Glue: when the core publishes new items, kick off avatar image requests.
        Reducer<Action, State, Environment> { action, _, _ in
            guard case let .core(._updateItems(items)) = action, !items.isEmpty else {
                return .empty
            }
            let imageURLs = items.map { $0.owner.avatarUrl }
            return Effect.combine(imageURLs.map { Effect.next(action: Action.imageLoader(.requestImage(url: $0))) })
        },

        ImageLoader.reducer
            .contramap(action: /Action.imageLoader)
            .contramap(state: \State.imageLoader)
            .contramap(environment: { ImageLoader.Environment(fetchImage: $0.fetchImage) })
    )
}
