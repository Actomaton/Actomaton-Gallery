import Foundation

public struct RootEnvironment
{
    var favorite: Favorite.Environment
    var patternSelect: PatternSelect.Environment
    var game: Game.Environment

    public init(
        loadFavorites: @escaping () throws -> [String],
        saveFavorites: @escaping ([String]) throws -> Void,
        loadPatterns: @escaping () async throws -> [PatternSelect.Section<PatternSelect.Unit>],
        parseRunLengthEncoded: @escaping (URL) throws -> Pattern,
        timer: @escaping (TimeInterval) -> AsyncStream<Date>
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

extension RootEnvironment
{
    public static var live: RootEnvironment
    {
        enum Const {
            static let favoritesFileName = "favorites.json"
        }

        return .init(
            loadFavorites: {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsURL = URL(fileURLWithPath: documentsPath)
                let jsonURL = documentsURL.appendingPathComponent(Const.favoritesFileName)

                if !FileManager.default.fileExists(atPath: jsonURL.path) {
                    return Pattern.defaultPatternNames
                }

                let data = try Data(contentsOf: jsonURL)
                let patternNames = try JSONDecoder().decode([String].self, from: data)

                return patternNames
            },
            saveFavorites: { patternNames in
                let data = try JSONEncoder().encode(patternNames)
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsURL = URL(fileURLWithPath: documentsPath)
                let jsonURL = documentsURL.appendingPathComponent(Const.favoritesFileName)
                try data.write(to: jsonURL)

#if DEBUG
                print("===> Saved JSON to \(jsonURL)")
#endif
            },
            loadPatterns: {
                // Fake heavy loading just for fun.
                await Task.sleep(500_000_000) // 0.5 sec

                let urls = Bundle.module
                    .urls(forResourcesWithExtension: "", subdirectory: "GameOfLife-Patterns")
                ?? []

                typealias Unit = PatternSelect.Unit

                let sections = try urls
                    .lazy
                    .filter { $0.hasDirectoryPath }
                    .compactMap { url -> PatternSelect.Section<Unit>? in
                        let dirName = url.lastPathComponent
                        let subURLs = try FileManager.default.contentsOfDirectory(
                            at: url,
                            includingPropertiesForKeys: nil
                        )
                        return PatternSelect.Section(
                            title: "Pattern: \(dirName)",
                            rows: subURLs
                                .lazy
                                .map { subURL -> PatternSelect.Row<Unit> in
                                    let title = subURL.deletingPathExtension().lastPathComponent
                                    return PatternSelect.Row(
                                        title: title,
                                        url: subURL,
                                        isFavorite: PatternSelect.Unit()
                                    )
                                }
                                .sorted(by: { $0.title < $1.title })
                        )
                    }
                    .sorted(by: { $0.title < $1.title })

                return sections
            },
            parseRunLengthEncoded: { url in
                try Pattern.parseRunLengthEncoded(url: url)
            },
            timer: { timeInterval in
                AsyncStream { continuation in
                    let task = Task {
                        while true {
                            await Task.sleep(UInt64(timeInterval * 1_000_000_000))
                            if Task.isCancelled { break }
                            continuation.yield(Date())
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { @Sendable _ in
                        task.cancel()
                    }
                }
            }
        )
    }
}
