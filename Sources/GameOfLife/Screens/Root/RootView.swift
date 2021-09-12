import SwiftUI
import ActomatonStore

public struct RootView: View
{
    private let store: Store<Root.Action, Root.State>.Proxy

    public init(store: Store<Root.Action, Root.State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        VStack {
            GeometryReader { geometry in
                GameView(
                    store: self.store.game.contramap(action: (/Root.Action.game).embed),
                    geometrySize: geometry.size
                )
            }

            starAndPatternName()

            controlButtons()
        }
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

    private func controlButtons() -> some View
    {
        HStack {
            Spacer()

            Button(action: { self.store.send(.game(.resetBoard)) }) {
                Image(systemName: "arrow.uturn.left.circle")
            }

            Spacer()

            if self.store.state.game.isRunningTimer {
                Button(action: { self.store.send(.game(.stopTimer)) }) {
                    Image(systemName: "pause.circle")
                }
            }
            else {
                Button(action: { self.store.send(.game(.startTimer)) }) {
                    Image(systemName: "play.circle")
                }
            }

            Spacer()

            Button(action: { self.store.send(.game(.tick)) }) {
                Image(systemName: "chevron.right.circle")
            }

            Spacer()
        }
        .font(.largeTitle)
    }

    private func patternSelectView() -> some View
    {
        guard let stateBinding = Binding(store.$state.patternSelect) else
        {
            return AnyView(EmptyView())
        }

        let substore = Store<PatternSelect.Action, PatternSelect.State>.Proxy(
            state: stateBinding,
            send: { self.store.send(Root.Action.patternSelect($0)) }
        )

        let patternSelectView = PatternSelectView(store: substore)
            .navigationBarItems(trailing: Button("Close") { self.store.send(.dismissPatternSelect) })

        return AnyView(patternSelectView)
    }
}

// MARK: - Preview

struct RootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let gameOfLifeView = RootView(
            store: .init(
                state: .constant(.init(pattern: .glider)),
                send: { _ in }
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
