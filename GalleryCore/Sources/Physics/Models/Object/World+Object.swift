import Foundation
import Geometry
import VectorMath

extension World
{
    /// Resets `objects` forces, `run` custom logic, and calculates `velocity` & `position`.
    /// - Parameter Δt: Simulated delta time per tick.
    @Sendable
    static func tickForObjects<Obj>(_ run: @escaping @Sendable (inout [Obj], _ boardSize: Size) -> Void)
        -> @Sendable (inout [Obj], _ boardSize: Size, _ Δt: Scalar) -> Void
        where Obj: _ObjectLike
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

                if worldRect.contains(Point(position)) {
                    objects[i].position = position
                }
                else {
                    objects.remove(at: i)
                }
            }
        }
    }
}
