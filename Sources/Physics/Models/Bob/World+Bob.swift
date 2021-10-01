import CoreGraphics
import VectorMath

extension World
{
    /// Resets `bobs` angular accelerations, and `run` custom logic (no calculation of `angleVelocity` & `angle`).
    static func tick(_ run: @escaping (inout [Bob], _ boardSize: CGSize) -> Void)
        -> (inout [Bob], _ boardSize: CGSize) -> Void
    {
        { bobs, boardSize in
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
            run(&bobs, boardSize)

            // NOTE: No calculation of `angleVelocity` & `angle` at end.
        }
    }
}
