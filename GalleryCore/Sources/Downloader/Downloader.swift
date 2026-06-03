import CommonInterfaces

// MARK: - Action

public enum Action: Sendable
{
    case downloadAll
    case cancelAll

    case download(id: DownloadID)
    case pause(id: DownloadID)
    case resume(id: DownloadID)
    case cancel(id: DownloadID)

    // NOTE: Usually, raw data will be received here but omitted for simplicity.
    case _didReceiveData(DownloadID, DownloadProgress<String>)
}

// MARK: - State

public struct State: Hashable, Sendable
{
    public fileprivate(set) var runningTasks: [DownloadID: DownloadState<Unit>] = [:]

    public init() {}

    // MARK: State.DownloadState

    public enum DownloadState<Data>: Hashable, Sendable, CustomStringConvertible
        where Data: Hashable & Sendable
    {
        case waiting(progress: ProgressValue) // in queue
        case running(progress: ProgressValue)
        case paused(progress: ProgressValue)
        case finished(Data)
        case cancelled

        public var progressValue: ProgressValue
        {
            switch self {
            case let .waiting(progress),
                let .running(progress),
                let .paused(progress):
                return progress

            case .finished:
                return 1.0

            case .cancelled:
                return 0.0
            }
        }

        public var canRun: Bool
        {
            switch self {
            case .waiting, .running, .finished:
                return false
            case .paused, .cancelled:
                return true
            }
        }

        public var canPause: Bool
        {
            switch self {
            case .paused, .finished, .cancelled:
                return false
            case .waiting, .running:
                return true
            }
        }

        public var canCancel: Bool
        {
            switch self {
            case .cancelled:
                return false
            case .waiting, .running, .paused,
                .finished: // NOTE: `.finished` -> `.cancelled` transition for retry demo.
                return true
            }
        }

        func map<Data2>(_ f: (Data) -> Data2) -> DownloadState<Data2>
        {
            switch self {
            case let .waiting(progress):
                return .waiting(progress: progress)

            case let .running(progress):
                return .running(progress: progress)

            case let .paused(progress):
                return .paused(progress: progress)

            case let .finished(data):
                return .finished(f(data))

            case .cancelled:
                return .cancelled
            }
        }

        public var description: String
        {
            switch self {
            case let .waiting(progress):
                return progress > 0
                    ? "waiting (\(twoDecimalString(progress * 100))%)"
                    : "waiting"

            case let .running(progress):
                return "running (\(twoDecimalString(progress * 100))%)"

            case let .paused(progress):
                return "paused (\(twoDecimalString(progress * 100))%)"

            case .finished:
                return "finished"

            case .cancelled:
                return "cancelled"
            }
        }

        public typealias ProgressValue = Float
    }

    public struct Unit: Hashable, Sendable {}
}

// MARK: - Environment

public struct Environment: Sendable
{
    let download: @Sendable (DownloadID, _ fromProgress: Float) -> AsyncStream<DownloadProgress<String>>

    /// - Note: In this example, we don't implement too much detail, so it's no-operation.
    let savePartialDownloadedFile: @Sendable (DownloadID) async -> Void = { _ in /* No-Operation */ }

    public init(
        download: @Sendable @escaping (DownloadID, _ fromProgress: Float) -> AsyncStream<DownloadProgress<String>>
    )
    {
        self.download = download
    }
}


// MARK: - EffectID

public struct DownloaderEffectID: EffectID
{
    let downloadID: DownloadID
}

public func cancelAllEffectsPredicate(id: any EffectID) -> Bool
{
    return id is DownloaderEffectID
}

// MARK: - EffectQueue

public struct DownloaderEffectQueue: EffectQueue
{
    public var effectQueuePolicy: EffectQueuePolicy
    {
        .runOldest(maxCount: 2, .suspendNew)
    }
}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    Reducer<Action, State, Environment> { action, state, environment in
        switch action {
        case .downloadAll:
            let downloadIDs: [DownloadID] = [
                "item-01", "item-02", "item-03", "item-04", "item-05",
            ]
            let downloads: Effect<Action> = downloadIDs
                .map { Effect<Action>.next(action: .download(id: $0)) }
                .reduce(Effect<Action>.empty, +)

            return Effect<Action>.next(action: .cancelAll) + downloads

        case .cancelAll:
            for (downloadID, progress) in state.runningTasks where progress.canCancel {
                state.runningTasks[downloadID] = .cancelled
            }
            return .cancel(ids: { $0 is DownloaderEffectID })

        case let .download(downloadID):
            state.runningTasks[downloadID] = .waiting(progress: 0)

            return Effect.sequence(
                id: DownloaderEffectID(downloadID: downloadID),
                queue: DownloaderEffectQueue()
            ) { _ in
                return environment.download(downloadID, 0)
                    .map { Action._didReceiveData(downloadID, $0) }
            }

        case let .pause(downloadID):
            guard let downloadState = state.runningTasks[downloadID] else { return .empty }

            if downloadState.canPause {
                state.runningTasks[downloadID] = .paused(progress: downloadState.progressValue)
            }

            // NOTE: `savePartialDownloadedFile` is no-operation in this example.
            return Effect.fireAndForget { _ in await environment.savePartialDownloadedFile(downloadID) }
                + .cancel(id: DownloaderEffectID(downloadID: downloadID)) // Cancel task for pausing too.

        case let .resume(downloadID):
            let resumingProgress = state.runningTasks[downloadID]?.progressValue ?? 0

            state.runningTasks[downloadID] = .waiting(progress: resumingProgress)

            return Effect.sequence(
                id: DownloaderEffectID(downloadID: downloadID),
                queue: DownloaderEffectQueue()
            ) { _ in
                // NOTE:
                // Usually, `environment.download` should be able to handle pause/resume effects
                // including recovery of partially downloaded files.
                // In this example, however, we don't implement too much detail,
                // so we just pass `resumingProgress` to only mimic UI appearance.
                return environment.download(downloadID, resumingProgress)
                    .map { Action._didReceiveData(downloadID, $0) }
            }

        case let .cancel(downloadID):
            guard let downloadState = state.runningTasks[downloadID] else { return .empty }

            if downloadState.canCancel {
                state.runningTasks[downloadID] = .cancelled
            }
            return .cancel(id: DownloaderEffectID(downloadID: downloadID))

        case let ._didReceiveData(downloadID, progress):
            state.runningTasks[downloadID] = progress.toDownloadState().map { _ in .init() }
            return .empty
        }
    }
}

// MARK: - Other Types

public typealias DownloadID = String

// MARK: - Private

/// Formats `value` with 2 decimal places, e.g. `50.0` -> `"50.00"`.
///
/// - Note: Avoids `String(format:)`, which is unavailable on the WebAssembly Foundation,
///   so `Downloader` stays portable. Output matches `String(format: "%.2f", value)` for `value >= 0`.
private func twoDecimalString(_ value: Float) -> String
{
    let scaled = Int((Double(value) * 100).rounded())
    let whole = scaled / 100
    let frac = abs(scaled % 100)
    return "\(whole).\(frac < 10 ? "0" : "")\(frac)"
}
