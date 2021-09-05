import UIKit
import Combine
import Actomaton

/// GitHub example namespace.
/// - Credit:
///   - https://github.com/marty-suzuki/GitHubSearchWithSwiftUI
///   - https://github.com/ra1028/SwiftUI-Combine
enum GitHub {}

extension GitHub
{
    enum Action
    {
        case onAppear
        case updateSearchText(String)
        case _updateItems([Repository])
        case _showError(message: String)
        case tapRow(at: Int)
        case dismiss

        case _imageLoader(ImageLoader.Action)

        init(response: SearchRepositoryResponse)
        {
            switch response.value {
            case let .left(items):
                self = ._updateItems(items)
            case let .right(error):
                self = ._showError(message: error.message)
            }
        }
    }

    struct State: Equatable
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

        struct ErrorMessage: Identifiable, Equatable
        {
            let message: String

            var id: String { self.message }
        }
    }

    static var reducer: Reducer<Action, State, Environment>
    {
        let reducer = Reducer<Action, State, Environment> { action, state, environment in
            switch action {
            case .onAppear:
                state.isLoading = true
                return githubRequest(text: state.searchText, environment: environment)

            case let .updateSearchText(text):
                state.searchText = text
                state.isLoading = !text.isEmpty
                return githubRequest(text: text, environment: environment)

            case let ._updateItems(items):
                state.items = items
                state.isLoading = false

                guard !items.isEmpty else {
                    return .empty
                }

                let imageURLs = items.map { $0.owner.avatarUrl }

                // FIXME: No lazy loading yet.
                return Publishers.Sequence(sequence: imageURLs)
                    .flatMap(maxPublishers: .max(environment.imageLoadMaxConcurrency)) {
                        Just(Action._imageLoader(.requestImage(url: $0)))
                    }
                    .mapError(absurd)
                    .toEffect()

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
            .contramap(environment: { ImageLoader.Environment(urlSession: $0.urlSession) })

        return reducer + imageLoaderReducer
    }

    private static func githubRequest(
        text: String,
        environment: Environment
    ) -> Effect<Action>
    {
        guard !text.isEmpty else {
            return Effect.nextAction(Action._updateItems([]))
        }

        var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: text)
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Search request.
        return Effect(id: GitHubRequestID()) {
            do {
                // Sleep + EffectID auto-cancellation as debounce.
                await Task.sleep(UInt64(environment.searchRequestDelay * TimeInterval(1_000_000_000)))

                if Task.isCancelled {
                    print("fetch cancelled")
                    return nil
                }

                print("start fetch!")
                let (data, _) = try await environment.urlSession.data(for: request)
                print("end fetch!")

                let response = try decoder.decode(SearchRepositoryResponse.self, from: data)
                return Action(response: response)
            }
            catch {
                return Action._showError(message: error.localizedDescription)
            }
        }
    }

    struct GitHubRequestID: EffectIDProtocol {}

    static func cancelAllEffectsPredicate(id: EffectID) -> Bool {
        id is GitHubRequestID || id is ImageLoader.ImageURLEffectID
    }

    struct Environment
    {
        let urlSession: URLSession

        var searchRequestDelay: TimeInterval

        var imageLoadMaxConcurrency: Int
    }
}

// MARK: - Data Models

extension GitHub
{
    struct Repository: Decodable, Identifiable, Equatable
    {
        let id: Int
        let fullName: String
        let description: String?
        let stargazersCount: Int
        let htmlUrl: URL
        let owner: Owner

        struct Owner: Decodable, Identifiable, Equatable
        {
            let id: Int
            let login: String
            let avatarUrl: URL
        }
    }

    /// Mainly for decoding 403 API limit error.
    struct Error: Swift.Error, Decodable
    {
        let message: String
    }

    struct SearchRepositoryResponse: Decodable
    {
        var value: Either<[Repository], GitHub.Error>

        init(from decoder: Decoder) throws
        {
            do {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.value = .left(try container.decode([Repository].self, forKey: .items))
            }
            catch {
                let container = try decoder.singleValueContainer()
                self.value = .right(try container.decode(GitHub.Error.self))
            }
        }

        private enum CodingKeys: CodingKey
        {
            case items
        }
    }
}

// MARK: - Enum Properties

extension GitHub.Action
{
    var onAppear: Void?
    {
        guard case .onAppear = self else { return nil }
        return ()
    }

    var updateSearchText: String?
    {
        get {
            guard case let .updateSearchText(value) = self else { return nil }
            return value
        }
        set {
            guard case .updateSearchText = self, let newValue = newValue else { return }
            self = .updateSearchText(newValue)
        }
    }

    var _updateItems: [GitHub.Repository]?
    {
        get {
            guard case let ._updateItems(value) = self else { return nil }
            return value
        }
        set {
            guard case ._updateItems = self, let newValue = newValue else { return }
            self = ._updateItems(newValue)
        }
    }

    var _showError: String?
    {
        get {
            guard case let ._showError(value) = self else { return nil }
            return value
        }
        set {
            guard case ._showError = self, let newValue = newValue else { return }
            self = ._showError(message: newValue)
        }
    }

    var tapRow: Int?
    {
        get {
            guard case let .tapRow(value) = self else { return nil }
            return value
        }
        set {
            guard case .tapRow = self, let newValue = newValue else { return }
            self = .tapRow(at: newValue)
        }
    }

    var dismiss: Void?
    {
        guard case .dismiss = self else { return nil }
        return ()
    }

    var _imageLoader: ImageLoader.Action?
    {
        get {
            guard case let ._imageLoader(value) = self else { return nil }
            return value
        }
        set {
            guard case ._imageLoader = self, let newValue = newValue else { return }
            self = ._imageLoader(newValue)
        }
    }
}
