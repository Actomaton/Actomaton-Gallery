import Foundation
import ElementaryUI

@View
struct GitHubPage
{
    @State var machine: GitHubDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeGitHubDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "GitHub" }
            h2(.class("counter-heading")) { "Repository Search" }
            p(.class("counter-copy")) {
                "Search GitHub repositories through the shared GitHub reducer (debounced). "
                "Avatars are loaded by the browser's <img> tag — no ImageLoader on WASM."
            }

            input(.type(.text), .class("gh-search"), .placeholder("Search repositories"))
                .bindValue(
                    Binding(
                        get: { machine.state.github.searchText },
                        set: { machine.send(.updateSearchText($0)) }
                    )
                )

            if machine.state.github.isLoading {
                p(.class("gh-status")) { "Searching…" }
            }

            ul(.class("gh-list")) {
                for item in machine.state.github.items {
                    GitHubRepoRow(
                        htmlURL: item.htmlUrl.absoluteString,
                        avatarURL: item.owner.avatarUrl.absoluteString,
                        name: item.fullName,
                        description: item.description ?? "",
                        stars: item.stargazersCount
                    )
                }
            }
        }
        .onAppear {
            machine.send(.onAppear)
        }
    }
}

@View
struct GitHubRepoRow
{
    var htmlURL: String
    var avatarURL: String
    var name: String
    var description: String
    var stars: Int

    var body: some View
    {
        li(.class("gh-item")) {
            // Whole card is a link to the repository's GitHub page (opens in a new tab).
            a(
                .href(htmlURL),
                .class("gh-item-link"),
                .custom(name: "target", value: "_blank"),
                .custom(name: "rel", value: "noopener noreferrer")
            ) {
                img(.src(avatarURL), .class("gh-avatar"))
                div(.class("gh-info")) {
                    span(.class("gh-name")) { name }
                    if !description.isEmpty {
                        span(.class("gh-desc")) { description }
                    }
                    span(.class("gh-stars")) { "★ \(stars)" }
                }
            }
        }
    }
}
