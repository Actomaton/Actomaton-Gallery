import ElementaryUI
import JavaScriptKit

@View
struct ElemCellAutomatonPage
{
    private static let canvasID = "elem-cell-automaton-canvas"

    @State var machine: ElemCellAutomatonDemoMachine

    /// Retains the `ResizeObserver` JS closure across re-renders (the WASM counterpart of
    /// SwiftUI's GeometryReader): feeds the live canvas pixel size to `updateCanvasSize`.
    @State var sizeObserver = CanvasSizeObserver()

    init()
    {
        _machine = State(wrappedValue: makeElemCellAutomatonDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "ElemCellAutomaton" }
            h2(.class("counter-heading")) { "Wolfram Cellular Automaton" }
            p(.class("counter-copy")) {
                "An elementary cellular automaton driven by the shared ElemCellAutomaton reducer. "
                "The grid sizes itself to the canvas — a ResizeObserver feeds the live pixel size into the "
                "same updateCanvasSize logic the SwiftUI screen drives via GeometryReader — drawn to an "
                "HTML <canvas> via JavaScriptKit."
            }

            div(.class("elem-cell-automaton-controls")) {
                ruleButton(30)
                ruleButton(90)
                ruleButton(110)
                ruleButton(184)
            }

            div(.class("elem-cell-automaton-controls")) {
                if machine.state.elemCellAutomaton.isRunningTimer {
                    button(.type(.button), .class("counter-action")) { "Stop" }
                        .onClick { _ in machine.send(.stopTimer) }
                }
                else {
                    button(.type(.button), .class("counter-action is-primary")) { "Start" }
                        .onClick { _ in machine.send(.startTimer) }
                }
            }

            canvas(
                .custom(name: "id", value: Self.canvasID),
                .class("elem-cell-automaton-canvas")
            ) { "" }
                // Track the canvas pixel size and feed it to the shared dynamic-grid reducer.
                .onAppear {
                    sizeObserver.start(canvasID: Self.canvasID) { [machine] width, height in
                        machine.send(.updateCanvasSize(width: width, height: height))
                        redrawElemCellAutomatonCanvas(machine: machine, canvasID: Self.canvasID)
                    }
                }
                // Redraw imperatively whenever a new generation is produced (and once on appear).
                .onChange(of: machine.state.elemCellAutomaton.generation, initial: true) {
                    redrawElemCellAutomatonCanvas(machine: machine, canvasID: Self.canvasID)
                }
        }
    }

    private func ruleButton(_ rule: UInt8) -> some View
    {
        button(
            .type(.button),
            .class(machine.state.elemCellAutomaton.selectedPattern.rule == rule ? "elem-cell-automaton-rule is-selected" : "elem-cell-automaton-rule")
        ) { "Rule \(rule)" }
            .onClick { _ in machine.send(.setRule(rule)) }
    }
}

// MARK: - Rendering

/// Draws the live cells of the shared `ElemCellAutomaton` board onto the `<canvas>` 2D context.
private func redrawElemCellAutomatonCanvas(machine: ElemCellAutomatonDemoMachine, canvasID: String)
{
    let cell = machine.state.elemCellAutomaton.cellLength

    guard cell > 0,
        let canvasNode = JSObject.global.document.object?.getElementById?(canvasID).object,
        let context = canvasNode.getContext?("2d").object
    else {
        return
    }

    let bufferWidth = canvasNode.width.number ?? 0
    let bufferHeight = canvasNode.height.number ?? 0

    // Clear.
    context.fillStyle = .string("#14110c")
    _ = context.fillRect?(0, 0, bufferWidth, bufferHeight)

    // Live cells.
    context.fillStyle = .string("#7fe3a1")
    let grid = machine.state.elemCellAutomaton.displayGrid
    for (y, row) in grid.enumerated() {
        for (x, isAlive) in row.enumerated() where isAlive {
            _ = context.fillRect?(Double(x) * cell, Double(y) * cell, cell, cell)
        }
    }
}

// MARK: - CanvasSizeObserver

/// Observes a `<canvas>`'s layout size (via `ResizeObserver`), matches its backing buffer to the
/// displayed CSS pixels (1:1), and reports the size so `ElemCellAutomaton` can derive its grid.
final class CanvasSizeObserver
{
    private var resizeClosure: JSClosure?
    private var observer: JSObject?

    func start(canvasID: String, onSize: @escaping (Double, Double) -> Void)
    {
        // Measure immediately (covers the initial mount), then observe future resizes.
        measure(canvasID: canvasID, onSize: onSize)

        guard resizeClosure == nil,
            let canvas = Self.element(canvasID),
            let resizeObserverCtor = JSObject.global.ResizeObserver.function
        else {
            return
        }

        let closure = JSClosure { [weak self] _ in
            self?.measure(canvasID: canvasID, onSize: onSize)
            return .undefined
        }
        self.resizeClosure = closure

        let observer = resizeObserverCtor.new(closure)
        _ = observer.observe?(canvas)
        self.observer = observer
    }

    private func measure(canvasID: String, onSize: (Double, Double) -> Void)
    {
        guard let canvas = Self.element(canvasID),
            let rect = canvas.getBoundingClientRect?().object
        else {
            return
        }

        let width = rect.width.number ?? 0
        let height = rect.height.number ?? 0
        guard width > 0, height > 0 else { return }

        // Match the backing buffer to the displayed CSS size (1:1).
        canvas.width = .number(width)
        canvas.height = .number(height)

        onSize(width, height)
    }

    private static func element(_ id: String) -> JSObject?
    {
        JSObject.global.document.object?.getElementById?(id).object
    }
}
