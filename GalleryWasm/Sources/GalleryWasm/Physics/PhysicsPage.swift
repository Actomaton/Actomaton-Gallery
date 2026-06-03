import ElementaryUI
import Geometry
import JavaScriptKit
import Physics
import VectorMath

@View
struct PhysicsPage
{
    private static let canvasID = "physics-canvas"

    @State var machine: PhysicsDemoMachine
    @State var selectedExample: PhysicsExampleID = .gravityUniverse
    @State var sizeObserver = CanvasSizeObserver()
    @State var pointerObserver = PhysicsCanvasPointerObserver()
    @State var canvasWidth: Double = 0
    @State var canvasHeight: Double = 0

    init()
    {
        _machine = State(wrappedValue: makePhysicsDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "Physics" }
            h2(.class("counter-heading")) { "Physics Examples" }
            p(.class("counter-copy")) {
                "Object, collision, rope, and pendulum simulations rendered on a browser canvas with shared Physics."
            }

            div(.class("physics-layout")) {
                div(.class("physics-picker")) {
                    PhysicsExampleSectionPicker(
                        title: PhysicsExampleSection.objectWorld.title,
                        examples: PhysicsExampleID.objectWorldExamples,
                        selectedExample: selectedExample,
                        onSelect: selectExample
                    )

                    PhysicsExampleSectionPicker(
                        title: PhysicsExampleSection.pendulumWorld.title,
                        examples: PhysicsExampleID.pendulumWorldExamples,
                        selectedExample: selectedExample,
                        onSelect: selectExample
                    )
                }

                div(.class("physics-stage")) {
                    div(.class("physics-toolbar")) {
                        if machine.state.physics.current?.isRunningTimer == true {
                            button(.type(.button), .class("counter-action")) { "Pause" }
                                .onClick { _ in sendWorldAction(.stopTimer) }
                        }
                        else {
                            button(.type(.button), .class("counter-action is-primary")) { "Play" }
                                .onClick { _ in sendWorldAction(.startTimer) }
                        }

                        button(.type(.button), .class("counter-action")) { "Step" }
                            .onClick { _ in sendWorldAction(.tick) }

                        button(.type(.button), .class("counter-action")) { "Reset" }
                            .onClick { _ in sendWorldAction(.resetCanvas) }
                    }

                    div(.class("physics-toolbar")) {
                        button(
                            .type(.button),
                            .class(machine.state.physics.configuration.showsVelocityArrows ? "physics-toggle is-selected" : "physics-toggle")
                        ) { "Velocity" }
                            .onClick { _ in
                                machine.state.physics.configuration.showsVelocityArrows.toggle()
                                redraw()
                            }

                        button(
                            .type(.button),
                            .class(machine.state.physics.configuration.showsForceArrows ? "physics-toggle is-selected" : "physics-toggle")
                        ) { "Force" }
                            .onClick { _ in
                                machine.state.physics.configuration.showsForceArrows.toggle()
                                redraw()
                            }

                        PhysicsDeltaSlider(
                            value: Double(machine.state.physics.Δt),
                            onChange: { value in
                                machine.send(.changeΔt(Scalar(value)))
                                redraw()
                            }
                        )
                    }

                    canvas(
                        .custom(name: "id", value: Self.canvasID),
                        .class("physics-canvas")
                    ) { "" }
                        .onAppear {
                            sizeObserver.start(canvasID: Self.canvasID) { width, height in
                                canvasWidth = width
                                canvasHeight = height
                                sendCanvasSize(redrawAfterSend: false)
                                redraw()
                            }

                            pointerObserver.start(
                                canvasID: Self.canvasID,
                                onTap: { x, y in
                                    sendWorldAction(.tap(viewport.modelPoint(x: x, y: y)))
                                },
                                onDrag: { x, y in
                                    sendWorldAction(.dragging(viewport.modelPoint(x: x, y: y)))
                                },
                                onDragEnd: {
                                    sendWorldAction(.dragEnd)
                                }
                            )

                            sendWorldAction(.startTimer, redrawAfterSend: false)
                        }
                        .onChange(of: machine.state.physics.current, initial: true) {
                            redraw()
                        }
                        .onChange(of: machine.state.physics.configuration) {
                            redraw()
                        }
                }
            }
        }
    }

    private func selectExample(_ example: PhysicsExampleID)
    {
        selectedExample = example
        machine.send(.changeCurrent(example.initialState))
        sendCanvasSize(redrawAfterSend: false)
        sendWorldAction(.startTimer, redrawAfterSend: false)
        redraw()
    }

    private func sendCanvasSize(redrawAfterSend: Bool = true)
    {
        guard canvasWidth > 0, canvasHeight > 0 else { return }

        sendWorldAction(
            .updateCanvasSize(viewport.modelSize),
            redrawAfterSend: redrawAfterSend
        )
    }

    private func sendWorldAction(_ action: World.Action, redrawAfterSend: Bool = true)
    {
        machine.send(selectedExample.rootAction(action))

        if redrawAfterSend {
            redraw()
        }
    }

    private func redraw()
    {
        redrawPhysicsCanvas(
            machine: machine,
            selectedExample: selectedExample,
            canvasID: Self.canvasID
        )
    }

    private var viewport: PhysicsViewport
    {
        PhysicsViewport(canvasWidth: canvasWidth, canvasHeight: canvasHeight, selectedExample: selectedExample)
    }
}

@View
private struct PhysicsExampleSectionPicker
{
    let title: String
    let examples: [PhysicsExampleID]
    let selectedExample: PhysicsExampleID
    let onSelect: (PhysicsExampleID) -> Void

    var body: some View
    {
        div(.class("physics-picker-section")) {
            p(.class("physics-picker-label")) { title }

            for example in examples {
                PhysicsExamplePickerButton(
                    example: example,
                    isSelected: selectedExample == example,
                    onSelect: { onSelect(example) }
                )
            }
        }
    }
}

@View
private struct PhysicsExamplePickerButton
{
    let example: PhysicsExampleID
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View
    {
        button(
            .type(.button),
            .class(isSelected ? "physics-example-button is-selected" : "physics-example-button")
        ) {
            span(.class("material-symbols-outlined physics-example-icon")) { example.icon }
            span { example.title }
        }
        .onClick { _ in onSelect() }
    }
}

@View
private struct PhysicsDeltaSlider
{
    let value: Double
    let onChange: (Double) -> Void

    var body: some View
    {
        label(.class("physics-slider")) {
            span { "dt" }
            input(
                .custom(name: "type", value: "range"),
                .custom(name: "min", value: "0.01"),
                .custom(name: "max", value: "1"),
                .custom(name: "step", value: "0.01")
            )
            .bindValue(
                Binding<Double?>(
                    get: { value },
                    set: { onChange($0 ?? 1) }
                )
            )
        }
    }
}

// MARK: - Rendering

private struct AbsoluteObject<Obj: ObjectLike>
{
    var object: Obj
    var position: Vector2
}

private struct PhysicsViewport
{
    private static let defaultModelWidth = 360.0
    private static let lineCollisionModelWidth = 400.0
    private static let modelHeight = 400.0

    let canvasWidth: Double
    let canvasHeight: Double
    let modelWidth: Double
    let modelHeight: Double
    let offsetX: Double
    let offsetY: Double
    let scale: Double

    init(canvasWidth: Double, canvasHeight: Double, selectedExample: PhysicsExampleID)
    {
        let modelWidth = selectedExample == .lineCollision ? Self.lineCollisionModelWidth : Self.defaultModelWidth
        let modelHeight = Self.modelHeight
        let scale = min(canvasWidth / modelWidth, canvasHeight / modelHeight)

        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.modelWidth = modelWidth
        self.modelHeight = modelHeight
        self.offsetX = (canvasWidth - modelWidth * scale) / 2
        self.offsetY = (canvasHeight - modelHeight * scale) / 2
        self.scale = scale
    }

    var modelSize: Size
    {
        Size(width: modelWidth, height: modelHeight)
    }

    func screenX(_ x: Double) -> Double
    {
        offsetX + x * scale
    }

    func screenY(_ y: Double) -> Double
    {
        offsetY + y * scale
    }

    func screenPoint(_ position: Vector2, offset: Point = .zero) -> (x: Double, y: Double)
    {
        (
            x: screenX(Double(position.x) + offset.x),
            y: screenY(Double(position.y) + offset.y)
        )
    }

    func screenRadius(_ radius: Scalar) -> Double
    {
        Double(radius) * scale
    }

    func modelPoint(x: Double, y: Double) -> Point
    {
        Point(
            x: scale > 0 ? (x - offsetX) / scale : x,
            y: scale > 0 ? (y - offsetY) / scale : y
        )
    }
}

private func redrawPhysicsCanvas(machine: PhysicsDemoMachine, selectedExample: PhysicsExampleID, canvasID: String)
{
    guard let canvasNode = JSObject.global.document.object?.getElementById?(canvasID).object,
        let context = canvasNode.getContext?("2d").object
    else {
        return
    }

    let bufferWidth = canvasNode.width.number ?? 0
    let bufferHeight = canvasNode.height.number ?? 0

    context.fillStyle = .string("#101820")
    _ = context.fillRect?(0, 0, bufferWidth, bufferHeight)

    let viewport = PhysicsViewport(
        canvasWidth: bufferWidth,
        canvasHeight: bufferHeight,
        selectedExample: selectedExample
    )

    context.strokeStyle = .string("rgba(255, 255, 255, 0.08)")
    context.lineWidth = .number(1)
    let stageLeft = viewport.offsetX
    let stageTop = viewport.offsetY
    let stageRight = viewport.offsetX + viewport.modelWidth * viewport.scale
    let stageBottom = viewport.offsetY + viewport.modelHeight * viewport.scale
    for modelX in stride(from: 0.0, through: viewport.modelWidth, by: 48.0) {
        let x = viewport.screenX(modelX)
        _ = context.beginPath?()
        _ = context.moveTo?(x, stageTop)
        _ = context.lineTo?(x, stageBottom)
        _ = context.stroke?()
    }
    for modelY in stride(from: 0.0, through: viewport.modelHeight, by: 48.0) {
        let y = viewport.screenY(modelY)
        _ = context.beginPath?()
        _ = context.moveTo?(stageLeft, y)
        _ = context.lineTo?(stageRight, y)
        _ = context.stroke?()
    }
    context.strokeStyle = .string("rgba(122, 230, 160, 0.18)")
    context.lineWidth = .number(1)
    _ = context.strokeRect?(stageLeft, stageTop, stageRight - stageLeft, stageBottom - stageTop)

    guard let current = machine.state.physics.current else { return }
    let configuration = machine.state.physics.configuration

    switch current {
    case let .gravityUniverse(state),
        let .gravitySurface(state),
        let .spring(state),
        let .collision(state),
        let .galtonBoard(state):
        drawCircleWorld(
            context: context,
            canvasState: state.canvasPlayerState.canvasState,
            viewport: viewport,
            selectedExample: selectedExample,
            configuration: configuration
        )

    case let .rope(state):
        let canvasState = state.canvasPlayerState.canvasState
        drawRopePath(context: context, canvasState: canvasState, viewport: viewport)
        drawCircleWorld(
            context: context,
            canvasState: canvasState,
            viewport: viewport,
            selectedExample: selectedExample,
            configuration: configuration
        )

    case let .springPendulum(state):
        let canvasState = state.canvasPlayerState.canvasState
        drawSpringPendulumGuides(context: context, canvasState: canvasState, viewport: viewport)
        drawCircleWorld(
            context: context,
            canvasState: canvasState,
            viewport: viewport,
            selectedExample: selectedExample,
            configuration: configuration
        )

    case let .lineCollision(state):
        drawObjectWorld(
            context: context,
            canvasState: state.canvasPlayerState.canvasState,
            viewport: viewport,
            selectedExample: selectedExample,
            configuration: configuration
        )

    case let .pendulum(state):
        let canvasState = state.canvasPlayerState.canvasState
        drawPendulumGuides(context: context, canvasState: canvasState, viewport: viewport)
        drawBobWorld(
            context: context,
            canvasState: canvasState,
            viewport: viewport,
            selectedExample: selectedExample,
            configuration: configuration
        )

    case let .doublePendulum(state):
        let canvasState = state.canvasPlayerState.canvasState
        drawDoublePendulumGuides(context: context, canvasState: canvasState, viewport: viewport)
        drawBobWorld(
            context: context,
            canvasState: canvasState,
            viewport: viewport,
            selectedExample: selectedExample,
            configuration: configuration
        )
    }
}

private func drawCircleWorld(
    context: JSObject,
    canvasState: World.CanvasState<CircleObject>,
    viewport: PhysicsViewport,
    selectedExample: PhysicsExampleID,
    configuration: WorldConfiguration
)
{
    let objects = absoluteObjects(canvasState.objects, selectedExample: selectedExample)
    let offset = canvasState.offset

    for object in objects {
        let point = viewport.screenPoint(object.position, offset: offset)
        drawCircle(
            context: context,
            object: object.object,
            x: point.x,
            y: point.y,
            radius: viewport.screenRadius(object.object.radius)
        )
    }

    drawArrows(
        context: context,
        objects: objects,
        offset: offset,
        viewport: viewport,
        selectedExample: selectedExample,
        configuration: configuration
    )
}

private func drawObjectWorld(
    context: JSObject,
    canvasState: World.CanvasState<Object>,
    viewport: PhysicsViewport,
    selectedExample: PhysicsExampleID,
    configuration: WorldConfiguration
)
{
    let objects = absoluteObjects(canvasState.objects, selectedExample: selectedExample)
    let offset = canvasState.offset

    for object in objects {
        switch object.object {
        case let .line(line):
            drawLine(context: context, line: line, offset: offset, viewport: viewport)
        case .circle:
            break
        }
    }

    for object in objects {
        switch object.object {
        case let .circle(circle):
            let point = viewport.screenPoint(object.position, offset: offset)
            drawCircle(
                context: context,
                object: circle,
                x: point.x,
                y: point.y,
                radius: viewport.screenRadius(circle.radius)
            )
        case .line:
            break
        }
    }

    drawArrows(
        context: context,
        objects: objects,
        offset: offset,
        viewport: viewport,
        selectedExample: selectedExample,
        configuration: configuration
    )
}

private func drawBobWorld(
    context: JSObject,
    canvasState: World.CanvasState<Bob>,
    viewport: PhysicsViewport,
    selectedExample: PhysicsExampleID,
    configuration: WorldConfiguration
)
{
    let objects = absoluteObjects(canvasState.objects, selectedExample: selectedExample)
    let offset = canvasState.offset

    for object in objects {
        let point = viewport.screenPoint(object.position, offset: offset)
        drawBob(
            context: context,
            bob: object.object,
            x: point.x,
            y: point.y,
            radius: viewport.screenRadius(object.object.radius)
        )
    }

    drawArrows(
        context: context,
        objects: objects,
        offset: offset,
        viewport: viewport,
        selectedExample: selectedExample,
        configuration: configuration
    )
}

private func absoluteObjects<Obj: ObjectLike>(
    _ objects: [Obj],
    selectedExample: PhysicsExampleID
) -> [AbsoluteObject<Obj>]
{
    guard let absolutePosition = selectedExample.absolutePosition else {
        return objects.map { AbsoluteObject(object: $0, position: $0.position) }
    }

    var result: [AbsoluteObject<Obj>] = []
    var previous = Vector2.zero

    for index in objects.indices {
        let object = objects[index]
        let position = absolutePosition(object.position, index, previous)
        previous = position
        result.append(AbsoluteObject(object: object, position: position))
    }

    return result
}

private func drawCircle(context: JSObject, object: CircleObject, x: Double, y: Double, radius: Double)
{
    _ = context.beginPath?()
    _ = context.arc?(x, y, radius, 0, Double.pi * 2)
    context.fillStyle = .string(object.isStatic ? "#7aa88a" : "#78e6a0")
    _ = context.fill?()
}

private func drawBob(context: JSObject, bob: Bob, x: Double, y: Double, radius: Double)
{
    _ = context.beginPath?()
    _ = context.arc?(x, y, radius, 0, Double.pi * 2)
    context.fillStyle = .string("#78e6a0")
    _ = context.fill?()
}

private func drawLine(context: JSObject, line: LineObject, offset: Point, viewport: PhysicsViewport)
{
    let start = viewport.screenPoint(line.startPosition, offset: offset)
    let end = viewport.screenPoint(line.endPosition, offset: offset)

    context.strokeStyle = .string(line.isFinalized ? "#ff7878" : "#ffd166")
    context.lineWidth = .number(Double(line.width) * viewport.scale)
    context.lineCap = .string("round")
    _ = context.beginPath?()
    _ = context.moveTo?(start.x, start.y)
    _ = context.lineTo?(end.x, end.y)
    _ = context.stroke?()
    context.lineCap = .string("butt")
}

private func drawArrows<Obj: ObjectLike>(
    context: JSObject,
    objects: [AbsoluteObject<Obj>],
    offset: Point,
    viewport: PhysicsViewport,
    selectedExample: PhysicsExampleID,
    configuration: WorldConfiguration
)
{
    let scale = selectedExample.arrowScale

    if configuration.showsVelocityArrows, scale.velocityArrowScale != 0 {
        for object in objects {
            let start = viewport.screenPoint(object.position, offset: offset)
            let end = viewport.screenPoint(
                object.position + object.object.velocity * scale.velocityArrowScale,
                offset: offset
            )
            drawArrow(
                context: context,
                startX: start.x,
                startY: start.y,
                endX: end.x,
                endY: end.y,
                color: "#4ea1ff"
            )
        }
    }

    if configuration.showsForceArrows, scale.forceArrowScale != 0 {
        for object in objects {
            let start = viewport.screenPoint(object.position, offset: offset)
            let end = viewport.screenPoint(
                object.position + object.object.force * scale.forceArrowScale,
                offset: offset
            )
            drawArrow(
                context: context,
                startX: start.x,
                startY: start.y,
                endX: end.x,
                endY: end.y,
                color: "#ff6b6b"
            )
        }
    }
}

private func drawArrow(
    context: JSObject,
    startX: Double,
    startY: Double,
    endX: Double,
    endY: Double,
    color: String
)
{
    let dx = endX - startX
    let dy = endY - startY
    let length = (dx * dx + dy * dy).squareRoot()
    guard length > 0.5 else { return }

    let unitX = dx / length
    let unitY = dy / length
    let perpX = -unitY
    let perpY = unitX
    let headLength = min(12, max(5, length * 0.22))
    let headWidth = headLength * 0.45

    context.strokeStyle = .string(color)
    context.fillStyle = .string(color)
    context.lineWidth = .number(2)
    _ = context.beginPath?()
    _ = context.moveTo?(startX, startY)
    _ = context.lineTo?(endX, endY)
    _ = context.stroke?()

    _ = context.beginPath?()
    _ = context.moveTo?(endX, endY)
    _ = context.lineTo?(endX - unitX * headLength + perpX * headWidth, endY - unitY * headLength + perpY * headWidth)
    _ = context.lineTo?(endX - unitX * headLength - perpX * headWidth, endY - unitY * headLength - perpY * headWidth)
    _ = context.closePath?()
    _ = context.fill?()
}

private func drawRopePath(context: JSObject, canvasState: World.CanvasState<CircleObject>, viewport: PhysicsViewport)
{
    guard canvasState.objects.count == 3 else { return }

    let offset = canvasState.offset
    let obj0 = canvasState.objects[0]
    let obj1 = canvasState.objects[1]
    let midObj = canvasState.objects[2]
    let start = viewport.screenPoint(obj0.position, offset: offset)
    let control = viewport.screenPoint(midObj.position, offset: offset)
    let end = viewport.screenPoint(obj1.position, offset: offset)

    context.strokeStyle = .string("#9af7c0")
    context.lineWidth = .number(2 * viewport.scale)
    _ = context.beginPath?()
    _ = context.moveTo?(start.x, start.y)
    _ = context.quadraticCurveTo?(
        control.x,
        control.y,
        end.x,
        end.y
    )
    _ = context.stroke?()
}

private func drawSpringPendulumGuides(context: JSObject, canvasState: World.CanvasState<CircleObject>, viewport: PhysicsViewport)
{
    let pivot = viewport.screenPoint(Vector2(180, 0))
    let rodLength = 300.0

    context.strokeStyle = .string("rgba(122, 230, 160, 0.55)")
    context.lineWidth = .number(2 * viewport.scale)
    _ = context.beginPath?()
    _ = context.arc?(pivot.x, pivot.y, rodLength * viewport.scale, Double.pi / 6, Double.pi * 5 / 6)
    _ = context.stroke?()

    context.strokeStyle = .string("rgba(122, 230, 160, 0.65)")
    context.lineWidth = .number(viewport.scale)
    for object in canvasState.objects {
        let point = viewport.screenPoint(object.position)
        _ = context.beginPath?()
        _ = context.moveTo?(pivot.x, pivot.y)
        _ = context.lineTo?(point.x, point.y)
        _ = context.stroke?()
    }
}

private func drawPendulumGuides(context: JSObject, canvasState: World.CanvasState<Bob>, viewport: PhysicsViewport)
{
    guard let first = canvasState.objects.first else { return }

    let offset = canvasState.offset
    let pivot = viewport.screenPoint(Vector2(0, 0), offset: offset)
    context.strokeStyle = .string("rgba(122, 230, 160, 0.45)")
    context.lineWidth = .number(2 * viewport.scale)
    _ = context.beginPath?()
    _ = context.arc?(pivot.x, pivot.y, Double(first.rodLength) * viewport.scale, 0, Double.pi * 2)
    _ = context.stroke?()

    context.strokeStyle = .string("rgba(122, 230, 160, 0.8)")
    context.lineWidth = .number(viewport.scale)
    for object in canvasState.objects {
        let point = viewport.screenPoint(object.position, offset: offset)
        _ = context.beginPath?()
        _ = context.moveTo?(pivot.x, pivot.y)
        _ = context.lineTo?(point.x, point.y)
        _ = context.stroke?()
    }
}

private func drawDoublePendulumGuides(context: JSObject, canvasState: World.CanvasState<Bob>, viewport: PhysicsViewport)
{
    guard canvasState.objects.count >= 2 else { return }

    let offset = canvasState.offset
    let pivot = viewport.screenPoint(Vector2(0, 0), offset: offset)
    context.strokeStyle = .string("rgba(122, 230, 160, 0.45)")
    context.lineWidth = .number(2 * viewport.scale)
    _ = context.beginPath?()
    _ = context.arc?(pivot.x, pivot.y, Double(canvasState.objects[0].rodLength) * viewport.scale, 0, Double.pi * 2)
    _ = context.stroke?()

    for index in 0 ..< canvasState.objects.count / 2 {
        let obj0 = canvasState.objects[index * 2]
        let obj1 = canvasState.objects[index * 2 + 1]
        let offsetVector = Vector2(Scalar(offset.x), Scalar(offset.y))
        let firstPoint = viewport.screenPoint(offsetVector + obj0.position)
        let secondPoint = viewport.screenPoint(offsetVector + obj0.position + obj1.position)

        context.strokeStyle = .string("rgba(122, 230, 160, 0.8)")
        context.lineWidth = .number(viewport.scale)
        _ = context.beginPath?()
        _ = context.moveTo?(pivot.x, pivot.y)
        _ = context.lineTo?(firstPoint.x, firstPoint.y)
        _ = context.stroke?()

        context.strokeStyle = .string("rgba(78, 161, 255, 0.8)")
        _ = context.beginPath?()
        _ = context.moveTo?(firstPoint.x, firstPoint.y)
        _ = context.lineTo?(secondPoint.x, secondPoint.y)
        _ = context.stroke?()
    }
}

// MARK: - Current helpers

private extension PhysicsRoot.State.Current
{
    var isRunningTimer: Bool
    {
        switch self {
        case let .gravityUniverse(state),
            let .gravitySurface(state),
            let .spring(state),
            let .rope(state),
            let .collision(state),
            let .galtonBoard(state),
            let .springPendulum(state):
            return state.canvasPlayerState.isRunningTimer

        case let .lineCollision(state):
            return state.canvasPlayerState.isRunningTimer

        case let .pendulum(state),
            let .doublePendulum(state):
            return state.canvasPlayerState.isRunningTimer
        }
    }
}

// MARK: - PhysicsCanvasPointerObserver

final class PhysicsCanvasPointerObserver
{
    private var isDragging = false
    private var startPoint: (x: Double, y: Double)?
    private var lastPoint: (x: Double, y: Double)?
    private var pointerDownClosure: JSClosure?
    private var pointerMoveClosure: JSClosure?
    private var pointerUpClosure: JSClosure?
    private var pointerCancelClosure: JSClosure?

    func start(
        canvasID: String,
        onTap: @escaping (Double, Double) -> Void,
        onDrag: @escaping (Double, Double) -> Void,
        onDragEnd: @escaping () -> Void
    )
    {
        guard pointerDownClosure == nil,
            let canvas = Self.element(canvasID)
        else {
            return
        }

        let pointerDownClosure = JSClosure { [weak self] arguments in
            guard let self,
                let event = arguments.first?.object
            else {
                return .undefined
            }

            _ = event.preventDefault?()
            self.isDragging = true

            if let pointerID = event.pointerId.number {
                _ = canvas.setPointerCapture?(pointerID)
            }

            let point = Self.point(from: event)
            self.startPoint = point
            self.lastPoint = point
            return .undefined
        }

        let pointerMoveClosure = JSClosure { [weak self] arguments in
            guard let self,
                self.isDragging,
                let event = arguments.first?.object
            else {
                return .undefined
            }

            _ = event.preventDefault?()
            let point = Self.point(from: event)
            self.lastPoint = point
            onDrag(point.x, point.y)
            return .undefined
        }

        let pointerUpClosure = JSClosure { [weak self] arguments in
            guard let self else { return .undefined }

            var point = self.lastPoint
            if let event = arguments.first?.object {
                _ = event.preventDefault?()
                point = Self.point(from: event)

                if let pointerID = event.pointerId.number {
                    _ = canvas.releasePointerCapture?(pointerID)
                }
            }

            self.endDrag(point: point, onTap: onTap, onDragEnd: onDragEnd)
            return .undefined
        }

        let pointerCancelClosure = JSClosure { [weak self] _ in
            self?.cancelDrag(onDragEnd: onDragEnd)
            return .undefined
        }

        _ = canvas.addEventListener?("pointerdown", pointerDownClosure)
        _ = canvas.addEventListener?("pointermove", pointerMoveClosure)
        _ = canvas.addEventListener?("pointerup", pointerUpClosure)
        _ = canvas.addEventListener?("pointercancel", pointerCancelClosure)
        _ = canvas.addEventListener?("pointerleave", pointerCancelClosure)

        self.pointerDownClosure = pointerDownClosure
        self.pointerMoveClosure = pointerMoveClosure
        self.pointerUpClosure = pointerUpClosure
        self.pointerCancelClosure = pointerCancelClosure
    }

    private func endDrag(
        point: (x: Double, y: Double)?,
        onTap: (Double, Double) -> Void,
        onDragEnd: () -> Void
    )
    {
        guard isDragging else { return }

        let startPoint = self.startPoint
        self.isDragging = false
        self.startPoint = nil
        self.lastPoint = nil

        defer { onDragEnd() }

        guard let startPoint, let point else { return }

        let dx = point.x - startPoint.x
        let dy = point.y - startPoint.y
        if dx * dx + dy * dy < 16 {
            onTap(point.x, point.y)
        }
    }

    private func cancelDrag(onDragEnd: () -> Void)
    {
        guard isDragging else { return }

        isDragging = false
        startPoint = nil
        lastPoint = nil
        onDragEnd()
    }

    private static func point(from event: JSObject) -> (x: Double, y: Double)
    {
        let x = event.offsetX.number ?? 0
        let y = event.offsetY.number ?? 0
        return (x, y)
    }

    private static func element(_ id: String) -> JSObject?
    {
        JSObject.global.document.object?.getElementById?(id).object
    }
}
