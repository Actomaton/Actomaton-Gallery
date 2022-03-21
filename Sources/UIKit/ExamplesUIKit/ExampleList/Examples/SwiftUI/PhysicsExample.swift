import SwiftUI
import ActomatonStore
import Physics
import ExampleListUIKit

public struct PhysicsExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "atom") }

    @MainActor
    public func build() -> UIViewController
    {
        HostingViewController.make(
            store: Store(
                state: .init(current: nil),
                reducer: PhysicsRoot.reducer,
                environment: .init(timer: { timeInterval in
                    Timer.publish(every: timeInterval, tolerance: timeInterval * 0.1, on: .main, in: .common)
                        .autoconnect()
                        .toAsyncStream()

//                    AsyncStream { continuation in
//                        let task = Task {
//                            while true {
//                                try await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
//                                if Task.isCancelled { break }
//                                continuation.yield(Date())
//                            }
//                            continuation.finish()
//                        }
//                        continuation.onTermination = { @Sendable _ in
//                            task.cancel()
//                        }
//                    }
                })
            ),
            makeView: PhysicsRootView.init
        )
    }
}
