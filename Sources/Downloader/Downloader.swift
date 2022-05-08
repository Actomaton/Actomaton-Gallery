import Actomaton

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
    case _didReceiveData(DownloadID, Environment.DownloadProgress<String>)
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

        var progressValue: ProgressValue
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

        var canRun: Bool
        {
            switch self {
            case .waiting, .running, .finished:
                return false
            case .paused, .cancelled:
                return true
            }
        }

        var canPause: Bool
        {
            switch self {
            case .paused, .finished, .cancelled:
                return false
            case .waiting, .running:
                return true
            }
        }

        var canCancel: Bool
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
                    ? "waiting (\(String(format: "%.2f", progress * 100))%)"
                    : "waiting"

            case let .running(progress):
                return "running (\(String(format: "%.2f", progress * 100))%)"

            case let .paused(progress):
                return "paused (\(String(format: "%.2f", progress * 100))%)"

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

    // MARK: - Environment.DownloadProgress

    public enum DownloadProgress<Data>: Hashable, Sendable
        where Data: Hashable & Sendable
    {
        case running(progress: ProgressValue)
        case finished(Data)

        var progressValue: ProgressValue
        {
            switch self {
            case let .running(progress):
                return progress

            case .finished:
                return 1.0
            }
        }

        func toDownloadState() -> State.DownloadState<Data>
        {
            switch self {
            case let .running(progress):
                return .running(progress: progress)

            case let .finished(data):
                return .finished(data)
            }
        }

        public typealias ProgressValue = Float
    }
}


// MARK: - EffectID

public struct DownloaderEffectID: EffectIDProtocol
{
    let downloadID: DownloadID
}

public func cancelAllEffectsPredicate(id: EffectID) -> Bool
{
    return id.value is DownloaderEffectID
}

// MARK: - EffectQueue

public struct DownloaderEffectQueue: EffectQueueProtocol
{
    public var effectQueuePolicy: EffectQueuePolicy
    {
        .runOldest(maxCount: 2, .suspendNew)
    }
}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .init { action, state, environment in
        switch action {
        case .downloadAll:
            let downloads = Effect<Action>.nextAction(.download(id: "item-01"))
                + .nextAction(.download(id: "item-02"))
                + .nextAction(.download(id: "item-03"))
                + .nextAction(.download(id: "item-04"))
                + .nextAction(.download(id: "item-05"))

            return Effect.nextAction(.cancelAll)
                + downloads

        case .cancelAll:
            for (downloadID, progress) in state.runningTasks where progress.canCancel {
                state.runningTasks[downloadID] = .cancelled
            }
            return .cancel(ids: { $0.value is DownloaderEffectID })

        case let .download(downloadID):
            state.runningTasks[downloadID] = .waiting(progress: 0)

            return Effect(
                id: DownloaderEffectID(downloadID: downloadID),
                queue: DownloaderEffectQueue(),
                sequence: {
                    return environment.download(downloadID, 0)
                        .map { Action._didReceiveData(downloadID, $0) }
                }
            )

        case let .pause(downloadID):
            guard let downloadState = state.runningTasks[downloadID] else { return .empty }

            if downloadState.canPause {
                state.runningTasks[downloadID] = .paused(progress: downloadState.progressValue)
            }

            // NOTE: `savePartialDownloadedFile` is no-operation in this example.
            return Effect.fireAndForget { await environment.savePartialDownloadedFile(downloadID) }
                + .cancel(id: DownloaderEffectID(downloadID: downloadID)) // Cancel task for pausing too.

        case let .resume(downloadID):
            let resumingProgress = state.runningTasks[downloadID]?.progressValue ?? 0

            state.runningTasks[downloadID] = .waiting(progress: resumingProgress)

            return Effect(
                id: DownloaderEffectID(downloadID: downloadID),
                queue: DownloaderEffectQueue(),
                sequence: {
                    // NOTE:
                    // Usually, `environment.download` should be able to handle pause/resume effects
                    // including recovery of partially downloaded files.
                    // In this example, however, we don't implement too much detail,
                    // so we just pass `resumingProgress` to only mimic UI appearance.
                    return environment.download(downloadID, resumingProgress)
                        .map { Action._didReceiveData(downloadID, $0) }
                }
            )

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
