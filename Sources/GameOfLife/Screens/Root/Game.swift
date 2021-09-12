import Foundation
import CoreGraphics
import Actomaton

/// Conway's Game-of-Life game engine namespace.
public enum Game {}

extension Game
{
    public enum Action
    {
        case startTimer
        case stopTimer
        case tick

        case tap(x: Int, y: Int)
        case drag(x: Int, y: Int)
        case dragEnd

        case resetBoard
        case updateBoardSize(CGSize)

        case updatePattern(Pattern)
    }

    struct State: Equatable
    {
        var cellLength: CGFloat
        var boardSize: Board.Size

        fileprivate var dragState: DragState = .idle

        fileprivate(set) var board: Board

        var selectedPattern: Pattern

        var timerInterval: TimeInterval = 0.1
        var isRunningTimer = false

        public init(
            pattern: Pattern,
            cellLength: CGFloat = 5
        )
        {
            self.cellLength = cellLength
            self.boardSize = .zero
            self.board = pattern.makeBoard(size: self.boardSize)
            self.selectedPattern = pattern
        }

        enum DragState: Equatable
        {
            case idle
            case dragging(isFirstAlive: Bool)
        }
    }

    struct Environment
    {
        let timer: (TimeInterval) -> AsyncStream<Date>

        init(timer: @escaping (TimeInterval) -> AsyncStream<Date>)
        {
            self.timer = timer
        }
    }

    public struct TimerEffectID: EffectIDProtocol {}

    static func reducer() -> Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case let .updateBoardSize(size):
                let width = Int(size.width / state.cellLength)
                let height = Int(size.height / state.cellLength)
                state.boardSize = .init(width: width, height: height)
                state.board = state.selectedPattern.makeBoard(size: state.boardSize)

            case .startTimer:
                state.isRunningTimer = true

                return Effect(
                    id: TimerEffectID(),
                    sequence: environment.timer(state.timerInterval)
                        .map { _ in Action.tick }
                )

            case .stopTimer:
                state.isRunningTimer = false
                return .cancel(id: TimerEffectID())

            case .tick:
                let newBoard = runGame(board: state.board, boardSize: state.boardSize)
                let isSameBoard = state.board == newBoard
                state.board = newBoard

                // Stop timer if new board is same as previous.
                return state.board.cells.isEmpty || isSameBoard
                    ? Effect.nextAction(.stopTimer)
                    : .empty

            case let .tap(x, y):
                state.board[x, y].toggle()

            case let .drag(x, y):
                let newFlag = state.dragState.dragging ?? !state.board[x, y]
                state.dragState = .dragging(isFirstAlive: newFlag)
                state.board[x, y] = newFlag

            case .dragEnd:
                state.dragState = .idle

            case .resetBoard:
                state.board = state.selectedPattern.makeBoard(size: state.boardSize)

            case let .updatePattern(pattern):
                state.board = pattern.makeBoard(size: state.boardSize)
                state.selectedPattern = pattern
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

extension Game.State.DragState
{
    var dragging: Bool?
    {
        guard case let .dragging(value) = self else { return nil }
        return value
    }
}
