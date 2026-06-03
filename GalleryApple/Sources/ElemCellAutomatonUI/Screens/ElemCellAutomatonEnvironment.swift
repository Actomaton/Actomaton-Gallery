import Foundation
import ElemCellAutomaton

public struct Environment: Sendable
{
    var game: ElemCellAutomaton.Environment

    public init(
        timer: @Sendable @escaping (TimeInterval) -> AsyncStream<Date>
    )
    {
        self.game = .init(timer: timer)
    }
}
