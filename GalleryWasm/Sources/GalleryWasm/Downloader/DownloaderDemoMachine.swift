import Foundation
import Actomaton
import Downloader
import Reactivity

@Reactive
final class DownloaderState
{
    var downloader: Downloader.State = .init()
}

typealias DownloaderDemoMachine = MealyDriver<Downloader.Action, DownloaderState, Never>

func makeDownloaderDemoMachine(state: DownloaderState = DownloaderState()) -> DownloaderDemoMachine
{
    DownloaderDemoMachine(
        state: state,
        reducer: Downloader.reducer
            .contramap(state: \DownloaderState.downloader),
        environment: Downloader.Environment(download: browserDownload)
    )
}

/// Browser-native fake download built on `Task.sleep` (no `URLSession`), matching
/// `Downloader.Environment.download`'s `(DownloadID, Float) -> AsyncStream<DownloadProgress<String>>`
/// contract. Deterministic stepping keeps the demo RNG-free.
private func browserDownload(
    _ downloadID: String,
    _ fromProgress: Float
) -> AsyncStream<Downloader.DownloadProgress<String>>
{
    AsyncStream { continuation in
        let task = Task {
            var progress = fromProgress
            while progress < 1 {
                continuation.yield(.running(progress: progress))
                try? await Task.sleep(nanoseconds: 250_000_000)
                if Task.isCancelled { break }
                progress += 0.07
            }
            if !Task.isCancelled {
                continuation.yield(.finished("\(downloadID) completed"))
            }
            continuation.finish()
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}
