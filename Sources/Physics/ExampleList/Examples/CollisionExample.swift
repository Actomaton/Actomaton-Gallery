import SwiftUI
import ActomatonStore
import VectorMath

struct CollisionExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle") }

    var exampleInitialState: PhysicsRoot.State.Current
    {
        .collision(World.State(objects: Object.collidingObjects))
    }

    var exampleArrowScale: ArrowScale
    {
        // NOTE: Force (impulse) is not simulated in this example.
        .init(velocityArrowScale: 10, forceArrowScale: 0)
    }

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State>.Proxy) -> AnyView
    {
        let configuration = store.state.configuration

        return Self.exampleView(
            store: store,
            action: PhysicsRoot.Action.collision,
            statePath: /PhysicsRoot.State.Current.collision,
            makeView: {
                WorldView(
                    store: $0,
                    configuration: configuration,
                    absolutePosition: self.absolutePosition,
                    arrowScale: self.exampleArrowScale
                )
            }
        )
    }
}

// MARK: - Algorithm

extension CollisionExample: ObjectWorldExample
{
    func step(objects: inout [Object], boardSize: CGSize)
    {
        let objectCount = objects.count

        for i in 0 ..< objectCount {
            let obj = objects[i]

            for j in (i + 1) ..< objects.count {
                let other = objects[j]
                let posDiff = obj.position - other.position
                let posDiffNorm = posDiff.normalized()
                let overlappedDistance = obj.radius + other.radius - posDiff.length

                // 2-objects collision https://en.wikipedia.org/wiki/Elastic_collision
                // NOTE: Formula is derived from conservation of kinetic energy and conservation of momentum.
                if overlappedDistance > 0 {
                    let coeff = (obj.velocity - other.velocity).dot(posDiffNorm)
                        * 2 / (obj.mass + other.mass)

                    objects[i].velocity = obj.velocity - posDiffNorm * other.mass * coeff
                    objects[j].velocity = other.velocity + posDiffNorm * obj.mass * coeff

                    // Sliding
                    objects[i].position = obj.position + posDiffNorm * overlappedDistance * 0.05
                    objects[j].position = other.position - posDiffNorm * overlappedDistance * 0.05
                }
            }

            // Flip `velocity.x` if reached at the edge of `canvasSize`.
            // WARNING: No continuous collision detection.
            if obj.position.x - obj.radius < 0 {
                objects[i].velocity.x = abs(objects[i].velocity.x) * 0.25
                objects[i].position.x = obj.radius // sliding
            }
            else if obj.position.x + obj.radius > Scalar(boardSize.width) {
                objects[i].velocity.x = -abs(objects[i].velocity.x) * 0.25
                objects[i].position.x = Scalar(boardSize.width) - obj.radius // sliding
            }

            // Flip `velocity.y` if reached at the edge of `canvasSize`.
            if obj.position.y - obj.radius < 0 {
                objects[i].velocity.y = abs(objects[i].velocity.y)
                objects[i].position.y = obj.radius // sliding
            }
            else if obj.position.y + obj.radius > Scalar(boardSize.height) {
                objects[i].velocity.y = -abs(objects[i].velocity.y)
                objects[i].position.y = Scalar(boardSize.height) - obj.radius // sliding
            }

            // Friction as opposite direction of velocity.
            objects[i].force = objects[i].velocity.normalized() * -0.0005
        }
    }

    func draggingVoid(_ objects: inout [Object], point: CGPoint)
    {
        objects.append(Object(position: Vector2(point)))
    }
}

// MARK: - Constants

/// Simulated constant of gravity at Earth's surface (`g = 9.807 m/s²` in real world)
private let g: Scalar = 0.1
