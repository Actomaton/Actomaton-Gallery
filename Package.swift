// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Actomaton-Gallery",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(
            name: "TimeTravel",
            targets: ["TimeTravel"]),
        .library(
            name: "Counter",
            targets: ["Counter"]),
        .library(
            name: "Todo",
            targets: ["Todo"]),
        .library(
            name: "StateDiagram",
            targets: ["StateDiagram"]),
        .library(
            name: "Stopwatch",
            targets: ["Stopwatch"]),
        .library(
            name: "GitHub",
            targets: ["GitHub", "Utilities", "ImageLoader"]),
        .library(
            name: "GameOfLife",
            targets: ["GameOfLife"]),
        .library(
            name: "DebugRoot",
            targets: ["DebugRoot"]),
    ],
    dependencies: [
        .package(url: "https://github.com/inamiy/Actomaton", .branch("main"))
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "ImageLoader",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "TimeTravel",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "Counter",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "Todo",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "StateDiagram",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")],
            resources: [.process("Resources/")]),
        .target(
            name: "Stopwatch",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")]),
        .target(
            name: "GitHub",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "Utilities", "ImageLoader"
            ]),
        .target(
            name: "GameOfLife",
            dependencies: [.product(name: "ActomatonStore", package: "Actomaton")],
            resources: [.copy("GameOfLife-Patterns/")]),
        .target(
            name: "DebugRoot",
            dependencies: [
                .product(name: "ActomatonStore", package: "Actomaton"),
                "TimeTravel"
            ]),
    ]
)
