enum WasmExampleID: String, CaseIterable
{
    // NOTE: Order mirrors the SwiftUI gallery's `exampleList` (filtered to WASM examples).
    case counter
    case syncCounters
    case colorFilter
    case todo
    case stateDiagram
    case stopwatch
    case httpbin
    case github
    case downloader
    case elemCellAutomaton
    case gameOfLife
    case physics

    var title: String
    {
        switch self {
        case .counter:
            return "Counter"
        case .syncCounters:
            return "SyncCounters"
        case .colorFilter:
            return "ColorFilter"
        case .todo:
            return "Todo"
        case .stateDiagram:
            return "StateDiagram"
        case .stopwatch:
            return "Stopwatch"
        case .httpbin:
            return "HttpBin"
        case .github:
            return "GitHub"
        case .downloader:
            return "Downloader"
        case .elemCellAutomaton:
            return "ElemCellAutomaton"
        case .gameOfLife:
            return "GameOfLife"
        case .physics:
            return "Physics"
        }
    }

    /// Material Symbols ligature name (rendered via the `material-symbols-outlined` font).
    var icon: String
    {
        switch self {
        case .counter:
            return "calculate"
        case .syncCounters:
            return "sync"
        case .colorFilter:
            return "tune"
        case .todo:
            return "checklist"
        case .stateDiagram:
            return "schema"
        case .stopwatch:
            return "timer"
        case .httpbin:
            return "http"
        case .github:
            return "code"
        case .downloader:
            return "download"
        case .elemCellAutomaton:
            return "grid_on"
        case .gameOfLife:
            return "cell_tower"
        case .physics:
            return "science"
        }
    }
}
