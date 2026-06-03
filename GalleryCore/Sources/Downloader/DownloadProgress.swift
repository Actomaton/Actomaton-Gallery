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
