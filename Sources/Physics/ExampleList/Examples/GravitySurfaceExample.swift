import SwiftUI
import ActomatonStore
import VectorMath

struct GravitySurfaceExample: Example
{
    var exampleIcon: Image { Image(systemName: "sunset") }

    var exampleInitialState: PhysicsRoot.State.Current
    {
        .gravitySurface(World.State(objects: [
            CircleObject(mass: 1, position: .init(180, 200), velocity: .init(0, 0)),
            CircleObject(mass: 1, position: .init(0, 200), velocity: .init(3, -5)),
            CircleObject(mass: 1, position: .init(0, 200), velocity: .init(3, 0)),
        ]))
    }

    var exampleArrowScale: ArrowScale
    {
        .init(velocityArrowScale: 10, forceArrowScale: 300)
    }

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State>.Proxy) -> AnyView
    {
        let configuration = store.state.configuration

        return Self.exampleView(
            store: store,
            action: PhysicsRoot.Action.gravitySurface,
            statePath: /PhysicsRoot.State.Current.gravitySurface,
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

extension GravitySurfaceExample: ObjectWorldExample
{
    func step(objects: inout [CircleObject], boardSize: CGSize)
    {
        // F = m * g
        for i in 0 ..< objects.count {
            let obj = objects[i]
            objects[i].force = .init(0, obj.mass * g)
        }
    }

    func draggingEmptyArea(_ objects: inout [CircleObject], point: CGPoint)
    {
        objects.append(CircleObject(position: Vector2(point)))
    }
}

// MARK: - Constants

/// Simulated constant of gravity at Earth's surface (`g = 9.807 m/s²` in real world)
private let g: Scalar = 0.1
