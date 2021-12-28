import UIKit
import Actomaton
import Utilities
import ImageLoader

// MARK: - Action

/// GitHub example namespace.
/// - Credit:
///   - https://github.com/marty-suzuki/GitHubSearchWithSwiftUI
///   - https://github.com/ra1028/SwiftUI-Combine

public enum Action
{
    case onAppear
    case updateSearchText(String)
    case _updateItems([Repository])
    case _showError(message: String)
    case tapRow(at: Int)
    case dismiss

    case _imageLoader(ImageLoader.Action)

    public init(response: SearchRepositoryResponse)
    {
        switch response.value {
        case let .left(items):
            self = ._updateItems(items)
        case let .right(error):
            self = ._showError(message: error.message)
        }
    }
}

// MARK: - State

public struct State: Equatable
{
    var searchText: String = "SwiftUI"

    var selectedIndex: Int? = nil

    var errorMessage: ErrorMessage? = nil

    fileprivate(set) var isLoading: Bool = false

    fileprivate(set) var items: [Repository] = []

    var imageLoader: ImageLoader.State = .init()

    var selectedWebURL: URL?
    {
        guard let selectedIndex = self.selectedIndex else { return nil }
        return self.items[selectedIndex].htmlUrl
    }

    var isWebViewPresented: Bool
    {
        get { self.selectedIndex != nil }
        set { self.selectedIndex = nil }
    }

    public init() {}

    struct ErrorMessage: Identifiable, Equatable
    {
        let message: String

        var id: String { self.message }
    }
}

// MARK: - Environment

public struct Environment
{
    let fetchRepositories: (_ searchText: String) async throws -> SearchRepositoryResponse
    let fetchImage: (URL) async -> UIImage?

    var searchRequestDelay: TimeInterval

    var imageLoadMaxConcurrency: Int

    public init(
        fetchRepositories: @escaping (_ searchText: String) async throws -> SearchRepositoryResponse,
        fetchImage: @escaping (URL) async -> UIImage?,
        searchRequestDelay: TimeInterval,
        imageLoadMaxConcurrency: Int
    )
    {
        self.fetchRepositories = fetchRepositories
        self.fetchImage = fetchImage
        self.searchRequestDelay = searchRequestDelay
        self.imageLoadMaxConcurrency = imageLoadMaxConcurrency
    }

    fileprivate func githubRequest(
        searchText: String
    ) -> Effect<Action>
    {
        guard !searchText.isEmpty else {
            return Effect.nextAction(Action._updateItems([]))
        }

        // Search request.
        return Effect(id: GitHubRequestID()) {
            // Sleep + EffectID auto-cancellation as debounce.
            try await Task.sleep(nanoseconds: UInt64(self.searchRequestDelay * TimeInterval(1_000_000_000)))

            if Task.isCancelled {
                print("fetch cancelled")
                return nil
            }

            do {
                print("start fetch!")
                let response = try await self.fetchRepositories(searchText)
                print("end fetch!")

                return Action(response: response)
            }
            catch {
                return Action._showError(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - EffectID

public struct GitHubRequestID: EffectIDProtocol {}

public func cancelAllEffectsPredicate(id: EffectID) -> Bool
{
    id is GitHubRequestID || id is ImageLoader.ImageEffectID
}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    let reducer = Reducer<Action, State, Environment> { action, state, environment in
        switch action {
        case .onAppear:
            state.isLoading = true
            return environment.githubRequest(searchText: state.searchText)

        case let .updateSearchText(text):
            state.searchText = text
            state.isLoading = !text.isEmpty
            return environment.githubRequest(searchText: state.searchText)

        case let ._updateItems(items):
            state.items = items
            state.isLoading = false

            guard !items.isEmpty else {
                return .empty
            }

            let imageURLs = items.map { $0.owner.avatarUrl }

            // FIXME: No lazy loading yet.
            return Effect.combine(imageURLs.map { .nextAction(._imageLoader(.requestImage(url: $0))) })

        case let ._showError(message):
            state.isLoading = false
            state.errorMessage = .init(message: message)

        case let .tapRow(index):
            state.selectedIndex = index

        case .dismiss:
            state.selectedIndex = nil

        case ._imageLoader:
            return .empty
        }

        return .empty
    }

    let imageLoaderReducer: Reducer<Action, State, Environment> = ImageLoader.reducer
        .contramap(action: /Action._imageLoader)
        .contramap(state: \.imageLoader)
        .contramap(environment: { .init(fetchImage: $0.fetchImage) })

    return reducer + imageLoaderReducer
}
