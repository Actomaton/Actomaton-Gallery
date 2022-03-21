import SwiftUI
import ActomatonStore
import VectorMath

struct LineCollisionExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle") }

    var exampleInitialState: PhysicsRoot.State.Current
    {
        var objects = CircleObject.collidingObjects.map(Object.circle)
        objects.append(.line(LineObject(startPosition: Vector2(0, 150), endPosition: Vector2(150, 0))))
        objects.append(.line(LineObject(startPosition: Vector2(0, 250), endPosition: Vector2(150, 400))))
        objects.append(.line(LineObject(startPosition: Vector2(250, 0), endPosition: Vector2(400, 150))))
        objects.append(.line(LineObject(startPosition: Vector2(250, 400), endPosition: Vector2(400, 250))))

        return .lineCollision(World.State(objects: objects))
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
            action: PhysicsRoot.Action.lineCollision,
            statePath: /PhysicsRoot.State.Current.lineCollision,
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

extension LineCollisionExample: ObjectWorldExample
{
    func step(objects: inout [Object], boardSize: CGSize)
    {
        let objectCount = objects.count

        for i in 0 ..< objectCount {
            for j in (i + 1) ..< objects.count {
                resolveCollision(objects: &objects, at1: i, at2: j)
            }

            resolveWallCollision(object: &objects[i], boardSize: boardSize)
        }
    }

    func draggingEmptyArea(_ objects: inout [Object], point: CGPoint)
    {
        switch objects.last {
        case var .line(line) where !line.isFinalized:
            line.endPosition = Vector2(point)
            objects[objects.index(before: objects.endIndex)] = .line(line)

        case .line, .circle, .none:
            let point = Vector2(point)
            objects.append(.line(LineObject(startPosition: point, endPosition: point, width: 10, isFinalized: false)))
        }
    }

    func dragEndEmptyArea(_ objects: inout [Object])
    {
        switch objects.last {
        case var .line(line):
            guard !line.isFinalized else { return }
            line.isFinalized = true
            objects[objects.index(before: objects.endIndex)] = .line(line)

        case .circle, .none:
            break
        }
    }
}
