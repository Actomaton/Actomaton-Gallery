import SwiftUI
import ActomatonUI
import VectorMath

struct SpringPendulumExample: Example
{
    var exampleIcon: Image { Image(systemName: "metronome") }

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

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>) -> AnyView
    {
        let configuration = store.viewStore.configuration

        return Self.exampleView(
            store: store,
            action: PhysicsRoot.Action.springPendulum,
            statePath: /PhysicsRoot.State.Current.springPendulum,
            makeView: { store in
                WorldView(store: store, configuration: configuration, content: { store, configuration in
                    WithViewStore(store) { viewStore -> AnyView in
                        let trackPath = Path {
                            $0.addArc(
                                center: CGPoint(offset),
                                radius: CGFloat(rodLength),
                                startAngle: .degrees(30),
                                endAngle: .degrees(150),
                                clockwise: false
                            )
                        }

                        let rodPath = Path {
                            for obj in store.state.objects {
                                $0.move(to: CGPoint(obj.position))
                                $0.addLine(to: CGPoint(offset))
                            }
                        }

                        let zStack = ZStack(alignment: .topLeading) {
                            // Dashed curve.
                            trackPath
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5]))

                            rodPath
                                .stroke(Color.green, lineWidth: 1)

                            WorldView<CircleObject>.makeContentView(
                                store: store.map(state: \.canvasState),
                                configuration: configuration,
                                absolutePosition: self.absolutePosition,
                                arrowScale: self.exampleArrowScale
                            )
                                .frame(maxWidth: nil, maxHeight: nil, alignment: .center)
                        }

                        return AnyView(zStack)
                    }
                })
            }
        )
    }
}

// MARK: - Algorithm

extension SpringPendulumExample: ObjectWorldExample
{
    func step(objects: inout [CircleObject], boardSize: CGSize)
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
