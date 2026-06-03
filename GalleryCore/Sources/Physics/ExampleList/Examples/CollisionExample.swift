import Geometry
import VectorMath

struct CollisionExample: Example
{
    var exampleInitialState: PhysicsRoot.State.Current
    {
        .collision(World.State(objects: CircleObject.collidingObjects))
    }

    var exampleArrowScale: ArrowScale
    {
        // NOTE: Force (impulse) is not simulated in this example.
        .init(velocityArrowScale: 10, forceArrowScale: 0)
    }
}

// MARK: - Algorithm

extension CollisionExample: ObjectWorldExample
{
    func step(objects: inout [CircleObject], boardSize: Size)
    {
        let objectCount = objects.count

        for i in 0 ..< objectCount {
            for j in (i + 1) ..< objects.count {
                resolveCircleCollision(circles: &objects, at1: i, at2: j)
            }

            resolveCircleWallCollision(circle: &objects[i], boardSize: boardSize)
        }
    }

    func draggingEmptyArea(_ objects: inout [CircleObject], point: Point)
    {
        objects.append(CircleObject(position: Vector2(point)))
    }
}
