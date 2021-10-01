import Foundation

public struct PhysicsRootEnvironment
{
    public let timer: () -> AsyncStream<Date>

    public init(
        timer: @escaping () -> AsyncStream<Date>
    )
    {
        self.timer = timer
    }
}
