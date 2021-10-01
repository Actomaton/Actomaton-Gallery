import Actomaton
import CanvasPlayer

extension PhysicsRoot.State
{
    /// Current example state as sum type where each state is not shared.
    public enum Current: Equatable
    {
        // Object
        case gravityUniverse(World.State<Object>)
        case gravitySurface(World.State<Object>)
        case spring(World.State<Object>)
        case collision(World.State<Object>)
        case springPendulum(World.State<Object>)

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
            case .springPendulum:   return SpringPendulumExample()
            case .pendulum:         return PendulumExample()
            case .doublePendulum:   return DoublePendulumExample()
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
