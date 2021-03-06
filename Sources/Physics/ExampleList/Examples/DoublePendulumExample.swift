import SwiftUI
import ActomatonUI
import VectorMath

/// https://www.myphysicslab.com/pendulum/double-pendulum-en.html
/// http://www.physicsandbox.com/projects/double-pendulum.html
/// https://github.com/lotz84/double-pendulum-simulation/blob/master/src/DoublePendulum.hs
struct DoublePendulumExample: Example
{
    var exampleIcon: Image { Image(systemName: "metronome") }

    var exampleInitialState: PhysicsRoot.State.Current
    {
        .doublePendulum(
            World.State(
                objects: Self.bobs,
                offset: .init(x: 180, y: 200)
            )
        )
    }

    private static var bobs: [Bob]
    {
        sequence(first: 0.4, next: { $0 + 1e-6 })
            .prefix(20) // NOTE: Adjust this value to see double-pendulum's chaos behavior
            .flatMap {
                [
                    Bob(mass: 1, rodLength: 100, angle: 0.4 * .pi, angleVelocity: 0),
                    Bob(mass: 1, rodLength: 100, angle: $0 * .pi, angleVelocity: 0)
                ]
            }
    }

    var exampleArrowScale: ArrowScale
    {
        .init(velocityArrowScale: 5, forceArrowScale: 0.2)
    }

    var absolutePosition: ((_ relativePosition: Vector2, _ index: Int, _ previous: Vector2) -> Vector2)?
    {
        // IMPORTANT:
        // `DoublePendulumExample` uses 2 objects where 2nd object relies on 1st object's position.
        { relativePosition, index, previous in
            index % 2 == 1
                ? relativePosition + previous // 2nd obj (relies on 1st (previous) position)
                : relativePosition            // 1st obj
        }
    }

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>) -> AnyView
    {
        let configuration = store.viewStore.configuration

        return Self.exampleView(
            store: store,
            action: PhysicsRoot.Action.doublePendulum,
            statePath: /PhysicsRoot.State.Current.doublePendulum,
            makeView: { store in
                // Additionally draws track & rods.
                WorldView<Bob>(store: store, configuration: configuration, content: { store, configuration in
                    WithViewStore(store) { viewStore -> AnyView in
                        guard viewStore.objects.count >= 2 else {
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
                            let obj0 = viewStore.objects[index * 2]
                            let obj1 = viewStore.objects[index * 2 + 1]

                            let pos0 = offset + obj0.position
                            let pos1 = pos0 + obj1.position

                            let rodPath = Path {
                                $0.move(to: CGPoint(offset))
                                $0.addLine(to: CGPoint(pos0))
                            }

                            let rod2Path = Path {
                                $0.move(to: CGPoint(pos0))
                                $0.addLine(to: CGPoint(pos1))
                            }

                            return Group {
                                rodPath
                                    .stroke(Color.green, lineWidth: 1)

                                rod2Path
                                    .stroke(Color.blue, lineWidth: 1)
                            }
                        }

                        let zStack = ZStack(alignment: .topLeading) {
                            // Dashed curve.
                            trackPath
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5]))

                            ForEach(0 ..< viewStore.objects.count / 2, id: \.self) { index in
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

extension DoublePendulumExample: BobWorldExample
{
    func step(objects: inout [Bob], boardSize: CGSize, ??t: Scalar)
    {
        guard objects.count >= 2 else { return }

        // Runge-Kutta method.
        objects = rungeKutta(dt: ??t, f: diffEq, bobs: objects)
    }

    /// https://www.physicsandbox.com/projects/double-pendulum.html
    private func diffEq(objects: [Bob]) -> [??Bob]
    {
        precondition(objects.count >= 2)

        var ??Bobs = [??Bob](repeating: .empty, count: objects.count)

        for i in 0 ..< objects.count / 2 {
            let obj1 = objects[i * 2]
            let obj2 = objects[i * 2 + 1]
            let l1 = obj1.rodLength
            let l2 = obj2.rodLength
            let m1 = obj1.mass
            let m2 = obj2.mass
            let ??1 = obj1.angle
            let ??2 = obj2.angle
            let ??1 = obj1.angleVelocity
            let ??2 = obj2.angleVelocity
            let ?? = 1 + m1 / m2

            let ??1??, ??2??: Scalar

            do {
                let x1 = g * sin(??2) * cos(??1 - ??2) - ?? * sin(??1)
                let x2 = (l2 * pow(??2, 2) + l1 * pow(??1, 2) * cos(??1 - ??2)) * sin(??1 - ??2)
                let denom = l1 * (?? - pow(cos(??1 - ??2), 2))

                ??1?? = (x1 - x2) / denom
            }

            do {
                let x1 = ?? * g * (sin(??1) * cos(??1 - ??2) - sin(??2))
                let x2 = (?? * l1 * pow(??1, 2) + l2 * pow(??2, 2) * cos(??1 - ??2)) * sin(??1 - ??2)
                let denom = l2 * (?? - pow(cos(??1 - ??2), 2))

                ??2?? = (x1 + x2) / denom
            }

            ??Bobs[i * 2] = .init(d??dt: ??1, d??dt: ??1??)
            ??Bobs[i * 2 + 1] = .init(d??dt: ??2, d??dt: ??2??)
        }

        return ??Bobs
    }

    /// https://www.myphysicslab.com/pendulum/double-pendulum-en.html
    /// - Note: Not used, just for reference (and this works too).
    private func __diffEq(objects: [Bob]) -> [??Bob]
    {
        precondition(objects.count >= 2)

        var ??Bobs = [??Bob](repeating: .empty, count: objects.count)

        for i in 0 ..< objects.count / 2 {
            let obj1 = objects[i * 2]
            let obj2 = objects[i * 2 + 1]
            let l1 = obj1.rodLength
            let l2 = obj2.rodLength
            let m1 = obj1.mass
            let m2 = obj2.mass
            let ??1 = obj1.angle
            let ??2 = obj2.angle
            let ??1 = obj1.angleVelocity
            let ??2 = obj2.angleVelocity

            let ??1??, ??2??: Scalar

            do {
                let x1 = -g * (2 * m1 + m2) * sin(??1)
                let x2 = -m2 * g * sin(??1 - 2 * ??2)
                let x3 = -2 * sin(??1 - ??2) * m2
                let x4 = (pow(??2, 2) * l2 + pow(??1, 2) * l1 * cos(??1 - ??2))
                let denom = l1 * (2 * m1 + m2 - m2 * cos(2 * ??1 - 2 * ??2))

                ??1?? = (x1 + x2 + x3 * x4) / denom
            }

            do {
                let x1 = 2 * sin(??1 - ??2)
                let x2 = pow(??1, 2) * l1 * (m1 + m2)
                let x3 = g * (m1 + m2) * cos(??1)
                let x4 = pow(??2, 2) * l2 * m2 * cos(??1 - ??2)
                let denom = l2 * (2 * m1 + m2 - m2 * cos(2 * ??1 - 2 * ??2))

                ??2?? = x1 * (x2 + x3 + x4) / denom
            }

            ??Bobs[i * 2] = .init(d??dt: ??1, d??dt: ??1??)
            ??Bobs[i * 2 + 1] = .init(d??dt: ??2, d??dt: ??2??)
        }

        return ??Bobs
    }
}

// MARK: - Constants

/// Simulated constant of gravity at Earth's surface (`g = 9.807 m/s??` in real world)
private let g: Scalar = 1
