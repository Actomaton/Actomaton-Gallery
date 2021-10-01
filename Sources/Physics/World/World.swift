import Foundation
import CoreGraphics
import Actomaton
import VectorMath

public enum World
{
    // MARK: - Action

    public enum Action
    {
        case updateBoardSize(CGSize)
        case resetBoard

        case startTimer
        case stopTimer
        case tick

        case tap(CGPoint)
        case dragging(CGPoint)
        case dragEnd
    }

    // MARK: - State

    public struct State<Obj>: Equatable where Obj: Equatable
    {
        public fileprivate(set) var boardSize: CGSize = .zero

        public fileprivate(set) var offset: CGPoint

        public internal(set) var objects: [Obj]

        public fileprivate(set) var isRunningTimer: Bool = false

        fileprivate let initialObjects: [Obj]
        fileprivate var dragState: DragState = .idle

        public init(objects: [Obj], offset: CGPoint = .zero)
        {
            self.offset = offset
            self.objects = objects
            self.objects.reserveCapacity(maxObjectCount)
            self.initialObjects = objects
        }

        enum DragState: Equatable
        {
            case idle
            case dragging
            case draggingObject(ObjectLikeID)

            var draggingObject: ObjectLikeID?
            {
                guard case let .draggingObject(value) = self else { return nil }
                return value
            }
        }
    }

    // MARK: - Environment

    public struct Environment
    {
        public let timer: () -> AsyncStream<Date>

        public init(
            timer: @escaping () -> AsyncStream<Date>
        )
        {
            self.timer = timer
        }
    }

    // MARK: - EffectID

    public struct TimerID: EffectIDProtocol {}

    public static func cancelAllEffectsPredicate(id: EffectID) -> Bool
    {
        return id is TimerID
    }

    // MARK: - Reducer

    /// - Parameters:
    ///   - tick: Custom logic called on every "tick" to modify `objects`, mainly to calculate surrounding forces.
    ///   - tap: Custom logic called on "tap" to modify `objects`.
    ///   - draggingObj: Custom logic called on "dragging object" to modify `object`.
    ///   - draggingVoid: Custom logic called on "dragging empty space" to modify `objects`.
    public static func reducer<Obj>(
        tick: @escaping (inout [Obj], CGSize) -> Void,
        tap: @escaping (inout [Obj], CGPoint) -> Void = { _, _ in },
        draggingObj: @escaping (inout Obj, CGPoint) -> Void = { _, _ in },
        draggingVoid: @escaping (inout [Obj], CGPoint) -> Void = { _, _ in }
    ) -> Reducer<Action, State<Obj>, Environment>
        where Obj: ObjectLike
    {
        .init { action, state, environment in
            switch action {
            case let .updateBoardSize(size):
                state.boardSize = size
                return .empty

            case .resetBoard:
                state.objects = state.initialObjects
                return .empty

            case .startTimer:
                state.isRunningTimer = true

                return Effect(
                    id: TimerID(),
                    sequence: environment.timer()
                        .map { _ in Action.tick }
                )

            case .stopTimer:
                state.isRunningTimer = false
                return .cancel(id: TimerID())

            case .tick:
                tick(&state.objects, state.boardSize)
                return .empty

            case let .tap(point):
                tap(&state.objects, point)
                return .empty

            case let .dragging(point):
                if state.dragState == .idle {
                    if let obj = state.objects.first(where: { $0.circleTouchRect.contains(point) }) {
                        state.dragState = .draggingObject(obj.id)
                    }
                    else {
                        state.dragState = .dragging
                    }
                }

                // Change object's position if possible.
                if let index = state.objects.firstIndex(where: { $0.id == state.dragState.draggingObject }) {
                    draggingObj(&state.objects[index], point)
                }
                else {
                    draggingVoid(&state.objects, point)
                }

                return .empty

            case .dragEnd:
                state.dragState = .idle
                return .empty
            }
        }
    }
}
