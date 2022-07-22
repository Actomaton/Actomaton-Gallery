import Foundation

public struct RootEnvironment: Sendable
{
    var favorite: Favorite.Environment
    var patternSelect: PatternSelect.Environment
    var game: Game.Environment

    public init(
        loadFavorites: @Sendable @escaping () throws -> [String],
        saveFavorites: @Sendable @escaping ([String]) throws -> Void,
        loadPatterns: @Sendable @escaping () async throws -> [PatternSelect.Section<PatternSelect.Unit>],
        parseRunLengthEncoded: @Sendable @escaping (URL) throws -> Pattern,
        timer: @Sendable @escaping (TimeInterval) -> AsyncStream<Date>
    )
    {
        self.favorite = .init(loadFavorites: loadFavorites, saveFavorites: saveFavorites)
        self.patternSelect = .init(
            loadPatterns: loadPatterns,
            parseRunLengthEncoded: parseRunLengthEncoded,
            favorite: favorite
        )
        self.game = .init(timer: timer)
    }
}
