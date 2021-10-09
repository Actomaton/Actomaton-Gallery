import Foundation
import CoreGraphics
import VectorMath

extension World
{
    /// Resets `objects` forces, `run` custom logic, and calculates `velocity` & `position`.
    /// - Parameter Δt: Simulated delta time per tick. 
    static func tickForObjects(_ run: @escaping (inout [Object], _ boardSize: CGSize) -> Void)
        -> (inout [Object], _ boardSize: CGSize, _ Δt: Scalar) -> Void
    {
        { objects, boardSize, Δt in
            let Δt_ = Scalar(Δt)
            var objectCount = objects.count

            // Limit `objects.count` to `maxObjectCount`.
            if objectCount > maxObjectCount {
                objects.removeFirst(objectCount - maxObjectCount)
                objectCount = maxObjectCount
            }

            // Reset forces.
            for i in 0 ..< objectCount {
                objects[i].force = .zero
            }

            // Calculate forces.
            run(&objects, boardSize)

            // Calculate velocities & positions.
            for i in (0 ..< objectCount).reversed() {
                objects[i].velocity = objects[i].velocity + objects[i].force / objects[i].mass * Δt_

                let position = objects[i].position + objects[i].velocity * Δt_

                if worldRect.contains(CGPoint(position)) {
                    objects[i].position = position
                }
                else {
                    objects.remove(at: i)
                }
            }
        }
    }
}
