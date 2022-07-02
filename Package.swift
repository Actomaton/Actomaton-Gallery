// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Actomaton-Gallery",
    platforms: [.macOS(.v11), .iOS(.v14), .watchOS(.v7), .tvOS(.v14)],
    products: [
        .library(
            name: "SwiftUI-Gallery",
            targets: ["Root", "DebugRoot"]),

        .library(
            name: "UIKit-Gallery",
            targets: ["RootUIKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/inamiy/Actomaton", .branch("main")),
        .package(url: "https://github.com/inamiy/OrientationKit", from: "0.1.0"),
        .package(url: "https://github.com/inamiy/SwiftUI-PhotoPicker", .branch("main")),
        .package(url: "https://github.com/inamiy/AVFoundation-Combine", .branch("main")),
        .package(url: "https://github.com/nicklockwood/VectorMath", from: "0.4.1")
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: []),
        .target(
            name: "CommonEffects",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "CommonUI",
            dependencies: []),
        .target(
            name: "CanvasPlayer",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "ImageLoader",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "TimeTravel",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "Tab",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "Counter",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Utilities"
            ]),
        .target(
            name: "SyncCounters",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Counter"
            ]),
        .target(
            name: "AnimationDemo",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "ColorFilter",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                .product(name: "PhotoPicker", package: "SwiftUI-PhotoPicker")
            ],
            resources: [.process("Resources/")]),
        .target(
            name: "Todo",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "StateDiagram",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")],
            resources: [.process("Resources/")]),
        .target(
            name: "Stopwatch",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "CommonEffects"
            ]),
        .target(
            name: "GitHub",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Utilities", "CommonEffects", "CommonUI", "ImageLoader"
            ]),
        .target(
            name: "GameOfLife",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "CommonUI", "CanvasPlayer"
            ],
            resources: [.copy("GameOfLife-Patterns/")]),
        .target(
            name: "VideoPlayer",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "AVFoundation-Combine"
            ]),
        .target(
            name: "VideoPlayerMulti",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "VideoPlayer"
            ]),
        .target(
            name: "VideoCapture",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "OrientationKit"
            ]),
        .target(
            name: "VideoDetector",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "VideoCapture"
            ]),
        .target(
            name: "Physics",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "VectorMath",
                "CommonUI", "CanvasPlayer"
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
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),

        // MARK: - SwiftUI-Gallery

        .target(
            name: "Home",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Counter", "SyncCounters", "AnimationDemo", "ColorFilter", "Todo", "StateDiagram", "Stopwatch", "GitHub",
                "GameOfLife", "VideoPlayerMulti", "VideoDetector", "Physics", "Downloader",
                "CommonEffects", "Utilities"
            ]),
        .target(
            name: "SettingsScene", // NOTE: Avoid naming with `SwiftUI.Settings`.
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "UserSession"
            ]),
        .target(
            name: "Root",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Tab", "Home", "SettingsScene", "Counter",
                "Onboarding", "Login", "UserSession",
                "Utilities"
            ]),
        .target(
            name: "DebugRoot",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Utilities", "TimeTravel"
            ]),

        // MARK: - UIKit-Gallery

        .target(
            name: "ExampleListUIKit",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Counter", "SyncCounters", "ColorFilter", "Todo", "StateDiagram", "Stopwatch", "GitHub",
                "GameOfLife", "VideoDetector", "Physics"
            ],
            path: "Sources/UIKit/ExampleListUIKit"),

        .target(
            name: "ExamplesUIKit",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "ExampleListUIKit"
            ],
            path: "Sources/UIKit/ExamplesUIKit"),

        .target(
            name: "TabUIKit",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "ExamplesUIKit", "SettingsUIKit"
            ],
            path: "Sources/UIKit/TabUIKit"),

        .target(
            name: "SettingsUIKit",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "SettingsScene"
            ],
            path: "Sources/UIKit/SettingsUIKit"),

        .target(
            name: "RootUIKit",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "SettingsScene", "UserSession", "Onboarding", "Login",
                "TabUIKit", "ExampleListUIKit", "ExamplesUIKit"
            ],
            path: "Sources/UIKit/RootUIKit"),

        // MARK: - UserSessionNavigation

        .target(
            name: "UserSession",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton")
            ],
            path: "Sources/UserSessionNavigation/UserSession"),

        .target(
            name: "Onboarding",
            dependencies: [],
            path: "Sources/UserSessionNavigation/Onboarding"),

        .target(
            name: "Login",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Utilities"
            ],
            path: "Sources/UserSessionNavigation/Login")
    ]
)
