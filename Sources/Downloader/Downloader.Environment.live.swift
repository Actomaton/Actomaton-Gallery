extension Environment
{
    public static var live: Environment
    {
        return .init(
            download: { downloadID, initialProgress in
                AsyncStream { continuation in
                    let task = Task {
                        var progress: Float = initialProgress

                        while progress < 1 {
                            continuation.yield(.running(progress: progress))
                            try await Task.sleep(nanoseconds: 200_000_000 * UInt64.random(in: 1 ... 5))
                            progress += 0.05 * Float.random(in: 1 ... 3)
                        }

                        continuation.yield(.finished("\(downloadID) completed"))
                        continuation.finish()
                    }

                    continuation.onTermination = { @Sendable _ in
                        task.cancel()
                    }
                }
            }
        )
    }
}

