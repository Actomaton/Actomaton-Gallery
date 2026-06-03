import SwiftUI
import ActomatonUI
import VectorMath
import CanvasPlayer
import CanvasPlayerUI
import Physics

// SwiftUI presentation for the shared `PhysicsExampleID` (defined view-free in `Physics`).
// `PhysicsRootView` drives its example list from `PhysicsExampleID` the same way the WASM
// `PhysicsPage` does — only the rendering differs (SwiftUI here, `<canvas>` there).
//
// Rope / pendulum / spring-pendulum examples draw extra background "guide" overlays
// (rope curve, track arc, rods) behind the objects, mirroring the wasm `draw*Guides`.

extension PhysicsExampleID
{
    /// SF Symbol shown in the SwiftUI example list (mirrors the wasm Material Symbol `icon`).
    var exampleIcon: Image
    {
        switch self {
        case .gravityUniverse:
            return Image(systemName: "network")
        case .gravitySurface:
            return Image(systemName: "sunset")
        case .spring:
            return Image(systemName: "tornado")
        case .springPendulum:
            return Image(systemName: "metronome")
        case .rope:
            return Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
        case .collision,
            .lineCollision,
            .galtonBoard:
            return Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle")
        case .pendulum,
            .doublePendulum:
            return Image(systemName: "metronome")
        }
    }

    /// Builds the detail `WorldView` for this example by narrowing the parent store down to
    /// the matching `World.State<Obj>` case.
    @MainActor
    func detailView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>) -> AnyView
    {
        let configuration = store.viewStore.configuration

        switch self {
        case .gravityUniverse:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.gravityUniverse,
                             action: PhysicsRoot.Action.gravityUniverse)
        case .gravitySurface:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.gravitySurface,
                             action: PhysicsRoot.Action.gravitySurface)
        case .spring:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.spring,
                             action: PhysicsRoot.Action.spring)
        case .rope:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.rope,
                             action: PhysicsRoot.Action.rope,
                             guides: ropeGuides)
        case .collision:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.collision,
                             action: PhysicsRoot.Action.collision)
        case .lineCollision:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.lineCollision,
                             action: PhysicsRoot.Action.lineCollision)
        case .galtonBoard:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.galtonBoard,
                             action: PhysicsRoot.Action.galtonBoard)
        case .springPendulum:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.springPendulum,
                             action: PhysicsRoot.Action.springPendulum,
                             guides: springPendulumGuides)
        case .pendulum:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.pendulum,
                             action: PhysicsRoot.Action.pendulum,
                             guides: pendulumGuides)
        case .doublePendulum:
            return worldView(store: store, configuration: configuration,
                             statePath: /PhysicsRoot.State.Current.doublePendulum,
                             action: PhysicsRoot.Action.doublePendulum,
                             guides: doublePendulumGuides)
        }
    }

    /// - Parameter guides: Optional background overlay (drawn behind the objects), e.g. rope
    ///   curve / pendulum track + rods. `nil` renders just the objects + velocity/force arrows.
    @MainActor
    private func worldView<Obj>(
        store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>,
        configuration: WorldConfiguration,
        statePath: CasePath<PhysicsRoot.State.Current, World.State<Obj>>,
        action: @escaping (World.Action) -> PhysicsRoot.Action,
        guides: (@MainActor (ViewStore<World.Action, World.CanvasState<Obj>>) -> AnyView)? = nil
    ) -> AnyView
        where Obj: ObjectViewable & Equatable
    {
        guard let substore = store
            .map(state: \.current)
            .optionalize()?
            .caseMap(state: statePath)
            .optionalize()?
            .contramap(action: action)
        else {
            return AnyView(EmptyView())
        }

        let absolutePosition = self.absolutePosition
        let arrowScale = self.arrowScale

        guard let guides else {
            return AnyView(
                WorldView(
                    store: substore,
                    configuration: configuration,
                    absolutePosition: absolutePosition,
                    arrowScale: arrowScale
                )
            )
        }

        return AnyView(
            WorldView<Obj>(store: substore, configuration: configuration, content: { canvasStore, configuration in
                let canvasStateStore = canvasStore.map(state: \.canvasState)

                return ZStack(alignment: .topLeading) {
                    WithViewStore(canvasStateStore) { viewStore in
                        guides(viewStore)
                    }

                    WorldView<Obj>.makeContentView(
                        store: canvasStateStore,
                        configuration: configuration,
                        absolutePosition: absolutePosition,
                        arrowScale: arrowScale
                    )
                }
            })
        )
    }

    // MARK: - Guide overlays

    @MainActor
    private func ropeGuides(_ viewStore: ViewStore<World.Action, World.CanvasState<CircleObject>>) -> AnyView
    {
        guard viewStore.objects.count == 3 else { return AnyView(EmptyView()) }

        let offset = Vector2(CGPoint(viewStore.offset))
        let pos0 = offset + viewStore.objects[0].position
        let pos1 = offset + viewStore.objects[1].position
        let midPos = offset + viewStore.objects[2].position

        let ropePath = Path {
            $0.move(to: CGPoint(pos0))
            $0.addQuadCurve(to: CGPoint(pos1), control: CGPoint(midPos))
        }

        return AnyView(
            ropePath
                .stroke(Color.green, lineWidth: 1)
                .foregroundStyle(
                    .linearGradient(
                        colors: [.pink, .blue, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }

    @MainActor
    private func pendulumGuides(_ viewStore: ViewStore<World.Action, World.CanvasState<Bob>>) -> AnyView
    {
        let objects = viewStore.objects
        guard let first = objects.first else { return AnyView(EmptyView()) }

        let offsetPoint = CGPoint(viewStore.offset)
        let offset = Vector2(offsetPoint)

        let trackPath = Path {
            $0.addArc(
                center: offsetPoint,
                radius: CGFloat(first.rodLength),
                startAngle: .degrees(0),
                endAngle: .degrees(360),
                clockwise: false
            )
        }

        return AnyView(
            ZStack(alignment: .topLeading) {
                trackPath
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5]))

                ForEach(0 ..< objects.count, id: \.self) { index in
                    rodPath(from: offsetPoint, to: offset + objects[index].position)
                        .stroke(Color.green, lineWidth: 1)
                }
            }
        )
    }

    @MainActor
    private func doublePendulumGuides(_ viewStore: ViewStore<World.Action, World.CanvasState<Bob>>) -> AnyView
    {
        let objects = viewStore.objects
        guard objects.count >= 2 else { return AnyView(EmptyView()) }

        let offsetPoint = CGPoint(viewStore.offset)
        let offset = Vector2(offsetPoint)

        let trackPath = Path {
            $0.addArc(
                center: offsetPoint,
                radius: CGFloat(objects[0].rodLength),
                startAngle: .degrees(0),
                endAngle: .degrees(360),
                clockwise: false
            )
        }

        return AnyView(
            ZStack(alignment: .topLeading) {
                trackPath
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5]))

                ForEach(0 ..< objects.count / 2, id: \.self) { index in
                    let pos0 = offset + objects[index * 2].position
                    let pos1 = pos0 + objects[index * 2 + 1].position

                    Group {
                        rodPath(from: offsetPoint, to: pos0)
                            .stroke(Color.green, lineWidth: 1)

                        rodPath(from: CGPoint(pos0), to: pos1)
                            .stroke(Color.blue, lineWidth: 1)
                    }
                }
            }
        )
    }

    @MainActor
    private func springPendulumGuides(_ viewStore: ViewStore<World.Action, World.CanvasState<CircleObject>>) -> AnyView
    {
        let offset = Vector2(180, 0) // Pivot of the spring pendulum.
        let rodLength: Scalar = 300

        let trackPath = Path {
            $0.addArc(
                center: CGPoint(offset),
                radius: CGFloat(rodLength),
                startAngle: .degrees(30),
                endAngle: .degrees(150),
                clockwise: false
            )
        }

        let rodsPath = Path {
            for obj in viewStore.objects {
                $0.move(to: CGPoint(obj.position))
                $0.addLine(to: CGPoint(offset))
            }
        }

        return AnyView(
            ZStack(alignment: .topLeading) {
                trackPath
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5]))

                rodsPath
                    .stroke(Color.green, lineWidth: 1)
            }
        )
    }

    private func rodPath(from start: CGPoint, to end: Vector2) -> Path
    {
        Path {
            $0.move(to: start)
            $0.addLine(to: CGPoint(end))
        }
    }
}

extension PhysicsRoot.State.Current
{
    /// The example identity that produced this state, used to drive `NavigationLink` selection.
    var exampleID: PhysicsExampleID
    {
        switch self {
        case .gravityUniverse:
            return .gravityUniverse
        case .gravitySurface:
            return .gravitySurface
        case .spring:
            return .spring
        case .rope:
            return .rope
        case .collision:
            return .collision
        case .lineCollision:
            return .lineCollision
        case .galtonBoard:
            return .galtonBoard
        case .springPendulum:
            return .springPendulum
        case .pendulum:
            return .pendulum
        case .doublePendulum:
            return .doublePendulum
        }
    }
}
