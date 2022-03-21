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

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>.Proxy) -> AnyView
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

        // F = m * g
        for i in staticCount ..< objects.count {
            let obj = objects[i]
            objects[i].force = .init(0, obj.mass * g)
        }

        for i in 0 ..< objectCount {
            for j in (i + 1) ..< objects.count {
                resolveCircleCollision(circles: &objects, at1: i, at2: j)
            }

            resolveCircleWallCollision(circle: &objects[i], boardSize: boardSize)
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
                radius: staticObjectRadius,
                isStatic: true
            )
        }
    }
}()

private let fallingObjects: [CircleObject] = [
    CircleObject(mass: 1, position: .init(180 - 1, 0), velocity: .init(0, 0), radius: fallingObjectRadius)
]
