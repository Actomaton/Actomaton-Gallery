import Geometry
import VectorMath

struct SpringPendulumExample: Example
{
    var exampleInitialState: PhysicsRoot.State.Current
    {
        .springPendulum(World.State(objects: [
            CircleObject(mass: 1, position: .init(120, 0), velocity: .zero)
        ]))
    }

    var exampleArrowScale: ArrowScale
    {
        .init(velocityArrowScale: 10, forceArrowScale: 100)
    }
}

// MARK: - Algorithm

extension SpringPendulumExample: ObjectWorldExample
{
    func step(objects: inout [CircleObject], boardSize: Size)
    {
        let objectCount = objects.count

        for i in 0 ..< objectCount {
            let obj = objects[i]
            let posDiff = obj.position - offset
            let length = posDiff.length

            // F = m * g
            let gravityForce = Vector2(0, obj.mass * g)
            objects[i].force = objects[i].force + gravityForce

            if length > rodLength {
                let posDiffNormalized = posDiff.normalized()

                /// Force from rod's tension.
                let force = posDiffNormalized * (gravityForce * obj.mass + obj.velocity * damping).dot(-posDiffNormalized)
                objects[i].force = objects[i].force + force * (1 + (length - rodLength) / 10)
            }
        }
    }
}

// MARK: - Constants

/// Simulated constant of gravity at Earth's surface (`g = 9.807 m/s²` in real world)
private let g: Scalar = 1

/// Simulated string dumping constant.
private let damping: Scalar = 0.03

private let rodLength: Scalar = 300

/// Pivot of 1st pendulum.
private let offset: Vector2 = .init(180, 0)
