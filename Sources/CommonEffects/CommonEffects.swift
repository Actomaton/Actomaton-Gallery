import Foundation
import ActomatonUI

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
    @Sendable
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
