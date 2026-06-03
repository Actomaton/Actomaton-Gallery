import VectorMath

public enum PhysicsExampleSection: String, Sendable
{
    case objectWorld
    case pendulumWorld

    public var title: String
    {
        switch self {
        case .objectWorld:
            return "Object World"
        case .pendulumWorld:
            return "Pendulum World"
        }
    }
}

public enum PhysicsExampleID: String, CaseIterable, Sendable
{
    case gravityUniverse
    case gravitySurface
    case spring
    case springPendulum
    case rope
    case collision
    case lineCollision
    case galtonBoard
    case pendulum
    case doublePendulum

    public static let objectWorldExamples: [Self] = [
        .gravityUniverse,
        .gravitySurface,
        .spring,
        .springPendulum,
        .rope,
        .collision,
        .lineCollision,
        .galtonBoard,
    ]

    public static let pendulumWorldExamples: [Self] = [
        .pendulum,
        .doublePendulum,
    ]

    public var title: String
    {
        example.exampleTitle
    }

    public var section: PhysicsExampleSection
    {
        switch self {
        case .gravityUniverse,
            .gravitySurface,
            .spring,
            .springPendulum,
            .rope,
            .collision,
            .lineCollision,
            .galtonBoard:
            return .objectWorld

        case .pendulum,
            .doublePendulum:
            return .pendulumWorld
        }
    }

    /// Material Symbols ligature name for the wasm picker.
    public var icon: String
    {
        switch self {
        case .gravityUniverse:
            return "hub"
        case .gravitySurface:
            return "south"
        case .spring:
            return "cyclone"
        case .springPendulum:
            return "linear_scale"
        case .rope:
            return "polyline"
        case .collision:
            return "motion_photos_paused"
        case .lineCollision:
            return "show_chart"
        case .galtonBoard:
            return "grain"
        case .pendulum:
            return "speed"
        case .doublePendulum:
            return "linked_services"
        }
    }

    public var initialState: PhysicsRoot.State.Current
    {
        example.exampleInitialState
    }

    public var arrowScale: ArrowScale
    {
        example.exampleArrowScale
    }

    public var absolutePosition: (@Sendable (_ relativePosition: Vector2, _ index: Int, _ previous: Vector2) -> Vector2)?
    {
        example.absolutePosition
    }

    public func rootAction(_ action: World.Action) -> PhysicsRoot.Action
    {
        switch self {
        case .gravityUniverse:
            return .gravityUniverse(action)
        case .gravitySurface:
            return .gravitySurface(action)
        case .spring:
            return .spring(action)
        case .springPendulum:
            return .springPendulum(action)
        case .rope:
            return .rope(action)
        case .collision:
            return .collision(action)
        case .lineCollision:
            return .lineCollision(action)
        case .galtonBoard:
            return .galtonBoard(action)
        case .pendulum:
            return .pendulum(action)
        case .doublePendulum:
            return .doublePendulum(action)
        }
    }

    var example: any Example
    {
        switch self {
        case .gravityUniverse:
            return GravityUniverseExample()
        case .gravitySurface:
            return GravitySurfaceExample()
        case .spring:
            return SpringExample()
        case .springPendulum:
            return SpringPendulumExample()
        case .rope:
            return RopeExample()
        case .collision:
            return CollisionExample()
        case .lineCollision:
            return LineCollisionExample()
        case .galtonBoard:
            return GaltonBoardExample()
        case .pendulum:
            return PendulumExample()
        case .doublePendulum:
            return DoublePendulumExample()
        }
    }
}
