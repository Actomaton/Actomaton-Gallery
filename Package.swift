// swift-tools-version:5.9

import Foundation
import PackageDescription

let package = Package(
    name: "Actomaton-Gallery",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(
            name: "SwiftUI-Gallery",
            targets: ["Root", "DebugRoot", "LiveEnvironments"]),
        .library(
            name: "UIKit-Gallery",
            targets: ["RootUIKit"]),
        .library(
            name: "ActomatonUI-shim",
            targets: ["CommonEffects"]) // Use non-empty `CommonEffects` as a handy re-export shim.
    ],
    dependencies: [
//        .package(name: "Actomaton", path: "../Actomaton"), // local
        .package(url: "https://github.com/inamiy/Actomaton", from: "0.9.0"),
        .package(url: "https://github.com/inamiy/OrientationKit", from: "0.2.0"),
        .package(url: "https://github.com/inamiy/SwiftUI-PhotoPicker", branch: "main"),
        .package(url: "https://github.com/inamiy/AVFoundation-Combine", branch: "main"),
        .package(url: "https://github.com/nicklockwood/VectorMath", from: "0.4.1")
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: []),
        .target(
            name: "CommonEffects",
            dependencies: [.product(name: "ActomatonUI", package: "Actomaton")]),
        .target(
            name: "CommonUI",
            dependencies: []),
        .target(
            name: "CanvasPlayer",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "ImageLoader",
            dependencies: [.product(name: "ActomatonUI", package: "Actomaton")]),
        .target(
            name: "TimeTravel",
            dependencies: [.product(name: "ActomatonUI", package: "Actomaton")]),
        .target(
            name: "Tabs",
            dependencies: [.product(name: "ActomatonUI", package: "Actomaton")]),
        .target(
            name: "Counter",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "SyncCounters",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Counter"
            ]),
        .target(
            name: "AnimationDemo",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "ColorFilter",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                .product(name: "PhotoPicker", package: "SwiftUI-PhotoPicker"),
                "Utilities"
            ],
            resources: [.process("Resources/")]),
        .target(
            name: "Todo",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "StateDiagram",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ],
            resources: [.process("Resources/")]),
        .target(
            name: "Stopwatch",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "HttpBin",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities", "ImageLoader"
            ]),
        .target(
            name: "GitHub",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities", "CommonUI", "ImageLoader"
            ]),
        .target(
            name: "ElemCellAutomaton",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "CanvasPlayer", "Utilities"
            ]),
        .target(
            name: "GameOfLife",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "CommonUI", "CanvasPlayer", "Utilities"
            ],
            resources: [.copy("GameOfLife-Patterns/")]),
        .target(
            name: "VideoPlayer",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "AVFoundation-Combine", "Utilities"
            ]),
        .target(
            name: "VideoPlayerMulti",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "VideoPlayer"
            ]),
        .target(
            name: "VideoCapture",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "OrientationKit", "Utilities"
            ]),
        .target(
            name: "VideoDetector",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "VideoCapture"
            ]),
        .target(
            name: "Physics",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "VectorMath",
                "CommonUI", "CanvasPlayer", "Utilities"
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
            name: "Downloader",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities"
            ]),

        // MARK: - SwiftUI-Gallery

        .target(
            name: "Home",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Counter", "SyncCounters", "AnimationDemo", "ColorFilter",
                "Todo", "StateDiagram", "Stopwatch", "HttpBin", "GitHub", "Downloader",
                "VideoPlayerMulti", "VideoDetector", "ElemCellAutomaton", "GameOfLife", "Physics",
                "Utilities"
            ]),
        .target(
            name: "SettingsScene", // NOTE: Avoid naming with `SwiftUI.Settings`.
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "UserSession"
            ]),
        .target(
            name: "Root",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Tabs", "Home", "SettingsScene", "Counter",
                "Onboarding", "Login", "UserSession", "UniversalLink",
                "Utilities"
            ]),
        .target(
            name: "DebugRoot",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Utilities", "TimeTravel"
            ]),

        // MARK: - UIKit-Gallery

        .target(
            name: "ExampleListUIKit",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Counter", "SyncCounters", "ColorFilter", "Todo", "StateDiagram", "Stopwatch", "GitHub",
                "GameOfLife", "VideoDetector", "Physics"
            ],
            path: "Sources/UIKit/ExampleListUIKit"),

        .target(
            name: "ExamplesUIKit",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "ExampleListUIKit", "LiveEnvironments"
            ],
            path: "Sources/UIKit/ExamplesUIKit"),

        .target(
            name: "TabsUIKit",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "ExamplesUIKit", "SettingsUIKit"
            ],
            path: "Sources/UIKit/TabsUIKit"),

        .target(
            name: "SettingsUIKit",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "SettingsScene"
            ],
            path: "Sources/UIKit/SettingsUIKit"),

        .target(
            name: "RootUIKit",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "SettingsScene", "UserSession", "Onboarding", "Login",
                "TabsUIKit", "ExampleListUIKit", "ExamplesUIKit"
            ],
            path: "Sources/UIKit/RootUIKit"),

        // MARK: - UserSessionNavigation

        .target(
            name: "UserSession",
            dependencies: [
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
            dependencies: [],
            path: "Sources/UniversalLink"),

        // MARK: - LiveEnvironments

        .target(
            name: "LiveEnvironments",
            dependencies: [
                .product(name: "ActomatonUI", package: "Actomaton"),
                "Counter", "SyncCounters", "AnimationDemo", "ColorFilter",
                "Todo", "StateDiagram", "Stopwatch", "HttpBin", "GitHub", "Downloader",
                "VideoPlayerMulti", "VideoDetector", "GameOfLife", "Physics",
                "Home",
                "CommonEffects", "Utilities"
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
