import Foundation
import CommonInterfaces

// MARK: - Action

/// Platform-agnostic GitHub repository search (no image loading).
/// - Credit:
///   - https://github.com/marty-suzuki/GitHubSearchWithSwiftUI
///   - https://github.com/ra1028/SwiftUI-Combine
public enum Action: Sendable
{
    case onAppear
    case updateSearchText(String)
    case _updateItems([Repository])
    case _showError(message: String)
    case tapRow(at: Int)
    case dismiss

    public init(response: SearchRepositoryResponse)
    {
        switch response.value {
        case let .repositories(items):
            self = ._updateItems(items)
        case let .failure(error):
            self = ._showError(message: error.message)
        }
    }
}

// MARK: - State

public struct State: Equatable, Sendable
{
    public fileprivate(set) var searchText: String = "SwiftUI"

    fileprivate var selectedIndex: Int? = nil

    public var errorMessage: ErrorMessage? = nil

    public fileprivate(set) var isLoading: Bool = false

    public fileprivate(set) var items: [Repository] = []

    public var selectedWebURL: URL?
    {
        guard let selectedIndex = self.selectedIndex else { return nil }
        return self.items[selectedIndex].htmlUrl
    }

    public var isWebViewPresented: Bool
    {
        get { self.selectedIndex != nil }
        set { self.selectedIndex = nil }
    }

    public init() {}

    public struct ErrorMessage: Identifiable, Equatable, Sendable
    {
        public let message: String

        public var id: String { self.message }
    }
}

// MARK: - Environment

public struct Environment: Sendable
{
    let fetchRepositories: @Sendable (_ searchText: String) async throws -> SearchRepositoryResponse

    var searchRequestDelay: TimeInterval

    public init(
        fetchRepositories: @Sendable @escaping (_ searchText: String) async throws -> SearchRepositoryResponse,
        searchRequestDelay: TimeInterval
    )
    {
        self.fetchRepositories = fetchRepositories
        self.searchRequestDelay = searchRequestDelay
    }

    fileprivate func githubRequest(
        searchText: String
    ) -> Effect<Action>
    {
        guard !searchText.isEmpty else {
            return Effect.next(action: Action._updateItems([]))
        }

        // Search request.
        return Effect(id: GitHubRequestID()) { _ in
            // Sleep + EffectID auto-cancellation as debounce.
            try await Task.sleep(nanoseconds: UInt64(self.searchRequestDelay * TimeInterval(1_000_000_000)))

            if Task.isCancelled {
                return nil
            }

            do {
                let response = try await self.fetchRepositories(searchText)
                return Action(response: response)
            }
            catch {
                return Action._showError(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - EffectID

public struct GitHubRequestID: EffectID {}

public func cancelAllEffectsPredicate(id: any EffectID) -> Bool
{
    id is GitHubRequestID
}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    Reducer<Action, State, Environment> { action, state, environment in
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

        case let ._showError(message):
            state.isLoading = false
            state.errorMessage = .init(message: message)

        case let .tapRow(index):
            state.selectedIndex = index

        case .dismiss:
            state.selectedIndex = nil
        }

        return .empty
    }
}
