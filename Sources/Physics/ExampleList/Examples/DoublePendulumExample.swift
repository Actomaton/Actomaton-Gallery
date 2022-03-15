import SwiftUI
import ActomatonStore
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

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State>.Proxy) -> AnyView
    {
        let configuration = store.state.configuration

        return Self.exampleView(
            store: store,
            action: PhysicsRoot.Action.doublePendulum,
            statePath: /PhysicsRoot.State.Current.doublePendulum,
            makeView: {
                // Additionally draws track & rods.
                WorldView(store: $0, configuration: configuration, content: { store, configuration in
                    guard store.state.objects.count >= 2 else {
                        return AnyView(EmptyView())
                    }

                    let offset = Vector2(store.state.offset)

                    let trackPath = Path {
                        $0.addArc(
                            center: store.state.offset,
                            radius: CGFloat(store.state.objects[0].rodLength),
                            startAngle: .degrees(0),
                            endAngle: .degrees(360),
                            clockwise: false
                        )
                    }

                    @MainActor
                    func rodPath(index: Int) -> some View
                    {
                        let obj0 = store.state.objects[index * 2]
                        let obj1 = store.state.objects[index * 2 + 1]

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

                        ForEach(0 ..< store.state.objects.count / 2) {
                            rodPath(index: $0)
                        }

                        WorldView<Bob>.makeContentView(
                            store: store.canvasState,   
                            configuration: configuration,
                            absolutePosition: self.absolutePosition,
                            arrowScale: self.exampleArrowScale
                        )
                            .frame(maxWidth: nil, maxHeight: nil, alignment: .center)
                    }

                    return AnyView(zStack)
                })
            }
        )
    }
}

// MARK: - Algorithm

extension DoublePendulumExample: BobWorldExample
{
    func step(objects: inout [Bob], boardSize: CGSize, Δt: Scalar)
    {
        guard objects.count >= 2 else { return }

        // Runge-Kutta method.
        objects = rungeKutta(dt: Δt, f: diffEq, bobs: objects)
    }

    /// https://www.physicsandbox.com/projects/double-pendulum.html
    private func diffEq(objects: [Bob]) -> [ΔBob]
    {
        precondition(objects.count >= 2)

        var ΔBobs = [ΔBob](repeating: .empty, count: objects.count)

        for i in 0 ..< objects.count / 2 {
            let obj1 = objects[i * 2]
            let obj2 = objects[i * 2 + 1]
            let l1 = obj1.rodLength
            let l2 = obj2.rodLength
            let m1 = obj1.mass
            let m2 = obj2.mass
            let θ1 = obj1.angle
            let θ2 = obj2.angle
            let ω1 = obj1.angleVelocity
            let ω2 = obj2.angleVelocity
            let μ = 1 + m1 / m2

            let ω1ʹ, ω2ʹ: Scalar

            do {
                let x1 = g * sin(θ2) * cos(θ1 - θ2) - μ * sin(θ1)
                let x2 = (l2 * pow(ω2, 2) + l1 * pow(ω1, 2) * cos(θ1 - θ2)) * sin(θ1 - θ2)
                let denom = l1 * (μ - pow(cos(θ1 - θ2), 2))

                ω1ʹ = (x1 - x2) / denom
            }

            do {
                let x1 = μ * g * (sin(θ1) * cos(θ1 - θ2) - sin(θ2))
                let x2 = (μ * l1 * pow(ω1, 2) + l2 * pow(ω2, 2) * cos(θ1 - θ2)) * sin(θ1 - θ2)
                let denom = l2 * (μ - pow(cos(θ1 - θ2), 2))

                ω2ʹ = (x1 + x2) / denom
            }

            ΔBobs[i * 2] = .init(dθdt: ω1, dωdt: ω1ʹ)
            ΔBobs[i * 2 + 1] = .init(dθdt: ω2, dωdt: ω2ʹ)
        }

        return ΔBobs
    }

    /// https://www.myphysicslab.com/pendulum/double-pendulum-en.html
    /// - Note: Not used, just for reference (and this works too).
    private func __diffEq(objects: [Bob]) -> [ΔBob]
    {
        precondition(objects.count >= 2)

        var ΔBobs = [ΔBob](repeating: .empty, count: objects.count)

        for i in 0 ..< objects.count / 2 {
            let obj1 = objects[i * 2]
            let obj2 = objects[i * 2 + 1]
            let l1 = obj1.rodLength
            let l2 = obj2.rodLength
            let m1 = obj1.mass
            let m2 = obj2.mass
            let θ1 = obj1.angle
            let θ2 = obj2.angle
            let ω1 = obj1.angleVelocity
            let ω2 = obj2.angleVelocity

            let ω1ʹ, ω2ʹ: Scalar

            do {
                let x1 = -g * (2 * m1 + m2) * sin(θ1)
                let x2 = -m2 * g * sin(θ1 - 2 * θ2)
                let x3 = -2 * sin(θ1 - θ2) * m2
                let x4 = (pow(ω2, 2) * l2 + pow(ω1, 2) * l1 * cos(θ1 - θ2))
                let denom = l1 * (2 * m1 + m2 - m2 * cos(2 * θ1 - 2 * θ2))

                ω1ʹ = (x1 + x2 + x3 * x4) / denom
            }

            do {
                let x1 = 2 * sin(θ1 - θ2)
                let x2 = pow(ω1, 2) * l1 * (m1 + m2)
                let x3 = g * (m1 + m2) * cos(θ1)
                let x4 = pow(ω2, 2) * l2 * m2 * cos(θ1 - θ2)
                let denom = l2 * (2 * m1 + m2 - m2 * cos(2 * θ1 - 2 * θ2))

                ω2ʹ = x1 * (x2 + x3 + x4) / denom
            }

            ΔBobs[i * 2] = .init(dθdt: ω1, dωdt: ω1ʹ)
            ΔBobs[i * 2 + 1] = .init(dθdt: ω2, dωdt: ω2ʹ)
        }

        return ΔBobs
    }
}

// MARK: - Constants

/// Simulated constant of gravity at Earth's surface (`g = 9.807 m/s²` in real world)
private let g: Scalar = 1
