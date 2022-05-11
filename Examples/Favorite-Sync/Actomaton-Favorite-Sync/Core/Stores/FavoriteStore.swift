import Foundation

/// Safe Favorites loader using UserDefaults.
actor FavoriteStore
{
    func loadFavorites() -> [String]
    {
        (UserDefaults.standard.array(forKey: Self.favoritesKey) as? [String]) ?? []
    }

    func loadFavorite(id: Card.ID) -> Bool
    {
        loadFavorites().contains(id)
    }

    func saveFavorites(_ favorites: [String])
    {
        UserDefaults.standard.set(favorites, forKey: Self.favoritesKey)
        UserDefaults.standard.synchronize()
    }

    func saveFavorite(id: Card.ID, isFavorite: Bool)
    {
        var ids = Set(loadFavorites())

        switch (isFavorite, ids.contains(id)) {
        case (false, true):
            ids.remove(id)
        case (true, false):
            ids.insert(id)
        default:
            return
        }

        saveFavorites(Array(ids))
    }

    private static let favoritesKey = "favorites"
}
