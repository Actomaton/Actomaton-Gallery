import SwiftUI
import ActomatonStore
import VectorMath

struct GaltonBoardExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle") }

    var exampleInitialState: PhysicsRoot.State.Current
    {
        .galtonBoard(World.State(objects: staticObjects + fallingObjects))
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
            action: PhysicsRoot.Action.galtonBoard,
            statePath: /PhysicsRoot.State.Current.galtonBoard,
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

extension GaltonBoardExample: ObjectWorldExample
{
    func step(objects: inout [CircleObject], boardSize: CGSize)
    {
        let staticCount = staticObjects.count
        let objectCount = objects.count

        func canSlide(_ index: Int) -> Bool
        {
            index >= staticCount
        }

        // F = m * g
        for i in staticCount ..< objects.count {
            let obj = objects[i]
            objects[i].force = .init(0, obj.mass * g)
        }

        for i in 0 ..< objectCount {
            let obj = objects[i]

            for j in (i + 1) ..< objects.count {
                let other = objects[j]
                let posDiff = obj.position - other.position
                let distance = posDiff.length
                let requiredDistance = obj.radius + other.radius
                let overlappedDistance = requiredDistance - distance

                // 2-objects collision https://en.wikipedia.org/wiki/Elastic_collision
                // NOTE: Formula is derived from conservation of kinetic energy and conservation of momentum.
                if overlappedDistance > 0 {
                    let coeff = (obj.velocity - other.velocity).dot(posDiff)
                        * 2 / (obj.mass + other.mass) / posDiff.lengthSquared

                    objects[i].velocity = obj.velocity - posDiff * other.mass * coeff
                    objects[j].velocity = other.velocity + posDiff * obj.mass * coeff

                    // Sliding
                    if canSlide(i) {
                        objects[i].position = obj.position + posDiff * (overlappedDistance / distance) * 0.25
                    }
                    if canSlide(j) {
                        objects[j].position = other.position - posDiff * (overlappedDistance / distance) * 0.25
                    }
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
                objects[i].velocity.y = abs(objects[i].velocity.y) * wallDumping
                objects[i].position.y = obj.radius // sliding
            }
            else if obj.position.y + obj.radius > Scalar(boardSize.height) {
                objects[i].velocity.y = -abs(objects[i].velocity.y) * wallDumping
                objects[i].position.y = Scalar(boardSize.height) - obj.radius // sliding
            }

            // Friction as opposite direction of velocity.
            objects[i].force = objects[i].force + objects[i].velocity.normalized() * -0.0005
        }

        // Keep static.
        for i in 0 ..< staticCount {
            objects[i].velocity = .zero
            objects[i].force = .zero
        }

        // Don't move horizontally after falling is complete.
        for i in staticCount ..< objectCount {
            if objects[i].position.y > 300 {
                objects[i].velocity.x = 0
                objects[i].force.x = 0
            }
        }
    }

    func draggingEmptyArea(_ objects: inout [CircleObject], point: CGPoint)
    {
        objects.append(CircleObject(position: Vector2(point), radius: fallingObjectRadius))
    }

    func exampleTapToMakeObject(point: CGPoint) -> CircleObject?
    {
        CircleObject(position: Vector2(point), radius: fallingObjectRadius)
    }
}

// MARK: - Constants

/// Simulated constant of gravity at Earth's surface (`g = 9.807 m/s²` in real world)
private let g: Scalar = 0.1

private let wallDumping: Scalar = 0.75 // 0.1

private let staticObjectRadius: Scalar = 6
private let fallingObjectRadius: Scalar = 4

private let staticObjects: [CircleObject] = {
    (2 ... 10).flatMap { row -> [CircleObject] in
        (0 ..< row).map { col -> CircleObject in
            let x: Scalar = 180 - staticObjectRadius * 2 * (Scalar(row) - 1) + staticObjectRadius * 4 * Scalar(col)
            let y: Scalar = 100 + staticObjectRadius * 2 * Scalar(row) * sqrt(3)
            return CircleObject(
                mass: 1,
                position: .init(x, y),
                velocity: .init(0, 0),
                radius: staticObjectRadius
            )
        }
    }
}()

private let fallingObjects: [CircleObject] = [
    CircleObject(mass: 1, position: .init(180 - 1, 0), velocity: .init(0, 0), radius: fallingObjectRadius)
]
