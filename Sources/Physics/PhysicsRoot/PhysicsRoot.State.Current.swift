import Actomaton
import VectorMath
import CanvasPlayer

extension PhysicsRoot.State
{
    /// Current example state as sum type where each state is not shared.
    /// - Note: `World.State` contains `Δt`, but will be replaced with `update` provided from `PhysicsRoot.State`.
    public enum Current: Equatable, Sendable
    {
        // Object
        case gravityUniverse(World.State<CircleObject>)
        case gravitySurface(World.State<CircleObject>)
        case spring(World.State<CircleObject>)
        case collision(World.State<CircleObject>)
        case lineCollision(World.State<Object>)
        case galtonBoard(World.State<CircleObject>)
        case springPendulum(World.State<CircleObject>)

        // Pendulum (Bob)
        case pendulum(World.State<Bob>)
        case doublePendulum(World.State<Bob>)

        @MainActor
        var example: Example
        {
            switch self {
            case .gravityUniverse:  return GravityUniverseExample()
            case .gravitySurface:   return GravitySurfaceExample()
            case .spring:           return SpringExample()
            case .collision:        return CollisionExample()
            case .lineCollision:    return LineCollisionExample()
            case .galtonBoard:      return GaltonBoardExample()
            case .springPendulum:   return SpringPendulumExample()
            case .pendulum:         return PendulumExample()
            case .doublePendulum:   return DoublePendulumExample()
            }
        }

        /// Replaces `self.Δt` with argument's `Δt`.
        mutating func update(Δt: Scalar)
        {
            switch self {
            case var .gravityUniverse(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .gravityUniverse(state)

            case var .gravitySurface(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .gravitySurface(state)

            case var .spring(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .spring(state)

            case var .collision(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .collision(state)

            case var .lineCollision(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .lineCollision(state)

            case var .galtonBoard(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .galtonBoard(state)

            case var .springPendulum(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .springPendulum(state)

            case var .pendulum(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .pendulum(state)

            case var .doublePendulum(state):
                state.canvasPlayerState.canvasState.Δt = Δt
                self = .doublePendulum(state)
            }
        }
    }
}

// MARK: - cancelAllEffectsPredicate

extension PhysicsRoot.State.Current
{
    /// Used for previous screen's effects cancellation.
    var cancelAllEffectsPredicate: (EffectID) -> Bool
    {
        CanvasPlayer.cancelAllEffectsPredicate
    }
}
