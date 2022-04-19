import SwiftUI
import ActomatonStore

@MainActor
struct DetailView: View
{
    private let store: Store<Action, State, Void>.Proxy

    init(store: Store<Action, State, Void>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        VStack {
            cardView(card: store.state.card)
            cardViewFooter(card: store.state.card)
        }
        .onAppear {
            store.send(.loadFavorite)
            store.send(.fetchCard)
        }
    }

    @ViewBuilder
    private func cardView(card: CardWithFavorite) -> some View
    {
        ZStack(alignment: .topTrailing) {
            Image(systemName: card.symbol)
                .font(.system(size: 30))
                .frame(width: 150, height: 150)
                .background(card.color)
                .cornerRadius(10)

            Button {
                store.send(.didTapHeart)
            } label: {
                Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 30))
                    .frame(width: 30, height: 30)

            }
            .offset(x: -10, y: 10)
        }
    }

    @ViewBuilder
    private func cardViewFooter(card: CardWithFavorite) -> some View
    {
        Text("ID: \(card.id)")
        Text(card.title)
        Text(card.description)
    }

    typealias Action = Detail.Action
    typealias State = Detail.State
    typealias Route = Detail.Route
}

struct DetailView_Previews: PreviewProvider
{
    static var previews: some View
    {
        DetailView(
            store: .mock(
                state: .constant(
                    Detail.State(
                        card: .init(
                            card: Card.fakedFetchedCards[0],
                            color: .yellow,
                            isFavorite: false
                        )
                    )
                ),
                environment: ()
            )
        )
    }
}
