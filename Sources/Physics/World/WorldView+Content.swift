import SwiftUI
import ActomatonStore
import CommonUI
import VectorMath

extension WorldView
{
    /// Initializer with default `content`.
    /// - Note: Makes contents, UI controls, etc.
    init(
        store: Store<World.Action, World.State<Obj>, Void>.Proxy,
        configuration: WorldConfiguration,
        absolutePosition: ((_ relativePosition: Vector2, _ index: Int, _ previous: Vector2) -> Vector2)?,
        arrowScale: ArrowScale
    )
    {
        self.store = store
        self.configuration = configuration

        self.content = { store, configuration in
            return AnyView(
                Self.makeContentView(
                    store: store.canvasState,
                    configuration: configuration,
                    absolutePosition: absolutePosition,
                    arrowScale: arrowScale
                )
            )
        }
    }

    /// Makes contents i.e. `objects`, `velocityArrows`, `forceArrows`.
    @MainActor
    static func makeContentView(
        store: Store<World.Action, World.CanvasState<Obj>, Void>.Proxy,
        configuration: WorldConfiguration,
        absolutePosition: ((_ relativePosition: Vector2, _ index: Int, _ previous: Vector2) -> Vector2)?,
        arrowScale: ArrowScale
    ) -> some View
    {
        let objects: [AbsObj<Obj>] = {
            guard let absolutePosition = absolutePosition else {
                // `object`'s relative position as absolute position.
                return store.state.objects
                    .map { AbsObj(object: $0, absolutePosition: $0.position) }
            }

            var objects: [AbsObj<Obj>] = []
            var prevPosition: Vector2 = .zero

            for i in 0 ..< store.state.objects.count {
                let obj = store.state.objects[i]
                let position = absolutePosition(obj.position, i, prevPosition)
                prevPosition = position

                objects.append(AbsObj(object: obj, absolutePosition: position))
            }

            return objects
        }()

        let offset = store.state.offset
        
        return ZStack(alignment: .topLeading) {
            Self.objectsView(
                objects: objects,
                offset: offset
            )

            if configuration.showsVelocityArrows {
                Self.velocityArrowsView(
                    objects: objects,
                    offset: offset,
                    scale: arrowScale.velocityArrowScale
                )
            }

            if configuration.showsForceArrows {
                Self.forceArrowsView(
                    objects: objects,
                    offset: offset,
                    scale: arrowScale.forceArrowScale
                )
            }
        }
    }

    /// Makes circle objects.
    @MainActor
    private static func objectsView(
        objects: [AbsObj<Obj>],
        offset: CGPoint
    ) -> some View
    {
        let offset = Vector2(offset)

        return ForEach(objects, id: \.object.id) { absObj in
            let obj = absObj.object
            let absPos = absObj.absolutePosition

            obj.makeView(absolutePosition: CGPoint(absPos + offset))
        }
    }

    /// Makes velocity arrows.
    @MainActor
    private static func velocityArrowsView(
        objects: [AbsObj<Obj>],
        offset: CGPoint,
        scale: Scalar
    ) -> some View
    {
        let offset = Vector2(offset)

        return ForEach(objects, id: \.object.id) { absObj in
            let obj = absObj.object
            let absPos = absObj.absolutePosition
            let adjustedVelocity = obj.velocity * scale

            Path.arrowPath(
                start: CGPoint(absPos + offset),
                end: CGPoint(absPos + offset + adjustedVelocity),
                pointerLength: CGFloat(adjustedVelocity.length) / 5,
                arrowAngle: CGFloat(Double.pi / 4)
            )
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2))
        }
    }

    /// Makes force arrows.
    @MainActor
    private static func forceArrowsView(
        objects: [AbsObj<Obj>],
        offset: CGPoint,
        scale: Scalar
    ) -> some View
    {
        let offset = Vector2(offset)

        return ForEach(objects, id: \.object.id) { absObj in
            let obj = absObj.object
            let absPos = absObj.absolutePosition
            let adjustedForce = obj.force * scale

            Path.arrowPath(
                start: CGPoint(absPos + offset),
                end: CGPoint(absPos + offset + adjustedForce),
                pointerLength: CGFloat(adjustedForce.length) / 5,
                arrowAngle: CGFloat(Double.pi / 4)
            )
                .stroke(Color.red, style: StrokeStyle(lineWidth: 2))
        }
    }
}

// MARK: - Private

/// Object with absolute position that is calculated from previous object.
private struct AbsObj<Obj: ObjectLike>
{
    var object: Obj
    var absolutePosition: Vector2
}
