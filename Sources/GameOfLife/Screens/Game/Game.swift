import Foundation
import CoreGraphics
import Actomaton
import CanvasPlayer

/// Conway's Game-of-Life game engine namespace.
public enum Game {}

extension Game
{
    // MARK: - Action

    public enum Action: Sendable
    {
        case updatePattern(Pattern)

        case canvasPlayer(CanvasPlayer.Action)
    }

    // MARK: - State

    /// - Note: Wrapper of `CanvasPlayer.State<CanvasState>` to add convenient initializer.
    @dynamicMemberLookup
    struct State: Equatable, Sendable
    {
        var canvasPlayerState: CanvasPlayer.State<CanvasState>

        /// Convenient initializer.
        init(
            pattern: Pattern,
            cellLength: CGFloat,
            timerInterval: TimeInterval
        )
        {
            self.canvasPlayerState = CanvasPlayer.State(
                canvasState: CanvasState(pattern: pattern, cellLength: cellLength),
                timerInterval: timerInterval
            )
        }

        subscript<U>(dynamicMember keyPath: KeyPath<CanvasState, U>) -> U
        {
            self.canvasPlayerState.canvasState[keyPath: keyPath]
        }

        subscript<U>(dynamicMember keyPath: WritableKeyPath<CanvasState, U>) -> U
        {
            get {
                self.canvasPlayerState.canvasState[keyPath: keyPath]
            }
            set {
                self.canvasPlayerState.canvasState[keyPath: keyPath] = newValue
            }
        }
    }

    struct CanvasState: Equatable, Sendable
    {
        var cellLength: CGFloat
        var canvasSize: Board.Size

        fileprivate var dragState: DragState = .idle

        fileprivate(set) var board: Board

        var selectedPattern: Pattern

        public init(
            pattern: Pattern,
            cellLength: CGFloat
        )
        {
            self.cellLength = cellLength
            self.canvasSize = .zero
            self.board = pattern.makeBoard(size: self.canvasSize)
            self.selectedPattern = pattern
        }

        enum DragState: Equatable
        {
            case idle
            case dragging(isFirstAlive: Bool)
        }
    }

    // MARK: - Environment

    typealias Environment = CanvasPlayer.Environment

    // MARK: - EffectID

    static func cancelAllEffectsPredicate(id: EffectID) -> Bool
    {
        CanvasPlayer.cancelAllEffectsPredicate(id: id)
    }

    // MARK: - Reducer

    static func reducer() -> Reducer<Action, State, Environment>
    {
        .combine(
            .init { action, state, environment in
                switch action {
                case let .updatePattern(pattern):
                    state.board = pattern.makeBoard(size: state.canvasSize)
                    state.selectedPattern = pattern
                    return .empty

                default:
                    return .empty
                }
            },

            CanvasPlayer.reducer()
                .contramap(action: /Game.Action.canvasPlayer)
                .contramap(state: \Game.State.canvasPlayerState),

            canvasReducer()
                .contramap(action: /Game.Action.canvasPlayer)
                .contramap(state: \CanvasPlayer.State<CanvasState>.canvasState)
                .contramap(state: \Game.State.canvasPlayerState)
        )
    }

    static func canvasReducer() -> Reducer<CanvasPlayer.Action, CanvasState, Environment>
    {
        .init { action, state, environment in
            switch action {
            case .startTimer,
                 .stopTimer:
                return .empty

            case .tick:
                let newBoard = runGame(board: state.board, boardSize: state.canvasSize)
                let isSameBoard = state.board == newBoard
                state.board = newBoard

                // Stop timer if new board is same as previous.
                return state.board.cells.isEmpty || isSameBoard
                    ? Effect.nextAction(.stopTimer)
                    : .empty

            case let .tap(point):
                let p = _offset(at: point, cellLength: state.cellLength)
                state.board[p.x, p.y].toggle()

            case let .dragging(point):
                let p = _offset(at: point, cellLength: state.cellLength)
                let newFlag = state.dragState.dragging ?? !state.board[p.x, p.y]
                state.dragState = .dragging(isFirstAlive: newFlag)
                state.board[p.x, p.y] = newFlag

            case .dragEnd:
                state.dragState = .idle

            case let .updateCanvasSize(size):
                let width = Int(size.width / state.cellLength)
                let height = Int(size.height / state.cellLength)
                state.canvasSize = .init(width: width, height: height)
                state.board = state.selectedPattern.makeBoard(size: state.canvasSize)

            case .resetCanvas:
                state.board = state.selectedPattern.makeBoard(size: state.canvasSize)
            }

            return .empty
        }
    }
}

// MARK: - Run Game

extension Game
{
    /// FIXME: Needs some performance improvements.
    private static func runGame(board: Board, boardSize: Board.Size) -> Board
    {
        let rows = boardSize.height
        let columns = boardSize.width

        var newBoard = Board()
        for y in 0 ..< rows {
            for x in 0 ..< columns {
                var neighborLiveCount = 0
                for dy in -1 ... 1 {
                    for dx in -1 ... 1 {
                        if dx == 0 && dy == 0 { continue }
                        let x_ = x + dx
                        let y_ = y + dy
                        guard x_ >= 0 && x_ < columns && y_ >= 0 && y_ < rows else { continue }

                        if board[x_, y_] {
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
}

// MARK: - Enum Properties

extension Game.CanvasState.DragState
{
    var dragging: Bool?
    {
        guard case let .dragging(value) = self else { return nil }
        return value
    }
}

// MARK: - Private

private func _offset(at point: CGPoint, cellLength: CGFloat) -> Board.Point
{
    let x = Int(point.x / cellLength)
    let y = Int(point.y / cellLength)
    return Board.Point(x: x, y: y)
}
