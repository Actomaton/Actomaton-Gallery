import Actomaton
import Counter
import ColorFilter
import Todo
import StateDiagram
import Stopwatch
import GitHub
import GameOfLife
import VideoDetector

extension Root.State
{
    /// Current example state as sum type where each state is not shared.
    enum Current: Equatable
    {
        case counter(Counter.State)
        case colorFilter(ColorFilter.State)
        case stopwatch(Stopwatch.State)
        case stateDiagram(StateDiagram.State)
        case todo(Todo.State)
        case github(GitHub.State)
        case gameOfLife(GameOfLife.Root.State)
        case videoDetector(VideoDetector.State)

        @MainActor
        var example: Example
        {
            switch self {
            case .counter:          return CounterExample()
            case .colorFilter:      return ColorFilterExample()
            case .stopwatch:        return StopwatchExample()
            case .stateDiagram:     return StateDiagramExample()
            case .todo:             return TodoExample()
            case .github:           return GitHubExample()
            case .gameOfLife:       return GameOfLifeExample()
            case .videoDetector:    return VideoDetectorExample()
            }
        }
    }
}

// MARK: - cancelAllEffectsPredicate

extension Root.State.Current
{
    /// Used for previous screen's effects cancellation.
    var cancelAllEffectsPredicate: (EffectID) -> Bool
    {
        switch self {
        case .stopwatch:
            return Stopwatch.cancelAllEffectsPredicate

        case .github:
            return GitHub.cancelAllEffectsPredicate

        default:
            return { _ in false }
        }
    }
}
