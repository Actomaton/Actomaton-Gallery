import ElementaryUI
import struct GameOfLife.Pattern
import JavaScriptKit

@View
struct GameOfLifePage
{
    private static let canvasID = "game-of-life-canvas"

    @State var machine: GameOfLifeDemoMachine
    @State var sizeObserver = CanvasSizeObserver()
    @State var pointerObserver = CanvasPointerObserver()

    init()
    {
        _machine = State(wrappedValue: makeGameOfLifeDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "GameOfLife" }
            h2(.class("counter-heading")) { "Conway's Game of Life" }
            p(.class("counter-copy")) {
                "A playable browser canvas backed by the same GameOfLife reducer used by the SwiftUI gallery."
            }

            div(.class("game-of-life-controls")) {
                for pattern in Pattern.presets {
                    GameOfLifePatternButton(
                        pattern: pattern,
                        isSelected: machine.state.game.selectedPattern.title == pattern.title,
                        onSelect: { machine.send(.updatePattern(pattern)) }
                    )
                }
            }

            div(.class("game-of-life-controls")) {
                if machine.state.game.isRunningTimer {
                    button(.type(.button), .class("counter-action")) { "Stop" }
                        .onClick { _ in machine.send(.stopTimer) }
                }
                else {
                    button(.type(.button), .class("counter-action is-primary")) { "Start" }
                        .onClick { _ in machine.send(.startTimer) }
                }

                button(.type(.button), .class("counter-action")) { "Step" }
                    .onClick { _ in machine.send(.tick) }

                button(.type(.button), .class("counter-action")) { "Reset" }
                    .onClick { _ in machine.send(.resetCanvas) }
            }

            canvas(
                .custom(name: "id", value: Self.canvasID),
                .class("game-of-life-canvas")
            ) { "" }
                .onAppear {
                    sizeObserver.start(canvasID: Self.canvasID) { width, height in
                        machine.send(.updateCanvasSize(width: width, height: height))
                        redrawGameOfLifeCanvas(machine: machine, canvasID: Self.canvasID)
                    }

                    pointerObserver.start(
                        canvasID: Self.canvasID,
                        onDrag: { x, y in
                            machine.send(.dragging(x: x, y: y))
                            redrawGameOfLifeCanvas(machine: machine, canvasID: Self.canvasID)
                        },
                        onDragEnd: {
                            machine.send(.dragEnd)
                        }
                    )
                }
                .onChange(of: machine.state.game.generation, initial: true) {
                    redrawGameOfLifeCanvas(machine: machine, canvasID: Self.canvasID)
                }
        }
    }

}

@View
private struct GameOfLifePatternButton
{
    let pattern: Pattern
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View
    {
        button(
            .type(.button),
            .class(isSelected ? "game-of-life-pattern is-selected" : "game-of-life-pattern")
        ) { pattern.title }
            .onClick { _ in onSelect() }
    }
}

// MARK: - Rendering

private func redrawGameOfLifeCanvas(machine: GameOfLifeDemoMachine, canvasID: String)
{
    let cell = machine.state.game.cellLength

    guard cell > 0,
        let canvasNode = JSObject.global.document.object?.getElementById?(canvasID).object,
        let context = canvasNode.getContext?("2d").object
    else {
        return
    }

    let bufferWidth = canvasNode.width.number ?? 0
    let bufferHeight = canvasNode.height.number ?? 0

    context.fillStyle = .string("#101820")
    _ = context.fillRect?(0, 0, bufferWidth, bufferHeight)

    context.strokeStyle = .string("rgba(255, 255, 255, 0.05)")
    context.lineWidth = .number(1)

    let columns = machine.state.game.canvasSize.width
    let rows = machine.state.game.canvasSize.height
    for column in 0 ... columns {
        let x = Double(column) * cell
        _ = context.beginPath?()
        _ = context.moveTo?(x, 0)
        _ = context.lineTo?(x, bufferHeight)
        _ = context.stroke?()
    }
    for row in 0 ... rows {
        let y = Double(row) * cell
        _ = context.beginPath?()
        _ = context.moveTo?(0, y)
        _ = context.lineTo?(bufferWidth, y)
        _ = context.stroke?()
    }

    context.fillStyle = .string("#f5c542")
    let inset = max(1, cell * 0.12)
    let liveCellLength = max(1, cell - inset * 2)

    for point in machine.state.game.board.liveCellPoints {
        _ = context.fillRect?(
            Double(point.x) * cell + inset,
            Double(point.y) * cell + inset,
            liveCellLength,
            liveCellLength
        )
    }
}

// MARK: - CanvasPointerObserver

final class CanvasPointerObserver
{
    private var isDragging = false
    private var pointerDownClosure: JSClosure?
    private var pointerMoveClosure: JSClosure?
    private var pointerUpClosure: JSClosure?
    private var pointerCancelClosure: JSClosure?

    func start(
        canvasID: String,
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
            onDrag(point.x, point.y)
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
            onDrag(point.x, point.y)
            return .undefined
        }

        let pointerUpClosure = JSClosure { [weak self] arguments in
            guard let self else { return .undefined }

            if let event = arguments.first?.object {
                _ = event.preventDefault?()
                if let pointerID = event.pointerId.number {
                    _ = canvas.releasePointerCapture?(pointerID)
                }
            }

            self.endDrag(onDragEnd: onDragEnd)
            return .undefined
        }

        let pointerCancelClosure = JSClosure { [weak self] _ in
            self?.endDrag(onDragEnd: onDragEnd)
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

    private func endDrag(onDragEnd: () -> Void)
    {
        guard isDragging else { return }

        isDragging = false
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
