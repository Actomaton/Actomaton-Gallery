import Foundation
import CoreGraphics
import VectorMath

extension World
{
    /// Resets `bobs` angular accelerations, and `run` custom logic (no calculation of `angleVelocity` & `angle`).
    /// - Parameter Δt: Simulated delta time per tick.
    @Sendable
    static func tickForBobs(_ run: @escaping @Sendable (inout [Bob], _ boardSize: CGSize, _ Δt: Scalar) -> Void)
        -> @Sendable (inout [Bob], _ boardSize: CGSize, _ Δt: Scalar) -> Void
    {
        { bobs, boardSize, Δt in
            var bobCount = bobs.count

            // Limit `bobs.count` to `maxObjectCount`.
            if bobCount > maxObjectCount {
                bobs.removeFirst(bobCount - maxObjectCount)
                bobCount = maxObjectCount
            }

            // Reset `angleAcceleration`.
            for i in 0 ..< bobCount {
                bobs[i].angleAcceleration = .zero
            }

            // Calculate `angleAcceleration`.
            run(&bobs, boardSize, Δt)

            // NOTE: No calculation of `angleVelocity` & `angle` at end.
        }
    }
}
