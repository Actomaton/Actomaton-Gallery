import UIKit
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

    let stopwatch: Stopwatch.Environment
    let github: GitHub.Environment
    let downloader: Downloader.Environment
    let videoPlayer: VideoPlayer.Environment
    let videoPlayerMulti: VideoPlayerMulti.Environment
    let gameOfLife: GameOfLife.Root.Environment

    public init(
        getDate: @escaping @Sendable () -> Date,
        timer: @escaping @Sendable (TimeInterval) -> AsyncStream<Date>,
        fetchRequest: @escaping @Sendable (URLRequest) async throws -> Data,
        stopwatch: Stopwatch.Environment,
        github: GitHub.Environment,
        downloader: Downloader.Environment,
        videoPlayer: VideoPlayer.Environment,
        videoPlayerMulti: VideoPlayerMulti.Environment,
        gameOfLife: GameOfLife.Root.Environment
    )
    {
        self.getDate = getDate
        self.timer = timer
        self.fetchRequest = fetchRequest
        self.stopwatch = stopwatch
        self.github = github
        self.downloader = downloader
        self.videoPlayer = videoPlayer
        self.videoPlayerMulti = videoPlayerMulti
        self.gameOfLife = gameOfLife
    }
}
