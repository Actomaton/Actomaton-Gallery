import UIKit
import CommonEffects
import Stopwatch
import GitHub
import GameOfLife
import VideoPlayer
import VideoPlayerMulti
import Downloader

public struct HomeEnvironment: Sendable
{
    let getDate: @Sendable () -> Date
    let timer: @Sendable (TimeInterval) -> AsyncStream<Date>
    let fetchRequest: @Sendable (URLRequest) async throws -> Data

    let gameOfLife: GameOfLife.Root.Environment
    let videoPlayer: VideoPlayer.Environment
    let videoPlayerMulti: VideoPlayerMulti.Environment
    let downloader: Downloader.Environment
}

// MARK: - Live Environment

extension HomeEnvironment
{
    public static func live(commonEffects: CommonEffects) -> HomeEnvironment
    {
        HomeEnvironment(
            getDate: commonEffects.now,
            timer: commonEffects.timer,
            fetchRequest: { urlRequest in
                try await commonEffects.fetch(request: urlRequest)
            },
            gameOfLife: .live,
            videoPlayer: .live,
            videoPlayerMulti: .live,
            downloader: .live
        )
    }
}

extension HomeEnvironment
{
    var github: GitHub.Environment
    {
        GitHub.Environment(
            fetchRepositories: { searchText in
                var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")!
                urlComponents.queryItems = [
                    URLQueryItem(name: "q", value: searchText)
                ]

                var urlRequest = URLRequest(url: urlComponents.url!)
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let data = try await self.fetchRequest(urlRequest)
                let response = try decoder.decode(SearchRepositoryResponse.self, from: data)
                return response
            },
            fetchImage: { url in
                let urlRequest = URLRequest(url: url)
                guard let data = try? await self.fetchRequest(urlRequest) else {
                    return nil
                }
                return UIImage(data: data)
            },
            searchRequestDelay: 0.3,
            imageLoadMaxConcurrency: 3
        )
    }

    var stopwatch: Stopwatch.Environment
    {
        Stopwatch.Environment(
            getDate: getDate,
            timer: timer
        )
    }
}
