import Foundation
import Actomaton
import ActomatonUI
import ActomatonDebugging
import SwiftUI

/// CardList (namespace).
enum CardList
{
    // MARK: - Action

    enum Action: Sendable
    {
        case loadFavorites
        case _didLoadFavorites([Card.ID])
        case _showError(Error)
        case _hideError

        case fetchCards
        case _didFetchCards([Card])

        case didTapHeart(Card.ID)
        case didTapCard(CardWithFavorite)
    }

    // MARK: - State

    struct State: Equatable, Sendable
    {
        fileprivate var _cards: [Card]
        fileprivate var favoriteCardIDs: Set<Card.ID>
        fileprivate var showsFavoriteOnly: Bool

        // Mark fetching states as `true` on init so that `emptyView` won't be presented.
        fileprivate var isFetchingCards: Bool = true
        fileprivate var isLoadingFavorites: Bool = true

        fileprivate var errorString: ErrorString?

        init(cards: [Card] = [], favoriteCardIDs: Set<Card.ID> = [], showsFavoriteOnly: Bool)
        {
            self._cards = cards
            self.favoriteCardIDs = favoriteCardIDs
            self.showsFavoriteOnly = showsFavoriteOnly
        }

        var cards: [CardWithFavorite]
        {
            let colors: [Color] =  [.yellow, .purple, .green]

            let cards = _cards
                .enumerated()
                .map { CardWithFavorite(card: $1, color: colors[$0 % colors.count], isFavorite: favoriteCardIDs.contains($1.id)) }

            if showsFavoriteOnly {
                return cards.filter { $0.isFavorite }
            }
            else {
                return cards
            }
        }

        // MARK: - LoadingState

        var loadingState: LoadingState
        {
            if let errorString = errorString {
                return .error(errorString)
            }

            // Show loading only when starting from `emptyView`.
            if (isFetchingCards || isLoadingFavorites) && cards.isEmpty {
                return .loading
            }

            return .idle
        }

        /// - Note: `case empty` shouldn't exist here because it may be overlapped with `error`.
        enum LoadingState: Equatable
        {
            case idle
            case loading
            case error(ErrorString)

            var values: (isLoading: Bool, errorString: ErrorString?)
            {
                switch self {
                case .idle:
                    return (false, nil)
                case .loading:
                    return (true, nil)
                case let .error(errorString):
                    return (false, errorString)
                }
            }
        }

        var shouldShowEmptyView: Bool
        {
            self.cards.isEmpty && self.loadingState == .idle
        }

        /// Error localizedDescription.
        /// - Note: Preferred to have Equatable Error.
        typealias ErrorString = String
    }

    // MARK: - Route

    enum Route
    {
        case showDetail(CardWithFavorite)
    }

    // MARK: - Environment

    struct _Environment: Sendable
    {
        let cardStore: CardStore
        let favoriteStore: FavoriteStore
        let sleep: @Sendable (_ nanoseconds: UInt64) async throws -> Void
    }

    typealias Environment = SendRouteEnvironment<_Environment, Route>

    // MARK: - Reducer

    static func reducer() -> Reducer<Action, State, Environment>
    {
        .debug("[CardList]") { action, state, env in
            switch action {
            case .loadFavorites:
                state.isLoadingFavorites = true

                return Effect {
                    let cardIDs = await env.environment.favoriteStore.loadFavorites()
                    return ._didLoadFavorites(cardIDs)

                    // return ._showError(Error.failedLoadingFavorites)
                }

            case let ._didLoadFavorites(cardIDs):
                state.favoriteCardIDs = Set(cardIDs)
                state.isLoadingFavorites = false
                return .empty

            case .fetchCards:
                state.isFetchingCards = true

                return Effect {
                    if let cards = try? await env.environment.cardStore.fetchCards() {
                        return ._didFetchCards(cards)
                    }
                    else {
                        return ._showError(Error.failedFetchingCards)
                    }
                }

            case let ._didFetchCards(cards):
                state._cards = cards
                state.isFetchingCards = false
                return .empty

            case let .didTapHeart(cardID):
                if let cardID = state.favoriteCardIDs.firstIndex(of: cardID) {
                    state.favoriteCardIDs.remove(at: cardID)
                }
                else {
                    state.favoriteCardIDs.insert(cardID)
                }

                return Effect { [state] in
                    let cardIDs = Array(state.favoriteCardIDs)
                    await env.environment.favoriteStore.saveFavorites(cardIDs)
                    return nil
                }

            case let .didTapCard(card):
                env.sendRoute(.showDetail(card))
                return .empty

            case let ._showError(error):
                print("===> error", error.localizedDescription)
                state.errorString = error.localizedDescription

                switch error {
                case .failedLoadingFavorites:
                    state.isLoadingFavorites = false

                case .failedFetchingCards:
                    state.isFetchingCards = false
                }

                return Effect {
                    try await env.environment.sleep(2_000_000_000)
                    return ._hideError
                }

            case ._hideError:
                state.errorString = nil
                return .empty
            }
        }
    }

    // MARK: - Error

    enum Error: Swift.Error
    {
        case failedLoadingFavorites
        case failedFetchingCards
    }
}
