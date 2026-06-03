import Foundation
import CommonInterfaces
import CanvasPlayer

// Elementary cellular automaton state machine, composed on top of `CanvasPlayer` (the
// shared timer / play-pause player) so the timer machinery isn't duplicated. The CA-specific
// logic — evolving the `Board` each `tick`, sizing the grid from the canvas, and reseeding on
// `setRule` — lives in `canvasReducer` + the `CanvasState` mutating helpers. Reuses the shared
// `Board` + `Pattern` math; CoreGraphics-free, so the SAME reducer backs both the SwiftUI screen
// (canvas size via GeometryReader) and the WebAssembly screen (canvas size via a JS ResizeObserver).
// The grid is always dynamic: `columns`/`maxRows` are derived from the pixel canvas size / `cellLength`.

// MARK: - CanvasState

/// CA-specific canvas content wrapped by `CanvasPlayer.State`.
public struct CanvasState: Equatable, Sendable
{
    public internal(set) var board: Board
    public internal(set) var selectedPattern: Pattern

    /// Monotonic counter bumped on every `tick` (reset on reseed).
    /// Lets renderers observe generation changes even after `board.rowCount` caps at `maxRows`.
    public internal(set) var generation: Int = 0

    /// Grid dimensions, derived from the canvas pixel size on `updateCanvasSize`.
    public internal(set) var columns: Int = 0
    public internal(set) var maxRows: Int = 0

    /// Pixels per cell — the divisor turning the canvas pixel size into `columns`/`maxRows`.
    public let cellLength: Double

    public init(rule: UInt8, cellLength: Double)
    {
        let pattern = Pattern(rule: rule)
        self.selectedPattern = pattern
        self.cellLength = cellLength
        self.board = pattern.makeBoard(size: Board.Size(width: 0, height: 1))
    }

    /// Centered, windowed view of the board for rendering (`rowCount` × `columns`).
    public var displayGrid: [[Bool]]
    {
        (0 ..< board.rowCount).map { y in
            (0 ..< columns).map { x in board[x, y] }
        }
    }

    /// Resize the grid to a pixel canvas size (`columns`/`maxRows` = size / `cellLength`) and reseed.
    mutating func resize(toPixelWidth width: Double, height: Double)
    {
        guard cellLength > 0 else { return }
        columns = Int(width / cellLength)
        maxRows = Int(height / cellLength)
        reseed()
    }

    /// Reseed the board from `selectedPattern` at the current `columns`, restarting from generation 0.
    mutating func reseed()
    {
        board = selectedPattern.makeBoard(size: Board.Size(width: columns, height: 1))
        generation = 0
    }

    mutating func setRule(_ rule: UInt8)
    {
        selectedPattern = Pattern(rule: rule)
        reseed()
    }
}

// MARK: - Action

public enum Action: Sendable
{
    case startTimer
    case stopTimer
    case setRule(UInt8)

    /// Pixel canvas size for the dynamic grid — flat case for WASM screens (the SwiftUI `CanvasPlayer`
    /// views send `.canvasPlayer(.updateCanvasSize(...))` instead).
    case updateCanvasSize(width: Double, height: Double)

    /// Plumbing for the shared `CanvasPlayer` (timer tick, SwiftUI canvas resize).
    case canvasPlayer(CanvasPlayer.Action)
}

// MARK: - State

@dynamicMemberLookup
public struct State: Equatable, Sendable
{
    public var canvasPlayerState: CanvasPlayer.State<CanvasState>

    /// - Parameter cellLength: Pixels per cell; `columns`/`maxRows` are derived from the canvas size.
    public init(rule: UInt8 = 110, cellLength: Double, timerInterval: TimeInterval)
    {
        self.canvasPlayerState = CanvasPlayer.State(
            canvasState: CanvasState(rule: rule, cellLength: cellLength),
            timerInterval: timerInterval
        )
    }

    /// Forwarded from the wrapped `CanvasPlayer.State`.
    public var isRunningTimer: Bool
    {
        self.canvasPlayerState.isRunningTimer
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<CanvasState, U>) -> U
    {
        self.canvasPlayerState.canvasState[keyPath: keyPath]
    }
}

// MARK: - Environment

public typealias Environment = CanvasPlayer.Environment

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .combine(
        // Shared timer / play-pause machinery.
        CanvasPlayer.reducer()
            .contramap(action: /Action.canvasPlayer)
            .contramap(state: \State.canvasPlayerState),

        // CA-specific evolution / resize.
        canvasReducer()
            .contramap(action: /Action.canvasPlayer)
            .contramap(state: \CanvasPlayer.State<CanvasState>.canvasState)
            .contramap(state: \State.canvasPlayerState),

        // Flat screen-facing actions: forward timer control to `CanvasPlayer`, reseed / resize.
        .init { action, state, _ in
            switch action {
            case .startTimer:
                return Effect.next(action: .canvasPlayer(.startTimer))

            case .stopTimer:
                return Effect.next(action: .canvasPlayer(.stopTimer))

            case let .setRule(rule):
                state.canvasPlayerState.canvasState.setRule(rule)
                return Effect.next(action: .canvasPlayer(.stopTimer))

            case let .updateCanvasSize(width, height):
                state.canvasPlayerState.canvasState.resize(toPixelWidth: width, height: height)
                return .empty

            case .canvasPlayer:
                return .empty
            }
        }
    )
}

private func canvasReducer() -> Reducer<CanvasPlayer.Action, CanvasState, Environment>
{
    .init { action, state, _ in
        switch action {
        case .tick:
            let previousBoard = state.board
            state.board.tick()
            state.board.trimOldCellsToFit(maxHeight: state.maxRows)
            state.generation += 1

            // Stop when the simulation can't progress (died out or stabilized).
            if state.board.cells.isEmpty || state.board == previousBoard {
                return Effect.next(action: .stopTimer)
            }
            return .empty

        case let .updateCanvasSize(size):
            state.resize(toPixelWidth: size.width, height: size.height)
            return .empty

        case .resetCanvas:
            state.reseed()
            return .empty

        default:
            return .empty
        }
    }
}
