import Foundation
import CoreGraphics
import Actomaton
import VectorMath
import CanvasPlayer

/// Physics root namespace.
public enum PhysicsRoot {}

extension PhysicsRoot
{
    // MARK: - Action

    public enum Action
    {
        case changeCurrent(State.Current?)
        case changeΔt(Scalar)

        // Object
        case gravityUniverse(World.Action)
        case gravitySurface(World.Action)
        case spring(World.Action)
        case collision(World.Action)
        case lineCollision(World.Action)
        case galtonBoard(World.Action)
        case springPendulum(World.Action)

        // Pendulum (Bob)
        case pendulum(World.Action)
        case doublePendulum(World.Action)
    }

    // MARK: - State

    public struct State: Equatable
    {
        /// Current example state.
        private var _current: Current?

        /// Wrapper to replace `_current.Δt` with `self.Δt`.
        var current: Current?
        {
            get {
                guard var current = self._current else { return nil }

                current.update(Δt: self.Δt)
                return current
            }
            set {
                var newValue = newValue
                newValue?.update(Δt: self.Δt)
                self._current = newValue
            }
        }

        /// - Simulated delta time per tick. (shared across different `Current`)
        var Δt: Scalar

        var configuration: WorldConfiguration

        public init(
            current: Current?,
            Δt: Scalar = 1,
            configuration: WorldConfiguration = .init(showsVelocityArrows: true, showsForceArrows: true)
        )
        {
            var current = current
            current?.update(Δt: Δt)

            self._current = current
            self.Δt = Δt
            self.configuration = configuration
        }
    }

    // MARK: - Environment

    public typealias Environment = CanvasPlayer.Environment

    // MARK: - EffectID

    public static func cancelAllEffectsPredicate(id: EffectID) -> Bool
    {
        CanvasPlayer.cancelAllEffectsPredicate(id: id)
    }

    // MARK: - Reducer

    public static var reducer: Reducer<Action, State, Environment>
    {
        .combine(
            changeCurrentReducer(),

            // Objects
            Reducer<Action, State, Environment>.combine(
                GravityUniverseExample().reducer
                    .contramap(action: /Action.gravityUniverse)
                    .contramap(state: /State.Current.gravityUniverse)
                    .contramap(state: \State.current),

                GravitySurfaceExample().reducer
                    .contramap(action: /Action.gravitySurface)
                    .contramap(state: /State.Current.gravitySurface)
                    .contramap(state: \State.current),

                SpringExample().reducer
                    .contramap(action: /Action.spring)
                    .contramap(state: /State.Current.spring)
                    .contramap(state: \State.current),

                CollisionExample().reducer
                    .contramap(action: /Action.collision)
                    .contramap(state: /State.Current.collision)
                    .contramap(state: \State.current),

                LineCollisionExample().reducer
                    .contramap(action: /Action.lineCollision)
                    .contramap(state: /State.Current.lineCollision)
                    .contramap(state: \State.current),

                GaltonBoardExample().reducer
                    .contramap(action: /Action.galtonBoard)
                    .contramap(state: /State.Current.galtonBoard)
                    .contramap(state: \State.current),

                SpringPendulumExample().reducer
                    .contramap(action: /Action.springPendulum)
                    .contramap(state: /State.Current.springPendulum)
                    .contramap(state: \State.current)
            ),

            // Pendulum (Bob)
            Reducer<Action, State, Environment>.combine(
                PendulumExample().reducer
                    .contramap(action: /Action.pendulum)
                    .contramap(state: /State.Current.pendulum)
                    .contramap(state: \State.current),

                DoublePendulumExample().reducer
                    .contramap(action: /Action.doublePendulum)
                    .contramap(state: /State.Current.doublePendulum)
                    .contramap(state: \State.current)
            )
        )
    }

    private static func changeCurrentReducer() -> Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case let .changeCurrent(current):
                state.current = current

                // Cancel previous effects when revisiting the same screen.
                //
                // NOTE:
                // We sometimes don't want to cancel previous effects at example screen's
                // `onAppear`, `onDisappear`, `init`, `deinit`, etc,
                // because we want to keep them running
                // (e.g. Stopwatch temporarily visiting child screen),
                // so `.changeCurrent` (revisiting the same screen) is
                // the best timing to cancel them.
                return current
                    .map { Effect.cancel(ids: $0.cancelAllEffectsPredicate) } ?? .empty

            case let .changeΔt(Δt):
                state.Δt = Δt
                return .empty

            default:
                return .empty
            }
        }
    }
}
