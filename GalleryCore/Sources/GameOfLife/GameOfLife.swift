import Foundation
import CommonInterfaces
import CanvasPlayer
import Geometry

// MARK: - Action

public enum Action: Sendable
{
    case startTimer
    case stopTimer
    case tick
    case resetCanvas
    case updatePattern(Pattern)
    case updateCanvasSize(width: Double, height: Double)
    case tap(x: Double, y: Double)
    case dragging(x: Double, y: Double)
    case dragEnd

    case canvasPlayer(CanvasPlayer.Action)
}

// MARK: - State

/// Wrapper of `CanvasPlayer.State<CanvasState>` to add a convenient initializer.
@dynamicMemberLookup
public struct State: Equatable, Sendable
{
    public var canvasPlayerState: CanvasPlayer.State<CanvasState>

    public init(
        pattern: Pattern,
        cellLength: Double,
        timerInterval: TimeInterval
    )
    {
        self.canvasPlayerState = CanvasPlayer.State(
            canvasState: CanvasState(pattern: pattern, cellLength: cellLength),
            timerInterval: timerInterval
        )
    }

    public var isRunningTimer: Bool
    {
        self.canvasPlayerState.isRunningTimer
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<CanvasState, U>) -> U
    {
        self.canvasPlayerState.canvasState[keyPath: keyPath]
    }

    public subscript<U>(dynamicMember keyPath: WritableKeyPath<CanvasState, U>) -> U
    {
        get {
            self.canvasPlayerState.canvasState[keyPath: keyPath]
        }
        set {
            self.canvasPlayerState.canvasState[keyPath: keyPath] = newValue
        }
    }
}

public struct CanvasState: Equatable, Sendable
{
    public var cellLength: Double
    public var canvasSize: Board.Size

    fileprivate var dragState: DragState = .idle

    public fileprivate(set) var board: Board
    public fileprivate(set) var generation: Int = 0

    public var selectedPattern: Pattern

    public init(
        pattern: Pattern,
        cellLength: Double
    )
    {
        self.cellLength = cellLength
        self.canvasSize = .zero
        self.board = pattern.makeBoard(size: self.canvasSize)
        self.selectedPattern = pattern
    }

    fileprivate mutating func resize(toPixelWidth width: Double, height: Double)
    {
        guard cellLength > 0 else { return }

        let columns = max(0, Int(width / cellLength))
        let rows = max(0, Int(height / cellLength))

        self.canvasSize = .init(width: columns, height: rows)
        self.board = self.selectedPattern.makeBoard(size: self.canvasSize)
        self.generation = 0
    }

    fileprivate mutating func reset()
    {
        self.board = self.selectedPattern.makeBoard(size: self.canvasSize)
        self.generation += 1
    }

    fileprivate enum DragState: Equatable, Sendable
    {
        case idle
        case dragging(isFirstAlive: Bool)
    }
}

// MARK: - Environment

public typealias Environment = CanvasPlayer.Environment

// MARK: - EffectID

public func cancelAllEffectsPredicate(id: any EffectID) -> Bool
{
    CanvasPlayer.cancelAllEffectsPredicate(id: id)
}

// MARK: - Reducer

public func reducer() -> Reducer<Action, State, Environment>
{
    .combine(
        .init { action, state, _ in
            switch action {
            case .startTimer:
                return Effect.next(action: .canvasPlayer(.startTimer))

            case .stopTimer:
                return Effect.next(action: .canvasPlayer(.stopTimer))

            case .tick:
                return Effect.next(action: .canvasPlayer(.tick))

            case .resetCanvas:
                return Effect.next(action: .canvasPlayer(.resetCanvas))

            case let .updatePattern(pattern):
                state.canvasPlayerState.canvasState.selectedPattern = pattern
                state.canvasPlayerState.canvasState.reset()
                return .empty

            case let .updateCanvasSize(width, height):
                return Effect.next(action: .canvasPlayer(.updateCanvasSize(.init(width: width, height: height))))

            case let .tap(x, y):
                return Effect.next(action: .canvasPlayer(.tap(.init(x: x, y: y))))

            case let .dragging(x, y):
                return Effect.next(action: .canvasPlayer(.dragging(.init(x: x, y: y))))

            case .dragEnd:
                return Effect.next(action: .canvasPlayer(.dragEnd))

            case .canvasPlayer:
                return .empty
            }
        },

        CanvasPlayer.reducer()
            .contramap(action: /Action.canvasPlayer)
            .contramap(state: \State.canvasPlayerState),

        canvasReducer()
            .contramap(action: /Action.canvasPlayer)
            .contramap(state: \CanvasPlayer.State<CanvasState>.canvasState)
            .contramap(state: \State.canvasPlayerState)
    )
}

private func canvasReducer() -> Reducer<CanvasPlayer.Action, CanvasState, Environment>
{
    .init { action, state, _ in
        switch action {
        case .startTimer,
            .stopTimer:
            return .empty

        case .tick:
            let newBoard = runGame(board: state.board, boardSize: state.canvasSize)
            let isSameBoard = state.board == newBoard
            state.board = newBoard
            state.generation += 1

            // Stop timer if the simulation died out or stabilized.
            return state.board.cells.isEmpty || isSameBoard
                ? Effect.next(action: .stopTimer)
                : .empty

        case let .tap(point):
            let point = offset(at: point, cellLength: state.cellLength)
            state.board[point.x, point.y].toggle()
            state.generation += 1

        case let .dragging(point):
            let point = offset(at: point, cellLength: state.cellLength)
            let newFlag = state.dragState.dragging ?? !state.board[point.x, point.y]
            state.dragState = .dragging(isFirstAlive: newFlag)
            state.board[point.x, point.y] = newFlag
            state.generation += 1

        case .dragEnd:
            state.dragState = .idle

        case let .updateCanvasSize(size):
            state.resize(toPixelWidth: size.width, height: size.height)

        case .resetCanvas:
            state.reset()
        }

        return .empty
    }
}

// MARK: - Run Game

/// FIXME(2026-06-01): Needs performance improvements for large boards.
private func runGame(board: Board, boardSize: Board.Size) -> Board
{
    let rows = boardSize.height
    let columns = boardSize.width

    var newBoard = Board()
    for y in 0 ..< rows {
        for x in 0 ..< columns {
            var neighborLiveCount = 0
            for deltaY in -1 ... 1 {
                for deltaX in -1 ... 1 {
                    if deltaX == 0 && deltaY == 0 { continue }
                    let neighborX = x + deltaX
                    let neighborY = y + deltaY
                    guard neighborX >= 0 && neighborX < columns && neighborY >= 0 && neighborY < rows else { continue }

                    if board[neighborX, neighborY] {
                        neighborLiveCount += 1
                    }
                }
            }

            switch neighborLiveCount {
            case 2:
                if board[x, y] {
                    newBoard[x, y] = true
                }
            case 3:
                newBoard[x, y] = true
            default:
                newBoard[x, y] = false
            }
        }
    }
    return newBoard
}

// MARK: - Enum Properties

extension CanvasState.DragState
{
    var dragging: Bool?
    {
        guard case let .dragging(value) = self else { return nil }
        return value
    }
}

// MARK: - Private

private func offset(at point: Geometry.Point, cellLength: Double) -> Board.Point
{
    guard cellLength > 0 else { return .zero }

    let x = Int(point.x / cellLength)
    let y = Int(point.y / cellLength)
    return Board.Point(x: x, y: y)
}
