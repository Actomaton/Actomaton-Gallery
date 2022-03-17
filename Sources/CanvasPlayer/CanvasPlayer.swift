import Foundation
import CoreGraphics
import Actomaton

// MARK: - Action

public enum Action: Sendable
{
    case startTimer
    case stopTimer
    case tick

    case tap(CGPoint)
    case dragging(CGPoint)
    case dragEnd

    case updateCanvasSize(CGSize)
    case resetCanvas
}

// MARK: - State

@dynamicMemberLookup
public struct State<CanvasState>: Equatable, Sendable
    where CanvasState: Equatable & Sendable
{
    public fileprivate(set) var canvasSize: CGSize = .zero
    public fileprivate(set) var isRunningTimer: Bool = false
    public var timerInterval: TimeInterval

    public var canvasState: CanvasState

    public init(canvasState: CanvasState, timerInterval: TimeInterval)
    {
        self.canvasState = canvasState
        self.timerInterval = timerInterval
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<CanvasState, U>) -> U
    {
        self.canvasState[keyPath: keyPath]
    }

    public subscript<U>(dynamicMember keyPath: WritableKeyPath<CanvasState, U>) -> U
    {
        get {
            self.canvasState[keyPath: keyPath]
        }
        set {
            self.canvasState[keyPath: keyPath] = newValue
        }
    }
}

// MARK: - Environment

public struct Environment: Sendable
{
    public let timer: @Sendable (TimeInterval) -> AsyncStream<Date>

    public init(
        timer: @Sendable @escaping (TimeInterval) -> AsyncStream<Date>
    )
    {
        self.timer = timer
    }
}

// MARK: - EffectID

private struct TimerEffectID: EffectIDProtocol {}

public func cancelAllEffectsPredicate(id: EffectID) -> Bool
{
    return id.value is TimerEffectID
}

// MARK: - Reducer

public func reducer<CanvasState>() -> Reducer<Action, State<CanvasState>, Environment>
{
    .init { action, state, environment in
        switch action {
        case .startTimer:
            state.isRunningTimer = true

            return Effect(
                id: TimerEffectID(),
                sequence: environment.timer(state.timerInterval)
                    .map { _ in .tick }
            )

        case .stopTimer:
            state.isRunningTimer = false
            return .cancel(id: TimerEffectID())

        case let .updateCanvasSize(canvasSize):
            state.canvasSize = canvasSize
            return .empty

        default:
            return .empty
        }
    }
}
