import SwiftUI
import ActomatonUI
import Utilities

@MainActor
public struct HomeView: View
{
    private let store: Store<Action, State, Environment>

    public init(store: Store<Action, State, Environment>)
    {
        let _ = Debug.print("HomeView.init")
        self.store = store
    }

    public var body: some View
    {
        let _ = Debug.print("HomeView.body")

        return VStack {
            NavigationView {
                WithViewStore(store.map(state: \.common)) { viewStore in
                    let _ = Debug.print("HomeView.WithViewStore.body")

                    List(exampleList, id: \.exampleTitle) { example in
                        navigationLink(example: example)
                    }
                    .navigationBarTitle(Text("🎭 Actomaton Gallery 🖼️"), displayMode: .large)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Toggle(isOn: viewStore.binding(get: \.isDebuggingTab, onChange: { .debugToggleTab($0) })) {
                                Image(systemName: "sidebar.squares.left")
                            }
                            Toggle(isOn: viewStore.binding(get: \.usesTimeTravel, onChange: { .debugToggleTimeTravel($0) })) {
                                Image(systemName: "clock.arrow.circlepath")
                            }
                        }
                    }
                }
            }
            // IMPORTANT:
            // iOS 15's default `NavigationView` causes broken state management.
            // To workaround, `.navigationViewStyle(.stack)` is required.
            // https://github.com/inamiy/iOS15-SwiftUI-Navigation-Bug
            // https://twitter.com/chriseidhof/status/1441330150872735745
            .navigationViewStyle(.stack)
        }
    }

    private func navigationLink(example: Example) -> some View
    {
        WithViewStore(store.map(state: \.current)) { viewStore in
            let _ = Debug.print("HomeView.navigationLink.WithViewStore.body")

            NavigationLink(
                destination: example.exampleView(store: self.store)
                    .navigationBarTitle(
                        "\(example.exampleTitle)",
                        displayMode: .inline
                    ),
                isActive: viewStore
                    .binding(onChange: Action.changeCurrent)
                    .transform(
                        get: { $0?.example.exampleTitle == example.exampleTitle },
                        set: { _, isPresenting in
                            isPresenting ? example.exampleInitialState : nil
                        }
                    )
                // Comment-Out: `removeDuplictates()` introduced in #3 seems not needed in iOS 15.
                // https://github.com/inamiy/Harvest-SwiftUI-Gallery/pull/3
                //
                // Workaround for SwiftUI's duplicated `isPresenting = false` calls per 1 dismissal.
                // .removeDuplictates()
            ) {
                HStack(alignment: .firstTextBaseline) {
                    example.exampleIcon
                        .frame(width: 44)
                    Text(example.exampleTitle)
                }
                .font(.body)
                .padding(5)
            }
        }
    }
}

// MARK: - Previews

public struct HomeView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: Environment, isMultipleScreens: Bool) -> some View
    {
        HomeView(
            store: .init(
                state: State(current: nil, usesTimeTravel: true, isDebuggingTab: true),
                reducer: Home.reducer,
                environment: environment
            )
        )
        .previewDisplayName("Home")

        if isMultipleScreens {
            HomeView(
                store: .init(
                    state: State(current: .counter(.init()), usesTimeTravel: true, isDebuggingTab: true),
                    reducer: Home.reducer,
                    environment: environment
                )
            )
            .previewDisplayName("Intro")
        }
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                getDate: { Date() },
                timer: { _ in AsyncStream { nil } },
                fetchRequest: { _ in throw CancellationError() },
                stopwatch: .init(
                    getDate: { Date() },
                    timer: { _ in AsyncStream { nil } }
                ),
                github: .init(
                    fetchRepositories: { _ in throw CancellationError() },
                    fetchImage: { _ in nil },
                    searchRequestDelay: 0.3,
                    imageLoadMaxConcurrency: 1
                ),
                downloader: .init(
                    download: { _, _ in AsyncStream { nil } }
                ),
                videoPlayer: .init(
                    getPlayer: { nil },
                    setPlayer: { _ in }
                ),
                videoPlayerMulti: .init(
                    description: "description",
                    videoPlayer1: .init(
                        getPlayer: { nil },
                        setPlayer: { _ in }
                    ),
                    videoPlayer2: .init(
                        getPlayer: { nil },
                        setPlayer: { _ in }
                    )
                ),
                gameOfLife: .init(
                    loadFavorites: { [] },
                    saveFavorites: { _ in },
                    loadPatterns: { [] },
                    parseRunLengthEncoded: { _ in .empty },
                    timer: { _ in AsyncStream { nil } }
                )
            ),
            isMultipleScreens: true
        )
    }
}
