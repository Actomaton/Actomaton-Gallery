import SwiftUI
import ActomatonUI
import VectorMath

struct CollisionExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle") }

    var exampleInitialState: PhysicsRoot.State.Current
    {
        .collision(World.State(objects: CircleObject.collidingObjects))
    }

    var exampleArrowScale: ArrowScale
    {
        // NOTE: Force (impulse) is not simulated in this example.
        .init(velocityArrowScale: 10, forceArrowScale: 0)
    }

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>) -> AnyView
    {
        let configuration = store.viewStore.configuration

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
    func step(objects: inout [CircleObject], boardSize: CGSize)
    {
        let objectCount = objects.count

        for i in 0 ..< objectCount {
            for j in (i + 1) ..< objects.count {
                resolveCircleCollision(circles: &objects, at1: i, at2: j)
            }

            resolveCircleWallCollision(circle: &objects[i], boardSize: boardSize)
        }
    }

    func draggingEmptyArea(_ objects: inout [CircleObject], point: CGPoint)
    {
        objects.append(CircleObject(position: Vector2(point)))
    }
}
