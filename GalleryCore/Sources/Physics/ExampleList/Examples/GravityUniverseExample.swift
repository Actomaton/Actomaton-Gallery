import Geometry
import VectorMath

struct GravityUniverseExample: Example
{
    var exampleInitialState: PhysicsRoot.State.Current
    {
        .gravityUniverse(World.State(objects: CircleObject.orbitingObjects))
    }

    var exampleArrowScale: ArrowScale
    {
        .init(velocityArrowScale: 15, forceArrowScale: 300)
    }
}

// MARK: - Algorithm

extension GravityUniverseExample: ObjectWorldExample
{
    func step(objects: inout [CircleObject], boardSize: Size)
    {
        let objectCount = objects.count

        guard objectCount >= 2 else { return }

        for i in 0 ..< objectCount - 1 {
            let obj = objects[i]

            for j in (i + 1) ..< objectCount {
                let other = objects[j]

                let posDiff = other.position - obj.position

                let r2 = posDiff.lengthSquared

                /// F = GMm / r²
                let force_ = posDiff.normalized() * (g * obj.mass * other.mass / r2)

                // Tweak: Set upper limit for force.
                let force: Vector2 = {
                    let norm = force_.length
                    if norm > 10 {
                        return force_.normalized() * 10
                    }
                    else {
                        return force_
                    }
                }()

                objects[i].force = objects[i].force + force
                objects[j].force = objects[j].force - force // action-reaction law
            }
        }
    }
}

// MARK: - Constants

/// Simulated constant of Gravitation (`G = 6.674×10^{−11}` in real world)
private let g: Scalar = 1
