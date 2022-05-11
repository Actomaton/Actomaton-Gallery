import Foundation
import ActomatonStore

public struct CommonEffects
{
    private let urlSession: URLSession
    private let _timer: @Sendable (TimeInterval) -> AsyncStream<Date>
    private let _now: @Sendable () -> Date

    public init(
        urlSession: URLSession,
        timer: @Sendable @escaping (TimeInterval) -> AsyncStream<Date>,
        now: @Sendable @escaping () -> Date
    )
    {
        self.urlSession = urlSession
        self._timer = timer
        self._now = now
    }
}

// MARK: - Public methods

extension CommonEffects
{
    public func fetch(request: URLRequest) async throws -> Data
    {
        try await urlSession.fetchData(for: request)
    }

    @Sendable
    public func timer(_ timeInterval: TimeInterval) -> AsyncStream<Date>
    {
        self._timer(timeInterval)
    }

    @Sendable
    public func now() -> Date
    {
        self._now()
    }
}

// MARK: - CommonEffects.live

extension CommonEffects
{
    public static var live = CommonEffects(
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
