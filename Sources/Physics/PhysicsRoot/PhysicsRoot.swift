import Foundation
import CoreGraphics
import Actomaton

/// Physics root namespace.
public enum PhysicsRoot {}

extension PhysicsRoot
{
    // MARK: - Action

    public enum Action
    {
        case changeCurrent(State.Current?)

        // Object
        case gravityUniverse(World.Action)
        case gravitySurface(World.Action)
        case spring(World.Action)
        case collision(World.Action)
        case springPendulum(World.Action)

        // Pendulum (Bob)
        case pendulum(World.Action)
        case doublePendulum(World.Action)
    }

    // MARK: - State

    public struct State: Equatable
    {
        /// Current example state.
        var current: Current?

        var configuration: WorldConfiguration

        public init(
            current: Current?,
            configuration: WorldConfiguration = .init(showsVelocityArrows: true, showsForceArrows: true)
        )
        {
            self.current = current
            self.configuration = configuration
        }
    }

    // MARK: - Environment

    public typealias Environment = PhysicsRootEnvironment

    // MARK: - EffectID

    public static func cancelAllEffectsPredicate(id: EffectID) -> Bool
    {
        id is World.TimerID
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
                    .contramap(state: \State.current)
                    .contramap(environment: { .init(timer: $0.timer) }),

                GravitySurfaceExample().reducer
                    .contramap(action: /Action.gravitySurface)
                    .contramap(state: /State.Current.gravitySurface)
                    .contramap(state: \State.current)
                    .contramap(environment: { .init(timer: $0.timer) }),

                SpringExample().reducer
                    .contramap(action: /Action.spring)
                    .contramap(state: /State.Current.spring)
                    .contramap(state: \State.current)
                    .contramap(environment: { .init(timer: $0.timer) }),

                CollisionExample().reducer
                    .contramap(action: /Action.collision)
                    .contramap(state: /State.Current.collision)
                    .contramap(state: \State.current)
                    .contramap(environment: { .init(timer: $0.timer) }),

                SpringPendulumExample().reducer
                    .contramap(action: /Action.springPendulum)
                    .contramap(state: /State.Current.springPendulum)
                    .contramap(state: \State.current)
                    .contramap(environment: { .init(timer: $0.timer) })
            ),

            // Pendulum (Bob)
            Reducer<Action, State, Environment>.combine(
                PendulumExample().reducer
                    .contramap(action: /Action.pendulum)
                    .contramap(state: /State.Current.pendulum)
                    .contramap(state: \State.current)
                    .contramap(environment: { .init(timer: $0.timer) }),

                DoublePendulumExample().reducer
                    .contramap(action: /Action.doublePendulum)
                    .contramap(state: /State.Current.doublePendulum)
                    .contramap(state: \State.current)
                    .contramap(environment: { .init(timer: $0.timer) })
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

            default:
                return .empty
            }
        }
    }
}
