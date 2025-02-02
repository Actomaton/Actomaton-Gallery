import Foundation
import CoreGraphics
import Actomaton
import CanvasPlayer

/// Elementary cellular automaton namespace.
/// https://en.wikipedia.org/wiki/Elementary_cellular_automaton
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

            case let .updateCanvasSize(size):
                let width = Int(size.width / state.cellLength)
                let height = Int(size.height / state.cellLength)
                state.canvasSize = .init(width: width, height: height)
                state.board = state.selectedPattern.makeBoard(size: state.canvasSize)

            case .resetCanvas:
                state.board = state.selectedPattern.makeBoard(size: state.canvasSize)

            case .tap, .dragging, .dragEnd:
                // No UI interaction.
                break
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
        var newBoard = board
        newBoard.tick()
        newBoard.trimOldCellsToFit(maxHeight: boardSize.height)
        return newBoard
    }
}
