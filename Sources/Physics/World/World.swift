import Foundation
import CoreGraphics
import Actomaton
import VectorMath
import CanvasPlayer

/// World's Action / State / Environment / Reducer logic, based on `CanvasPlayer`.
///
/// Structure:
///
/// ```
/// WorldView
///     CanvasPlayer.CanvasView
///         CanvasPlayer.ContentView = WorldView.makeContentView (objects, arrows)
///         CanvasPlayer.ControlsView
///
/// World.Action
///     CanvasPlayer.Action (startTimer, stopTimer, updateCanvasSize)
///
/// World.State<Obj>
///     CanvasPlayer.State<World.CanvasState<Obj>> (isRunningTimer)
///         World.CanvasState<Obj> (canvasSize, objects, Δt)
///
/// World.Environment
///     CanvasPlayer.Environment
///         timer
/// ```
public enum World
{
    // MARK: - Action

    public typealias Action = CanvasPlayer.Action

    // MARK: - State

    /// - Note: Wrapper of `CanvasPlayer.State<CanvasState<Obj>>` to add convenient initializer.
    @dynamicMemberLookup
    public struct State<Obj>: Equatable, Sendable
        where Obj: Equatable & Sendable
    {
        public var canvasPlayerState: CanvasPlayer.State<CanvasState<Obj>>

        /// Convenient initializer.
        /// - Parameter Δt: Simulated delta time per tick.
        public init(objects: [Obj], offset: CGPoint = .zero, timerInterval: TimeInterval = 0.01, Δt: Scalar = 1)
        {
            self.canvasPlayerState = CanvasPlayer.State(
                canvasState: World.CanvasState(objects: objects, offset: offset, Δt: Δt),
                timerInterval: timerInterval
            )
        }

        public subscript<U>(dynamicMember keyPath: KeyPath<CanvasState<Obj>, U>) -> U
        {
            self.canvasPlayerState.canvasState[keyPath: keyPath]
        }
    }

    public struct CanvasState<Obj>: Equatable, Sendable
        where Obj: Equatable & Sendable
    {
        public var canvasSize: CGSize = .zero
        public fileprivate(set) var offset: CGPoint

        /// Simulated delta time per tick.
        var Δt: Scalar

        public internal(set) var objects: [Obj]

        fileprivate let initialObjects: [Obj]
        fileprivate var dragState: DragState = .idle

        /// - Parameter Δt: Simulated delta time per tick.
        public init(objects: [Obj], offset: CGPoint = .zero, Δt: Scalar)
        {
            self.offset = offset
            self.objects = objects
            self.objects.reserveCapacity(maxObjectCount)
            self.initialObjects = objects
            self.Δt = Δt
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

    public typealias Environment = CanvasPlayer.Environment

    // MARK: - Reducer

    /// - Parameters:
    ///   - tick: Custom logic called on every "tick" to modify `objects`, mainly to calculate surrounding forces.
    ///   - tap: Custom logic called on "tap" to modify `objects`.
    ///   - draggingObj: Custom logic called on "dragging object" to modify `object`.
    ///   - draggingEmptyArea: Custom logic called on "dragging empty area" to modify `objects`.
    ///   - dragEndEmptyArea: Custom logic called on "drag-end empty area" to modify `objects`.
    public static func reducer<Obj>(
        tick: @escaping @Sendable (inout [Obj], CGSize, _ Δt: Scalar) -> Void,
        tap: @escaping @Sendable (inout [Obj], CGPoint) -> Void = { _, _ in },
        draggingObj: @escaping @Sendable (inout Obj, CGPoint) -> Void = { _, _ in },
        draggingEmptyArea: @escaping @Sendable (inout [Obj], CGPoint) -> Void = { _, _ in },
        dragEndEmptyArea: @escaping @Sendable (inout [Obj]) -> Void = { _ in }
    ) -> Reducer<World.Action, World.State<Obj>, Environment>
        where Obj: ObjectLike
    {
        .combine(
            CanvasPlayer.reducer()
                .contramap(state: \World.State.canvasPlayerState),

            canvasReducer(
                tick: tick,
                tap: tap,
                draggingObj: draggingObj,
                draggingEmptyArea: draggingEmptyArea,
                dragEndEmptyArea: dragEndEmptyArea
            )
                .contramap(state: \CanvasPlayer.State<World.CanvasState>.canvasState)
                .contramap(state: \World.State.canvasPlayerState)
        )
    }

    private static func canvasReducer<Obj>(
        tick: @escaping @Sendable (inout [Obj], CGSize, _ Δt: Scalar) -> Void,
        tap: @escaping @Sendable (inout [Obj], CGPoint) -> Void = { _, _ in },
        draggingObj: @escaping @Sendable (inout Obj, CGPoint) -> Void = { _, _ in },
        draggingEmptyArea: @escaping @Sendable (inout [Obj], CGPoint) -> Void = { _, _ in },
        dragEndEmptyArea: @escaping @Sendable (inout [Obj]) -> Void = { _ in }
    ) -> Reducer<Action, CanvasState<Obj>, Environment>
        where Obj: ObjectLike
    {
        .init { action, state, environment in
            switch action {
            case .startTimer,
                .stopTimer:
                // Do nothing. Will be handled by `CanvasPlayer`.
                return .empty

            case .tick:
                tick(&state.objects, state.canvasSize, state.Δt)
                return .empty

            case let .tap(point):
                tap(&state.objects, point)
                return .empty

            case let .dragging(point):
                if state.dragState == .idle {
                    if let obj = state.objects.first(where: { $0.touchableRect.contains(point) }) {
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
                    draggingEmptyArea(&state.objects, point)
                }

                return .empty

            case .dragEnd:
                state.dragState = .idle
                dragEndEmptyArea(&state.objects)
                return .empty

            case let .updateCanvasSize(size):
                state.canvasSize = size
                return .empty

            case .resetCanvas:
                state.objects = state.initialObjects
                return .empty
            }
        }
    }
}
