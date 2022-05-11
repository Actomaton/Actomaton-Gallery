import SwiftUI
import ActomatonStore
import CommonEffects

@MainActor
public struct GitHubAppView: View
{
    @StateObject
    private var store: Store<Action, State, Environment>

    public init()
    {
        let store = Store<Action, State, Environment>(
            state: State(),
            reducer: reducer,
            environment: .live(commonEffects: .live)
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        GitHubView(store: self.store.proxy.map(environment: { _ in () }))
    }
}

// MARK: - Environment.live

extension GitHub.Environment
{
    public static func live(commonEffects: CommonEffects) -> GitHub.Environment
    {
        return GitHub.Environment(
            fetchRepositories: { searchText in
                var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")!
                urlComponents.queryItems = [
                    URLQueryItem(name: "q", value: searchText)
                ]

                var urlRequest = URLRequest(url: urlComponents.url!)
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let data = try await commonEffects.fetch(request: urlRequest)
                let response = try decoder.decode(SearchRepositoryResponse.self, from: data)
                return response
            },
            fetchImage: { url in
                let urlRequest = URLRequest(url: url)
                guard let data = try? await commonEffects.fetch(request: urlRequest) else {
                    return nil
                }
                return UIImage(data: data)
            },
            searchRequestDelay: 0.3,
            imageLoadMaxConcurrency: 3
        )
    }
}
