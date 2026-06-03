// MARK: - Object World presets

extension PhysicsRoot.State
{
    public static var gravityUniverse: PhysicsRoot.State
    {
        .init(example: GravityUniverseExample())
    }

    public static var gravitySurface: PhysicsRoot.State
    {
        .init(example: GravitySurfaceExample())
    }

    public static var spring: PhysicsRoot.State
    {
        .init(example: SpringExample())
    }

    public static var springPendulum: PhysicsRoot.State
    {
        .init(example: SpringPendulumExample())
    }

    public static var rope: PhysicsRoot.State
    {
        .init(example: RopeExample())
    }

    public static var collision: PhysicsRoot.State
    {
        .init(example: CollisionExample())
    }

    public static var lineCollision: PhysicsRoot.State
    {
        .init(example: LineCollisionExample())
    }

    public static var galtonBoard: PhysicsRoot.State
    {
        .init(example: GaltonBoardExample())
    }
}

// MARK: - Pendulum (Bob) World presets

extension PhysicsRoot.State
{
    public static var pendulum: PhysicsRoot.State
    {
        .init(example: PendulumExample())
    }

    public static var doublePendulum: PhysicsRoot.State
    {
        .init(example: DoublePendulumExample())
    }
}

// MARK: - Private

extension PhysicsRoot.State
{
    private init<E: Example>(example: E)
    {
        self.init(current: example.exampleInitialState)
    }
}
