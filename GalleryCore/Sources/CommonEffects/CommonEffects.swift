import Foundation
#if !arch(wasm32) && canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ActomatonUI

public struct CommonEffects: Sendable
{
    #if !arch(wasm32)
    private let urlSession: URLSession
    #endif
    private let _timer: @Sendable (TimeInterval) -> AsyncStream<Date>
    private let _now: @Sendable () -> Date

    #if !arch(wasm32)
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
    #endif
}

// MARK: - Public methods

extension CommonEffects
{
    #if !arch(wasm32)
    @Sendable
    public func fetch(request: URLRequest) async throws -> Data
    {
        try await urlSession.fetchData(for: request)
    }
    #endif

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
