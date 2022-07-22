import SwiftUI
import ActomatonUI
import VectorMath

struct PendulumExample: Example
{
    var exampleIcon: Image { Image(systemName: "metronome") }

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

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>) -> AnyView
    {
        let configuration = store.viewStore.configuration

        return Self.exampleView(
            store: store,
            action: PhysicsRoot.Action.pendulum,
            statePath: /PhysicsRoot.State.Current.pendulum,
            makeView: { store in
                // Additionally draws track & rods.
                WorldView(store: store, configuration: configuration, content: { store, configuration in
                    WithViewStore(store) { viewStore -> AnyView in
                        guard viewStore.objects.count >= 1 else {
                            return AnyView(EmptyView())
                        }

                        let offset = Vector2(viewStore.offset)

                        let trackPath = Path {
                            $0.addArc(
                                center: viewStore.offset,
                                radius: CGFloat(viewStore.objects[0].rodLength),
                                startAngle: .degrees(0),
                                endAngle: .degrees(360),
                                clockwise: false
                            )
                        }

                        @MainActor
                        func rodPath(index: Int) -> some View
                        {
                            let obj0 = viewStore.objects[index]

                            let pos0 = offset + obj0.position

                            let rodPath = Path {
                                $0.move(to: CGPoint(offset))
                                $0.addLine(to: CGPoint(pos0))
                            }

                            return rodPath
                                .stroke(Color.green, lineWidth: 1)
                        }

                        let zStack = ZStack(alignment: .topLeading) {
                            // Dashed curve.
                            trackPath
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5]))

                            ForEach(0 ..< viewStore.objects.count, id: \.self) { index in
                                rodPath(index: index)
                            }

                            WorldView<Bob>.makeContentView(
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

extension PendulumExample: BobWorldExample
{
    func step(objects: inout [Bob], boardSize: CGSize, Δt: Scalar)
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
