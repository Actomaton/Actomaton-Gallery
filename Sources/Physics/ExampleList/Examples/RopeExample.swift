import SwiftUI
import ActomatonUI
import VectorMath

/// https://twitter.com/DLX/status/1544373383915356167
/// https://zenn.dev/ikeh1024/articles/3afefda9bf4777
struct RopeExample: Example
{
    var exampleIcon: Image { Image(systemName: "figure.jumprope") }

    var exampleInitialState: PhysicsRoot.State.Current
    {
        .rope(World.State(objects: [
            CircleObject(mass: 1, position: .init(50, 200), velocity: .init(0, 0)), // obj0
            CircleObject(mass: 1, position: .init(390 - 50, 200), velocity: .init(0, 0)), // obj1
            CircleObject(mass: 1, position: .init(390 / 2, 200), velocity: .init(0, 0)), // midObj
        ]))
    }

    var exampleArrowScale: ArrowScale
    {
        .init(velocityArrowScale: 10, forceArrowScale: 300)
    }

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>) -> AnyView
    {
        let configuration = store.viewStore.configuration

        return Self.exampleView(
            store: store,
            action: PhysicsRoot.Action.rope,
            statePath: /PhysicsRoot.State.Current.rope,
            makeView: { store in
                // Additionally draws rope path.
                WorldView<CircleObject>(store: store, configuration: configuration, content: { store, configuration in
                    WithViewStore(store) { viewStore -> AnyView in
                        guard viewStore.objects.count == 3 else {
                            return AnyView(EmptyView())
                        }
                        let offset = Vector2(viewStore.offset)

                        @MainActor
                        func ropePath() -> Path
                        {
                            let obj0 = viewStore.objects[obj0Index]
                            let obj1 = viewStore.objects[obj1Index]
                            let midObj = viewStore.objects[midObjIndex]

                            let pos0 = offset + obj0.position
                            let pos1 = offset + obj1.position
                            let midPos = offset + midObj.position

                            let path = Path {
                                $0.move(to: CGPoint(pos0))
                                $0.addQuadCurve(to: CGPoint(pos1), control: CGPoint(midPos))
                            }

                            return path
                        }

                        let zStack = ZStack(alignment: .topLeading) {
                            if #available(iOS 15.0, *) {
                                ropePath()
                                    .stroke(Color.green, lineWidth: 1)
                                    .foregroundStyle(
                                        .linearGradient(
                                            colors: [.pink, .blue, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            else {
                                ropePath()
                                    .stroke(Color.green, lineWidth: 1)
                            }

                            WorldView<CircleObject>.makeContentView(
                                store: store.map(state: \.canvasState),
                                configuration: configuration,
                                absolutePosition: self.absolutePosition,
                                arrowScale: self.exampleArrowScale
                            )
                        }

                        return AnyView(zStack)
                    }
                })
            }
        )
    }
}

// MARK: - Algorithm

extension RopeExample: ObjectWorldExample
{
    func step(objects: inout [CircleObject], boardSize: CGSize)
    {
        let objectCount = objects.count

        guard objectCount == 3 else { return }

        let obj0 = objects[obj0Index]
        let obj1 = objects[obj1Index]
        let midObj = objects[midObjIndex] // Control point for quad-bezier.

        let objPosDiff = obj1.position - obj0.position
        let objDistance = objPosDiff.length

        let decline = max(0, ropeLength - objDistance / 2)

        let staticMidPos = Vector2(
            obj0.position.x + objPosDiff.x / 2,
            obj0.position.y + objPosDiff.y / 2 + decline
        )

        let midPosDiff = staticMidPos - midObj.position

        objects[midObjIndex].force = Vector2(
            c.k * midPosDiff.x - midObj.velocity.x * c.damping,
            c.k * midPosDiff.y - midObj.velocity.y * c.damping
        )
    }

    func exampleTapToMakeObject(point: CGPoint) -> CircleObject?
    {
        // Don't create new object on tap (always 2 object with 1 control point).
        nil
    }
}

// MARK: - Types

private struct Constants
{
    /// Simulated spring constant.
    let k: Scalar

    /// Simulated spring dumping constant.
    let damping: Scalar
}

// MARK: - Constants

private let c: Constants = .init(k: 0.01, damping: 0.05)

private let obj0Index: Int = 0
private let obj1Index: Int = 1
private let midObjIndex: Int = 2 // Control point for quad-bezier.

private let ropeLength: Scalar = 400
