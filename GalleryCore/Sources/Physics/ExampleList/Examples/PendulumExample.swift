import Geometry
import VectorMath

struct PendulumExample: Example
{
    var exampleInitialState: PhysicsRoot.State.Current
    {
        .pendulum(
            World.State(
                objects: [
                    Bob(mass: 1, rodLength: 150, angle: 0.75 * .pi, angleVelocity: 0),
                    Bob(mass: 1, rodLength: 150, angle: 0.3 * .pi, angleVelocity: 0)
                ],
                offset: .init(x: 180, y: 200)
            )
        )
    }

    var exampleArrowScale: ArrowScale
    {
        .init(velocityArrowScale: 5, forceArrowScale: 100)
    }
}

// MARK: - Algorithm

extension PendulumExample: BobWorldExample
{
    func step(objects: inout [Bob], boardSize: Size, Δt: Scalar)
    {
        guard objects.count >= 1 else { return }

        for i in 0 ..< objects.count {
            let obj = objects[i]

            /// https://en.wikipedia.org/wiki/Pendulum_(mechanics)
            let Δω = -g / obj.rodLength * sin(obj.angle)

            // Euler method.
            objects[i].angleAcceleration = Δω
            let newAngleVelocity = obj.angleVelocity + Δω * Δt
            objects[i].angleVelocity = newAngleVelocity
            objects[i].angle = objects[i].angle + newAngleVelocity * Δt
        }
    }
}

// MARK: - Constants

/// Simulated constant of gravity at Earth's surface (`g = 9.807 m/s²` in real world)
private let g: Scalar = 1
