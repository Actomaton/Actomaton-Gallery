import SwiftUI
import ActomatonUI
import CanvasPlayer
import Utilities

@MainActor
public struct RootView: View
{
    private let store: Store<GameOfLifeRoot.Action, GameOfLifeRoot.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<GameOfLifeRoot.Action, GameOfLifeRoot.State>

    public init(store: Store<GameOfLifeRoot.Action, GameOfLifeRoot.State, Void>)
    {
        let _ = Debug.print("GameOfLife.RootView.init")

        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("GameOfLife.RootView.body")

        CanvasPlayerView(
            store: self.store
                .map(state: \.game.canvasPlayerState)
                .contramap(action: GameOfLifeRoot.Action.game)
                .contramap(action: Game.Action.canvasPlayer),
            content: { store in
                AnyView(
                    GameView(
                        store: self.store
                            .map(state: \.game)
                            .contramap(action: (/GameOfLifeRoot.Action.game).embed)
                    )
                )
            },
            bottomView: { _ in
                AnyView(starAndPatternName())
            }
        )
        .onAppear {
            self.store.send(.favorite(.loadFavorites))
        }
        .navigationBarItems(
            trailing: Button(action: { self.store.send(.presentPatternSelect) }) {
                Image(systemName: "slider.horizontal.3")
            }
        )
        .padding()
        .sheet(
            isPresented: self.viewStore.binding(
                get: { $0.patternSelect != nil },
                onChange: { isPresenting in
                    isPresenting ? .presentPatternSelect : .dismissPatternSelect
                }
            )
        ) {
            NavigationView {
                self.patternSelectView()
            }
        }
    }

    private func starAndPatternName() -> some View
    {
        HStack {
            Image(systemName: "star")
                .foregroundColor(self.viewStore.isFavoritePattern ? Color.yellow : Color(white: 0.8))
                .onTapGesture {
                    let pattern = self.viewStore.game.selectedPattern
                    self.store.send(.favorite(
                        self.viewStore.isFavoritePattern
                            ? .removeFavorite(patternName: pattern.title)
                            : .addFavorite(patternName: pattern.title)
                    ))
                }

            Button(action: { self.store.send(.presentPatternSelect) }) {
                Text("\(self.viewStore.game.selectedPattern.title)")
                    .lineLimit(1)
            }

            // Add hidden star on the right to balance the center.
            Image(systemName: "star").hidden()
        }
        .font(.title)
    }

    @ViewBuilder
    private func patternSelectView() -> some View
    {
        if let substore = store
            .map(state: \.patternSelect)
            .optionalize()?
            .contramap(action: GameOfLifeRoot.Action.patternSelect)
        {
            let patternSelectView = PatternSelectView(store: substore)
                .navigationBarItems(trailing: Button("Close") { self.store.send(.dismissPatternSelect) })

            patternSelectView
        }
    }
}

// MARK: - Preview

public struct GameOfLife_RootView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: GameOfLifeRoot.Environment, isMultipleScreens: Bool) -> some View
    {
        let gameOfLifeView = RootView(
            store: Store<GameOfLifeRoot.Action, GameOfLifeRoot.State, GameOfLifeRoot.Environment>(
                state: .init(pattern: .glider, cellLength: 5, timerInterval: 0.05),
                reducer: GameOfLifeRoot.reducer(),
                environment: environment
            )
            .noEnvironment
        )

        gameOfLifeView
            .previewDisplayName("Portrait")
//            .previewInterfaceOrientation(.portrait)

//        gameOfLifeView
//            .previewDisplayName("Landscape")
//            .previewInterfaceOrientation(.landscapeRight)
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                loadFavorites: { [] },
                saveFavorites: { _ in },
                loadPatterns: { [] },
                parseRunLengthEncoded: { _ in .glider },
                timer: { _ in AsyncStream(unfolding: { nil }) }
            ),
            isMultipleScreens: true
        )
    }
}
