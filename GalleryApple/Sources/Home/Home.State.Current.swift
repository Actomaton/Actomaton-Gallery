import Actomaton
import Counter
import SyncCounters
import AnimationDemo
import ColorFilter
import ColorFilterBindingUI
import Todo
import StateDiagram
import Stopwatch
import HttpBin
import GitHubUI
import ElemCellAutomatonUI
import GameOfLifeUI
import VideoPlayer
import VideoPlayerMulti
import VideoDetector
import PhysicsUI
import Downloader

extension State
{
    /// Current example state as sum type where each state is not shared.
    public enum Current: Equatable, Sendable
    {
        case counter(Counter.State)
        case syncCounters(SyncCounters.State)
        case animationDemo(AnimationDemo.State)
        case colorFilter(ColorFilter.State)
        case colorFilterBinding(ColorFilterBindingUI.State)
        case stopwatch(Stopwatch.State)
        case stateDiagram(StateDiagram.State)
        case todo(Todo.State)
        case httpbin(HttpBin.State)
        case github(GitHubUI.State)
        case elemCellAutomaton(ElemCellAutomatonUI.State)
        case gameOfLife(GameOfLifeUI.Root.State)
        case videoPlayer(VideoPlayer.State)
        case videoPlayerMulti(VideoPlayerMulti.State)
        case videoDetector(VideoDetector.State)
        case physics(PhysicsRoot.State)
        case downloader(Downloader.State)

        var example: Example
        {
            switch self {
            case .counter:          return CounterExample()
            case .syncCounters:     return SyncCountersExample()
            case .animationDemo:    return AnimationExample()
            case .colorFilter:      return ColorFilterExample()
            case .colorFilterBinding: return ColorFilterBindingExample()
            case .stopwatch:        return StopwatchExample()
            case .stateDiagram:     return StateDiagramExample()
            case .todo:             return TodoExample()
            case .httpbin:          return HttpBinExample()
            case .github:           return GitHubExample()
            case .elemCellAutomaton: return ElemCellAutomatonExample()
            case .gameOfLife:       return GameOfLifeExample()
            case .videoPlayer:      return VideoPlayerExample()
            case .videoPlayerMulti: return VideoPlayerMultiExample()
            case .videoDetector:    return VideoDetectorExample()
            case .physics:          return PhysicsExample()
            case .downloader:       return DownloaderExample()
            }
        }
    }
}

// MARK: - cancelAllEffectsPredicate

extension State.Current
{
    /// Used for previous screen's effects cancellation.
    var cancelAllEffectsPredicate: (any EffectID) -> Bool
    {
        switch self {
        case .stopwatch:
            return Stopwatch.cancelAllEffectsPredicate

        case .httpbin:
            return HttpBin.cancelAllEffectsPredicate

        case .github:
            return GitHubUI.cancelAllEffectsPredicate

        case .gameOfLife:
            return GameOfLifeUI.Root.cancelAllEffectsPredicate

        case .physics:
            return PhysicsRoot.cancelAllEffectsPredicate

        case .downloader:
            return Downloader.cancelAllEffectsPredicate

        default:
            return { _ in false }
        }
    }
}
