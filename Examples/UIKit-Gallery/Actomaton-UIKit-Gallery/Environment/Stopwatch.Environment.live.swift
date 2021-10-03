import UIKit
import Stopwatch

extension Stopwatch.Environment
{
    public static var live: Stopwatch.Environment
    {
        Environment(
            getDate: { Date() },
            timer: {
                Timer.publish(every: $0, tolerance: $0 * 0.1, on: .main, in: .common)
                    .autoconnect()
                    .toAsyncStream()
            }
        )
    }
}
