import SwiftUI
import ActomatonStore
import CanvasPlayer

@MainActor
public struct RootView: View
{
    private let store: Store<Root.Action, Root.State, Void>.Proxy

    public init(store: Store<Root.Action, Root.State, Void>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        CanvasPlayerView(
            store: self.store.game.canvasPlayerState
                .contramap(action: Root.Action.game)
                .contramap(action: Game.Action.canvasPlayer),
            content: { store in
                AnyView(
                    GameView(
                        store: self.store.game.contramap(action: (/Root.Action.game).embed)
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
            isPresented: self.store.patternSelect.stateBinding(
                get: { $0 != nil },
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
                .foregroundColor(self.store.state.isFavoritePattern ? Color.yellow : Color(white: 0.8))
                .onTapGesture {
                    let pattern = self.store.state.game.selectedPattern
                    self.store.send(.favorite(
                        self.store.state.isFavoritePattern
                            ? .removeFavorite(patternName: pattern.title)
                            : .addFavorite(patternName: pattern.title)
                    ))
                }

            Button(action: { self.store.send(.presentPatternSelect) }) {
                Text("\(self.store.state.game.selectedPattern.title)")
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
        if let substore = store.patternSelect
            .traverse(\.self)?
            .contramap(action: Root.Action.patternSelect)
        {
            let patternSelectView = PatternSelectView(store: substore)
                .navigationBarItems(trailing: Button("Close") { self.store.send(.dismissPatternSelect) })

            patternSelectView
        }
    }
}

// MARK: - Preview

struct RootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let gameOfLifeView = RootView(
            store: .mock(
                state: .constant(.init(pattern: .glider, cellLength: 5, timerInterval: 1)),
                environment: ()
            )
        )

        return Group {
            gameOfLifeView.previewLayout(.sizeThatFits)
                .previewDisplayName("Portrait")

            gameOfLifeView.previewLayout(.fixed(width: 568, height: 320))
                .previewDisplayName("Landscape")
        }
    }
}
