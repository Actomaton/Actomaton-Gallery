import UIKit
import Stopwatch
import HttpBin
import GitHub
import ElemCellAutomaton
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
    let httpbin: HttpBin.Environment
    let github: GitHub.Environment
    let downloader: Downloader.Environment
    let videoPlayer: VideoPlayer.Environment
    let videoPlayerMulti: VideoPlayerMulti.Environment
    let elemCellAutomaton: ElemCellAutomatonRoot.Environment
    let gameOfLife: GameOfLifeRoot.Environment

    public init(
        getDate: @escaping @Sendable () -> Date,
        timer: @escaping @Sendable (TimeInterval) -> AsyncStream<Date>,
        fetchRequest: @escaping @Sendable (URLRequest) async throws -> Data,
        stopwatch: Stopwatch.Environment,
        httpbin: HttpBin.Environment,
        github: GitHub.Environment,
        downloader: Downloader.Environment,
        videoPlayer: VideoPlayer.Environment,
        videoPlayerMulti: VideoPlayerMulti.Environment,
        elemCellAutomaton: ElemCellAutomatonRoot.Environment,
        gameOfLife: GameOfLifeRoot.Environment
    )
    {
        self.getDate = getDate
        self.timer = timer
        self.fetchRequest = fetchRequest
        self.stopwatch = stopwatch
        self.httpbin = httpbin
        self.github = github
        self.downloader = downloader
        self.videoPlayer = videoPlayer
        self.videoPlayerMulti = videoPlayerMulti
        self.elemCellAutomaton = elemCellAutomaton
        self.gameOfLife = gameOfLife
    }
}
