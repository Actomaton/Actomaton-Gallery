// swift-tools-version:6.3
import PackageDescription

// Web UI layer (peer of `GalleryApple`): ElementaryUI pages + Actomaton `MealyDriver`
// demo machines that reuse the platform-agnostic `*Core` reducers from `GalleryCore`.
// Consumed by the runnable harness in `Examples/Wasm-Gallery`.
let package = Package(
    name: "GalleryWasm",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "GalleryWasm",
            targets: ["GalleryWasm"]),
    ],
    dependencies: [
        .package(path: "../GalleryCore"),
        .package(url: "https://github.com/Actomaton/Actomaton", branch: "main"),
        .package(url: "https://github.com/elementary-swift/elementary-ui.git", from: "0.2.2"),
        .package(url: "https://github.com/nicklockwood/VectorMath", from: "0.4.1"),
        // For `JavaScriptEventLoop.installGlobalExecutor()` so Swift Concurrency time IO
        // (`Task.sleep`, async effects) works on the browser event loop.
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", .upToNextMinor(from: "0.53.0")),
    ],
    targets: [
        .target(
            name: "GalleryWasm",
            dependencies: [
                .product(name: "ElementaryUI", package: "elementary-ui"),
                .product(name: "Actomaton", package: "Actomaton"),
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
                .product(name: "JavaScriptEventLoop", package: "JavaScriptKit"),
                "VectorMath",
                .product(name: "Counter", package: "GalleryCore"),
                .product(name: "SyncCounters", package: "GalleryCore"),
                .product(name: "Todo", package: "GalleryCore"),
                .product(name: "StateDiagram", package: "GalleryCore"),
                .product(name: "Stopwatch", package: "GalleryCore"),
                .product(name: "Downloader", package: "GalleryCore"),
                .product(name: "CommonEffects", package: "GalleryCore"),
                .product(name: "ColorFilter", package: "GalleryCore"),
                .product(name: "HttpBin", package: "GalleryCore"),
                .product(name: "GitHub", package: "GalleryCore"),
                .product(name: "ElemCellAutomaton", package: "GalleryCore"),
                .product(name: "GameOfLife", package: "GalleryCore"),
                .product(name: "Physics", package: "GalleryCore"),
            ]
        )
    ]
)
