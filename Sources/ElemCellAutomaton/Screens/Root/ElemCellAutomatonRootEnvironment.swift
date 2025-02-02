import Foundation

public struct RootEnvironment: Sendable
{
    var game: Game.Environment

    public init(
        timer: @Sendable @escaping (TimeInterval) -> AsyncStream<Date>
    )
    {
        self.game = .init(timer: timer)
    }
}
