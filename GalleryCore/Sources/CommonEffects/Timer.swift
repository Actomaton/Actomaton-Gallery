import Foundation

extension CommonEffects
{
    @Sendable
    public static func timer(_ timeInterval: TimeInterval) -> AsyncStream<Date>
    {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
                    if Task.isCancelled { break }
                    continuation.yield(Date())
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
