// swift-tools-version:6.2

import Foundation
import PackageDescription

let package = Package(
    name: "GalleryApple",
    platforms: [.macOS("15.4"), .iOS("18.4"), .watchOS("11.4"), .tvOS("18.4")],
    products: [
        .library(
            name: "CounterUI",
            targets: ["CounterUI"]),
        .library(
            name: "SwiftUI-Gallery",
            targets: ["Root", "DebugRoot", "LiveEnvironments"]),
        .library(
            name: "UIKit-Gallery",
            targets: ["RootUIKit"]),
    ],
    dependencies: [
        .package(path: "../GalleryCore"),
//        .package(name: "Actomaton", path: "../Actomaton"), // local
        .package(url: "https://github.com/Actomaton/Actomaton", branch: "main"),
//        .package(url: "https://github.com/Actomaton/Actomaton", from: "0.9.0"),
        .package(url: "https://github.com/inamiy/OrientationKit", from: "0.2.0"),
        .package(url: "https://github.com/inamiy/SwiftUI-PhotoPicker", branch: "main"),
        .package(url: "https://github.com/inamiy/AVFoundation-Combine", branch: "main"),
        .package(url: "https://github.com/nicklockwood/VectorMath", from: "0.4.1"),
        // Pin to 1.3.0 to avoid swift-issue-reporting vs xctest-dynamic-overlay target conflict.
        // .package(url: "https://github.com/pointfreeco/swift-custom-dump", exact: "1.3.0")
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: []),
        .target(
            name: "CommonUI",
            dependencies: []),
        .target(
            name: "CanvasPlayerUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "CanvasPlayer", package: "GalleryCore"),
                .product(name: "Geometry", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "CommonUI", "Utilities"
            ]),
        .target(
            name: "CellGridView", // Generic live-cell grid renderer shared by GameOfLife / ElemCellAutomaton.
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton")
            ]),
        .target(
            name: "ImageLoader",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton")]),
        .target(
            name: "TimeTravel",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton")]),
        .target(
            name: "Tabs",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "CounterUI",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                .product(name: "Counter", package: "GalleryCore"),
                "Utilities"
            ]),
        .target(
            name: "SyncCountersUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "SyncCounters", package: "GalleryCore"),
                .product(name: "Counter", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "CounterUI"
            ]),
        .target(
            name: "AnimationDemo",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "ColorFilterUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ColorFilter", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                .product(name: "PhotoPicker", package: "SwiftUI-PhotoPicker"),
                "Utilities"
            ],
            resources: [.process("Resources/")]),
        .target(
            // Direct-state-binding demo (empty `Action`, `.empty()` reducer).
            // Kept alongside the action-driven `ColorFilter` core (used by Wasm-Gallery);
            // depends on `ColorFilterUI` only to reuse its bundled `color.jpg` (no duplicate resource).
            name: "ColorFilterBindingUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                .product(name: "PhotoPicker", package: "SwiftUI-PhotoPicker"),
                "ColorFilterUI",
                "Utilities"
            ]),
        .target(
            name: "TodoUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "Todo", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "StateDiagramUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "StateDiagram", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ],
            resources: [.process("Resources/")]),
        .target(
            name: "StopwatchUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "Stopwatch", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "HttpBinUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "HttpBin", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities", "ImageLoader"
            ]),
        .target(
            name: "GitHubUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "GitHub", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities", "CommonUI", "ImageLoader"
            ]),
        .target(
            name: "ElemCellAutomatonUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ElemCellAutomaton", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "CommonUI", "CanvasPlayerUI", "CellGridView", "Utilities"
            ]),
        .target(
            name: "GameOfLifeUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "GameOfLife", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "CommonUI", "CanvasPlayerUI", "CellGridView", "Utilities"
            ],
            resources: [.copy("GameOfLife-Patterns/")]),
        .target(
            name: "VideoPlayer",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "AVFoundation-Combine", "Utilities"
            ]),
        .target(
            name: "VideoPlayerMulti",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "VideoPlayer"
            ]),
        .target(
            name: "VideoCapture",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "OrientationKit", "Utilities"
            ]),
        .target(
            name: "VideoDetector",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "VideoCapture"
            ]),
        .target(
            name: "PhysicsUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "Physics", package: "GalleryCore"),
                .product(name: "Geometry", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "VectorMath",
                "CommonUI", "CanvasPlayerUI", "Utilities"
            ],
            swiftSettings: [
                // Workaroudn for Xcode 13.3 (Swift 5.6) segfault
                // https://github.com/inamiy/Actomaton-Gallery/pull/33
                // https://twitter.com/slava_pestov/status/1503903893389983745
                .unsafeFlags({
#if swift(>=5.6) && swift(<5.7)
                    [
                        "-Xfrontend", "-requirement-machine=off",
                    ]
#else
                    []
#endif
                }())
            ]
        ),
        .target(
            name: "DownloaderUI",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "Downloader", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),

        // MARK: - SwiftUI-Gallery

        .target(
            name: "Home",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "Counter", package: "GalleryCore"),
                .product(name: "SyncCounters", package: "GalleryCore"),
                .product(name: "ColorFilter", package: "GalleryCore"),
                .product(name: "Todo", package: "GalleryCore"),
                .product(name: "StateDiagram", package: "GalleryCore"),
                .product(name: "Stopwatch", package: "GalleryCore"),
                .product(name: "HttpBin", package: "GalleryCore"),
                .product(name: "Downloader", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "CounterUI", "SyncCountersUI", "AnimationDemo", "ColorFilterUI", "ColorFilterBindingUI",
                "TodoUI", "StateDiagramUI", "StopwatchUI", "HttpBinUI", "GitHubUI", "DownloaderUI",
                "VideoPlayerMulti", "VideoDetector", "ElemCellAutomatonUI", "GameOfLifeUI", "PhysicsUI",
                "Utilities"
            ]),
        .target(
            name: "SettingsScene", // NOTE: Avoid naming with `SwiftUI.Settings`.
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "UserSession"
            ]),
        .target(
            name: "Root",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "Counter", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Tabs", "Home", "SettingsScene", "CounterUI",
                "Onboarding", "Login", "UserSession", "PhysicsUI", "UniversalLink",
                "Utilities"
            ]),
        .target(
            name: "DebugRoot",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities", "TimeTravel"
            ]),

        // MARK: - UIKit-Gallery

        .target(
            name: "ExampleListUIKit",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "Counter", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "SyncCountersUI", "ColorFilterUI", "TodoUI", "StateDiagramUI", "StopwatchUI", "GitHubUI",
                "GameOfLifeUI", "VideoDetector", "PhysicsUI"
            ],
            path: "Sources/UIKit/ExampleListUIKit"),

        .target(
            name: "ExamplesUIKit",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "Counter", package: "GalleryCore"),
                .product(name: "Todo", package: "GalleryCore"),
                .product(name: "StateDiagram", package: "GalleryCore"),
                .product(name: "Stopwatch", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "CounterUI",
                "ExampleListUIKit", "LiveEnvironments"
            ],
            path: "Sources/UIKit/ExamplesUIKit"),

        .target(
            name: "TabsUIKit",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "ExamplesUIKit", "SettingsUIKit"
            ],
            path: "Sources/UIKit/TabsUIKit"),

        .target(
            name: "SettingsUIKit",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "SettingsScene"
            ],
            path: "Sources/UIKit/SettingsUIKit"),

        .target(
            name: "RootUIKit",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "SettingsScene", "UserSession", "Onboarding", "Login",
                "TabsUIKit", "ExampleListUIKit", "ExamplesUIKit"
            ],
            path: "Sources/UIKit/RootUIKit"),

        // MARK: - UserSessionNavigation

        .target(
            name: "UserSession",
            dependencies: [
                .product(name: "CommonInterfaces", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton")
            ],
            path: "Sources/UserSessionNavigation/UserSession"),

        .target(
            name: "Onboarding",
            dependencies: [],
            path: "Sources/UserSessionNavigation/Onboarding"),

        .target(
            name: "Login",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ],
            path: "Sources/UserSessionNavigation/Login"),

        // MARK: - UniversalLink

        .target(
            name: "UniversalLink",
            dependencies: []),

        // MARK: - LiveEnvironments

        .target(
            name: "LiveEnvironments",
            dependencies: [
                .product(name: "Counter", package: "GalleryCore"),
                .product(name: "Stopwatch", package: "GalleryCore"),
                .product(name: "HttpBin", package: "GalleryCore"),
                .product(name: "GitHub", package: "GalleryCore"),
                .product(name: "Downloader", package: "GalleryCore"),
                .product(name: "CommonEffects", package: "GalleryCore"),
                .product(name: "ActomatonUI", package: "Actomaton"),
                "SyncCountersUI", "AnimationDemo", "ColorFilterUI",
                "TodoUI", "StateDiagramUI", "StopwatchUI", "HttpBinUI", "GitHubUI", "DownloaderUI",
                "VideoPlayerMulti", "VideoDetector", "ElemCellAutomatonUI", "GameOfLifeUI", "PhysicsUI",
                "Home", "Utilities"
            ])
    ]
)

// Comment-Out:
// Concurrency warning around Xcode Preview is shown too many (possibly due to compiler bug),
// so will turn off by default.
// https://github.com/apple/swift/issues/61300
//
//    for target in package.targets {
//        target.swiftSettings = [
//            .unsafeFlags([
//                "-Xfrontend", "-warn-concurrency",
//                "-Xfrontend", "-enable-actor-data-race-checks",
//            ])
//        ]
//    }
