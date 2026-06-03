import Foundation
import Actomaton
import GitHub
import Reactivity
import JavaScriptKit
import JavaScriptEventLoop

@Reactive
final class GitHubState
{
    var github: GitHub.State = .init()
}

typealias GitHubDemoMachine = MealyDriver<GitHub.Action, GitHubState, Never>

func makeGitHubDemoMachine(state: GitHubState = GitHubState()) -> GitHubDemoMachine
{
    GitHubDemoMachine(
        state: state,
        reducer: GitHub.reducer
            .contramap(state: \GitHubState.github),
        environment: GitHub.Environment(
            fetchRepositories: browserSearch,
            searchRequestDelay: 0.3
        )
    )
}

/// Real GitHub search via the browser `fetch` (JavaScriptKit), decoded with `JSONDecoder`.
/// GitHub's API sends `Access-Control-Allow-Origin: *`; unauthenticated search is rate-limited,
/// mitigated by the core's `Task.sleep` debounce + `GitHubRequestID` auto-cancellation.
@Sendable
private func browserSearch(_ searchText: String) async throws -> GitHub.SearchRepositoryResponse
{
    let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
    let urlString = "https://api.github.com/search/repositories?q=\(query)"
    let response = try await JSPromise(JSObject.global.fetch!(urlString).object!)!.value
    let textValue = try await JSPromise(response.object!.text!().object!)!.value
    let text = textValue.string ?? ""

    // GitHub's JSON is snake_case (full_name, stargazers_count, avatar_url, ...).
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(GitHub.SearchRepositoryResponse.self, from: Data(text.utf8))
}
