import Foundation

/// Fixed flag choosing which ColorFilter demo to show in the gallery:
/// - `true`  → `ColorFilterBindingUI` (self-contained, direct-state-binding; reducer does not run).
/// - `false` → action-driven `ColorFilter` (uses `ColorFilter`, also reused by Wasm-Gallery).
private let usesColorFilterBindingUI = true

@MainActor
let exampleList: [Example] = [
    CounterExample(),
    SyncCountersExample(),
    AnimationExample(),
    usesColorFilterBindingUI ? ColorFilterBindingExample() : ColorFilterExample(),
    TodoExample(),
    StateDiagramExample(),
    StopwatchExample(),
    HttpBinExample(),
    GitHubExample(),
    DownloaderExample(),
    VideoPlayerExample(),
    VideoPlayerMultiExample(),
    VideoDetectorExample(),
    ElemCellAutomatonExample(),
    GameOfLifeExample(),
    PhysicsExample(),
]
