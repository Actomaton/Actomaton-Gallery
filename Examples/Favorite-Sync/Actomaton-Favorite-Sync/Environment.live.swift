import Foundation

extension CardList._Environment
{
    static var live: Self
    {
        .init(
            cardStore: CardStore(),
            favoriteStore: FavoriteStore(),
            sleep: { 
                try await Task.sleep(nanoseconds: $0)
            }
        )
    }
}

extension Card
{
    static let fakedFetchedCards = Array(repeating: symbols, count: 10)
        .flatMap { $0 }
        .enumerated()
        .map {
            Card(id: "\($0)", symbol: $1, title: $1, description: "Description \($1)")
        }
}

private let symbols = ["keyboard", "hifispeaker.fill", "printer.fill", "tv.fill", "desktopcomputer", "headphones", "tv.music.note", "mic", "plus.bubble", "video"]
