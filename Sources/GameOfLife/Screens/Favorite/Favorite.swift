import Foundation
import Actomaton

/// Game-of-Life favorite pattern namespace.
public enum Favorite {}

extension Favorite
{
    public enum Action
    {
        case addFavorite(patternName: String)
        case removeFavorite(patternName: String)

        case loadFavorites
        case didLoadFavorites(patternNames: [String]?)
        case saveFavorites
        case didSaveFavorites
    }

    struct State: Equatable
    {
        /// Favorite pattern names.
        var patternNames: [String] = []
    }

    struct Environment
    {
        var loadFavorites: () throws -> [String]
        var saveFavorites: ([String]) throws -> Void

        init(
            loadFavorites: @escaping () throws -> [String],
            saveFavorites: @escaping ([String]) throws -> Void
        )
        {
            self.loadFavorites = loadFavorites
            self.saveFavorites = saveFavorites
        }

        func saveFavoritesEffect(patternNames: [String]) -> Effect<Action>
        {
            Effect {
                try? self.saveFavorites(patternNames)
                return .didSaveFavorites
            }
        }
    }

    static func reducer() -> Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case let .addFavorite(patternName):
                state.patternNames.removeAll { $0 == patternName }
                state.patternNames.insert(patternName, at: 0)
                return environment.saveFavoritesEffect(patternNames: state.patternNames)

            case let .removeFavorite(patternName):
                state.patternNames.removeAll { $0 == patternName }
                return environment.saveFavoritesEffect(patternNames: state.patternNames)

            case .loadFavorites:
                return Effect {
                    let favorites = try? environment.loadFavorites()
                    return .didLoadFavorites(patternNames: favorites)
                }

            case let .didLoadFavorites(patternNames):
                state.patternNames = patternNames ?? []

            case .saveFavorites:
                return environment.saveFavoritesEffect(patternNames: state.patternNames)

            case .didSaveFavorites:
                break
            }

            return .empty
        }
    }
}
