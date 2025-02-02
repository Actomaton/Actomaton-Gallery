import UIKit
import AVFoundation
import ActomatonUI
import CommonEffects
import Stopwatch
import HttpBin
import GitHub
import Downloader
import VideoPlayer
import VideoPlayerMulti
import ElemCellAutomaton
import GameOfLife
import Physics
import Home

// MARK: - CommonEffects.live

extension CommonEffects
{
    public static let live = CommonEffects(
        urlSession: URLSession.shared,
        timer: { timeInterval in
            Timer.publish(every: timeInterval, tolerance: timeInterval * 0.1, on: .main, in: .common)
                .autoconnect()
                .toAsyncStream()

            // Warning: Using `Task.sleep` may not be accurate timer.
//            AsyncStream { continuation in
//                let task = Task {
//                    while true {
//                        if Task.isCancelled { break }
//                        try await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
//                        continuation.yield(Date())
//                    }
//                    continuation.finish()
//                }
//                continuation.onTermination = { @Sendable _ in
//                    task.cancel()
//                }
//            }
        },
        now: { Date() }
    )
}

// MARK: - Stopwatch.Environment

extension Stopwatch.Environment: LiveEnvironment
{
    public init(commonEffects: CommonEffects)
    {
        self.init(
            getDate: commonEffects.now,
            timer: commonEffects.timer
        )
    }
}


// MARK: - HttpBin.Environment

extension HttpBin.Environment: LiveEnvironment
{
    public init(commonEffects: CommonEffects)
    {
        self.init(
            fetch: {
                let url = URL(string: "https://httpbin.org/ip")!

                var urlRequest = URLRequest(url: url)
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let decoder = JSONDecoder()

                let data = try await commonEffects.fetch(request: urlRequest)

                // Additional delay for testing.
                try await Task.sleep(nanoseconds: 1_000_000_000)

                let response = try decoder.decode(HttpBinResponse.self, from: data)
                return response
            }
        )
    }
}

// MARK: - GitHub.Environment

extension GitHub.Environment: LiveEnvironment
{
    public init(commonEffects: CommonEffects)
    {
        self.init(
            fetchRepositories: { searchText in
                var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")!
                urlComponents.queryItems = [
                    URLQueryItem(name: "q", value: searchText)
                ]

                var urlRequest = URLRequest(url: urlComponents.url!)
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let data = try await commonEffects.fetch(request: urlRequest)
                let response = try decoder.decode(SearchRepositoryResponse.self, from: data)
                return response
            },
            fetchImage: { url in
                let urlRequest = URLRequest(url: url)
                guard let data = try? await commonEffects.fetch(request: urlRequest) else {
                    return nil
                }
                return UIImage(data: data)
            },
            searchRequestDelay: 0.3,
            imageLoadMaxConcurrency: 3
        )
    }
}

// MARK: - Downloader.Environment

extension Downloader.Environment: LiveEnvironment
{
    public init(commonEffects: CommonEffects)
    {
        self.init(
            download: { downloadID, initialProgress in
                AsyncStream { continuation in
                    let task = Task {
                        var progress: Float = initialProgress

                        while progress < 1 {
                            continuation.yield(.running(progress: progress))
                            try await Task.sleep(nanoseconds: 200_000_000 * UInt64.random(in: 1 ... 5))
                            progress += 0.05 * Float.random(in: 1 ... 3)
                        }

                        continuation.yield(.finished("\(downloadID) completed"))
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

// MARK: - VideoPlayer.Environment

extension VideoPlayer.Environment: LiveEnvironment
{
    @MainActor
    public init(commonEffects: CommonEffects)
    {
        /// Effectful references.
        @MainActor
        class Refs {
            var player: AVPlayer?
        }

        let refs = Refs()

        self.init(
            getPlayer: { refs.player },
            setPlayer: { refs.player = $0 }
        )
    }
}

// MARK: - VideoPlayerMulti.Environment

extension VideoPlayerMulti.Environment: LiveEnvironment
{
    /// Live environment that separates `AVPlayer` per each `VideoPlayer` module.
    @MainActor
    public init(commonEffects: CommonEffects)
    {
        // NOTE: Creates different `.live` `AVPlayer` environment for each player.
        let environment1 = VideoPlayer.Environment(commonEffects: commonEffects)
        let environment2 = VideoPlayer.Environment(commonEffects: commonEffects)

        self.init(
            description: "Multiple AVPlayers",
            videoPlayer1: environment1,
            videoPlayer2: environment2
        )
    }
}

// MARK: - ElemCellAutomaton.RootEnvironment.live

extension ElemCellAutomaton.RootEnvironment: LiveEnvironment
{
    public init(commonEffects: CommonEffects)
    {
        self.init(
            timer: commonEffects.timer
        )
    }
}

// MARK: - GameOfLife.RootEnvironment.live

extension GameOfLife.RootEnvironment: LiveEnvironment
{
    public init(commonEffects: CommonEffects)
    {
        enum Const {
            static let favoritesFileName = "favorites.json"
        }

        self.init(
            loadFavorites: {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsURL = URL(fileURLWithPath: documentsPath)
                let jsonURL = documentsURL.appendingPathComponent(Const.favoritesFileName)

                if !FileManager.default.fileExists(atPath: jsonURL.path) {
                    return GameOfLife.Pattern.defaultPatternNames
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
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec

                let urls = Bundle.gameOfLife
                    .urls(forResourcesWithExtension: "", subdirectory: "GameOfLife-Patterns")
                ?? []

                typealias Unit = GameOfLife.PatternSelect.Unit

                let sections = try urls
                    .lazy
                    .filter { $0.hasDirectoryPath }
                    .compactMap { url -> GameOfLife.PatternSelect.Section<Unit>? in
                        let dirName = url.lastPathComponent
                        let subURLs = try FileManager.default.contentsOfDirectory(
                            at: url,
                            includingPropertiesForKeys: nil
                        )
                        return PatternSelect.Section(
                            title: "Pattern: \(dirName)",
                            rows: subURLs
                                .lazy
                                .map { subURL -> GameOfLife.PatternSelect.Row<Unit> in
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
            timer: commonEffects.timer
        )
    }
}

// MARK: - PhysicsRoot.Environment

extension PhysicsRoot.Environment: LiveEnvironment
{
    public init(commonEffects: CommonEffects)
    {
        self.init(
            timer: commonEffects.timer
        )
    }
}

// MARK: - PhysicsRoot.Environment

extension Home.HomeEnvironment: LiveEnvironment
{
    public init(commonEffects: CommonEffects)
    {
        self.init(
            getDate: commonEffects.now,
            timer: commonEffects.timer,
            fetchRequest: commonEffects.fetch,
            stopwatch: .live,
            httpbin: .live,
            github: .live,
            downloader: .live,
            videoPlayer: .live,
            videoPlayerMulti: .live,
            elemCellAutomaton: .live,
            gameOfLife: .live
        )
    }
}
