import SwiftUI
import ActomatonStore

@MainActor
struct CardListView: View
{
    private let store: Store<Action, State>.Proxy

    init(store: Store<Action, State>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        let (isLoading, errorString) = store.state.loadingState.values

        ZStack {
            completedOrEmpty
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

            isLoading ? HUD { ProgressView("Loading") } : nil

            errorViewIfNeeded(errorString: errorString)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
        }
        .onAppear {
            store.send(.loadFavorites)
            store.send(.fetchCards)
        }
    }

    @ViewBuilder
    var completedOrEmpty: some View
    {
        if store.state.cards.isEmpty {
            emptyView
        }
        else {
            completedView
        }
    }

    @ViewBuilder
    func errorViewIfNeeded(errorString: String?) -> some View
    {
        if let errorString = errorString {
            HUD {
                Label(errorString, systemImage: "exclamationmark.triangle")
            }
        }
    }

    @ViewBuilder
    var completedView: some View
    {
        ScrollView {
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            let cards = store.state.cards

            LazyVGrid(columns: columns) {
                ForEach(0 ..< cards.count, id: \.self) { i in
                    let card = cards[i]
                    cardView(card: card, at: i)
                }
            }
        }
    }

    @ViewBuilder
    private func cardView(card: CardWithFavorite, at index: Int) -> some View
    {
        ZStack(alignment: .topTrailing) {
            Button {
                store.send(.didTapCard(card))
            } label: {
                Image(systemName: card.symbol)
                    .font(.system(size: 30))
                    .frame(width: 150, height: 150)
                    .background(card.color)
                    .cornerRadius(10)
            }

            Button {
                store.send(.didTapHeart(card.id))
            } label: {
                Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 30))
                    .frame(width: 30, height: 30)
            }
            .offset(x: -10, y: 10)
        }
        .overlay(
            Text("ID: \(card.id)")
                .padding(.bottom, 8),
            alignment: .bottom
        )
    }

    @ViewBuilder
    private var emptyView: some View
    {
        Text("No Cards")
    }

    typealias Action = CardList.Action
    typealias State = CardList.State
    typealias Route = CardList.Route
}

struct CardListView_Previews: PreviewProvider
{
    static var previews: some View
    {
        CardListView(
            store: .init(
                state: .constant(CardList.State(cards: Card.fakedFetchedCards, showsFavoriteOnly: false)),
                send: { _ in }
            )
        )
    }
}
