import Foundation

/// Cards fetcher & caching.
actor CardStore
{
    private var cards: [Card]?

    private var fetchingTask: Task<[Card], Error>?

    func fetchCards(isForced: Bool = false) async throws -> [Card]
    {
        if isForced { cards = nil }

        // Use cache if possible.
        if let cards = cards { return cards }

        // Reuse already fetching task.
        if let fetchingTask = self.fetchingTask {
            return try await fetchingTask.value
        }

        let newFetchingTask = Task<[Card], Error> {
            // Fake network delay.
            try await Task.sleep(nanoseconds: 300_000_000)

            // DEBUG: Error test.
//            struct MyError: Swift.Error {}
//            throw MyError()

            // Always use built-in faked data (because there is no appropriate endpoint for this demo app).
            let fetchedCards = Card.fakedFetchedCards
            return fetchedCards
        }
        self.fetchingTask = newFetchingTask

        defer { self.fetchingTask = nil } // NOTE: Called even when `newFetchingTask` fails.

        let fetchedCards = try await newFetchingTask.value

        self.cards = fetchedCards

        return fetchedCards
    }

    func fetchCard(id: Card.ID) async throws -> Card?
    {
        let cards = try await fetchCards()
        return cards.first(where: { $0.id == id })
    }
}
