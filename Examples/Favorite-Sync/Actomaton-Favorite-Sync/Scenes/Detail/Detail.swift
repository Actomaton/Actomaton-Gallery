import Foundation
import Actomaton
import ActomatonStore
import ActomatonDebugging

/// Detail (namespace).
enum Detail
{
    // MARK: - Action

    enum Action
    {
        case loadFavorite
        case _didLoadFavorite(Bool)
        case _showError(Error)
        case _hideError

        case fetchCard
        case _didFetchCard(Card)

        case didTapHeart
    }

    // MARK: - State

    struct State: Equatable
    {
        fileprivate(set) var card: CardWithFavorite

        fileprivate var isFetchingCard: Bool = false
        fileprivate var isLoadingFavorite: Bool = false
        fileprivate var errorString: ErrorString?

        init(card: CardWithFavorite)
        {
            self.card = card
        }

        // MARK: - LoadingState

        var loadingState: LoadingState
        {
            if let errorString = errorString {
                return .error(errorString)
            }

            if isFetchingCard || isLoadingFavorite {
                return .loading
            }

            return .complete
        }

        enum LoadingState: Equatable
        {
            case loading
            case complete
            case empty
            case error(ErrorString)

            var values: (isLoading: Bool, errorString: ErrorString?)
            {
                switch self {
                case .loading:
                    return (true, nil)
                case .complete:
                    return (false, nil)
                case .empty:
                    return (false, nil)
                case let .error(errorString):
                    return (false, errorString)
                }
            }
        }

        /// Error localizedDescription.
        /// - Note: Preferred to have Equatable Error.
        typealias ErrorString = String
    }

    // MARK: - Route

    enum Route
    {
    }

    // MARK: - Environment

    struct _Environment
    {
        let cardStore: CardStore
        let favoriteStore: FavoriteStore
        let sleep: (_ nanoseconds: UInt64) async throws -> Void
    }

    typealias Environment = SendRouteEnvironment<_Environment, Route>

    // MARK: - Reducer

    static func reducer() -> Reducer<Action, State, Environment>
    {
        .debug(name: "[Detail]") { action, state, env in
            switch action {
            case .loadFavorite:
                state.isLoadingFavorite = true

                let cardID = state.card.id

                return Effect {
                    if let isFavorite = await env.environment.favoriteStore.loadFavorite(id: cardID) {
                        return ._didLoadFavorite(isFavorite)
                    }
                    else {
                        return ._showError(Error.failedLoadingFavorites)
                    }
                }

            case let ._didLoadFavorite(isFavorite):
                state.card.isFavorite = isFavorite
                state.isLoadingFavorite = false
                return .empty

            case .fetchCard:
                state.isFetchingCard = true

                let cardID = state.card.id

                return Effect {
                    if let card = try? await env.environment.cardStore.fetchCard(id: cardID) {
                        return ._didFetchCard(card)
                    }
                    else {
                        return ._showError(Error.failedFetchingCards)
                    }
                }

            case let ._didFetchCard(card):
                state.card.card = card
                state.isFetchingCard = false
                return .empty

            case let .didTapHeart:
                state.card.isFavorite.toggle()

                return Effect { [state] in
                    await env.environment.favoriteStore.saveFavorite(id: state.card.id, isFavorite: state.card.isFavorite)
                    return nil
                }

            case let ._showError(error):
                state.errorString = error.localizedDescription

                switch error {
                case .failedLoadingFavorites:
                    state.isLoadingFavorite = false

                case .failedFetchingCards:
                    state.isFetchingCard = false
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
