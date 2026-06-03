// swift-tools-version:6.2

import PackageDescription

// Platform-agnostic core: portable Elm-architecture logic with no SwiftUI/UIKit
// assumptions. Built for Apple platforms AND WebAssembly (see Examples/Wasm-Gallery).
let package = Package(
    name: "GalleryCore",
    platforms: [.macOS("15.4"), .iOS("18.4"), .watchOS("11.4"), .tvOS("18.4")],
    products: [
        .library(
            name: "Counter",
            targets: ["Counter"]),
        .library(
            name: "SyncCounters",
            targets: ["SyncCounters"]),
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
            name: "Downloader",
            targets: ["Downloader"]),
        .library(
            name: "ColorFilter",
            targets: ["ColorFilter"]),
        .library(
            name: "HttpBin",
            targets: ["HttpBin"]),
        .library(
            name: "GitHub",
            targets: ["GitHub"]),
        .library(
            name: "ElemCellAutomaton",
            targets: ["ElemCellAutomaton"]),
        .library(
            name: "GameOfLife",
            targets: ["GameOfLife"]),
        .library(
            name: "Physics",
            targets: ["Physics"]),
        .library(
            name: "Geometry",
            targets: ["Geometry"]),
        .library(
            name: "CanvasPlayer",
            targets: ["CanvasPlayer"]),
        .library(
            name: "CommonInterfaces",
            targets: ["CommonInterfaces"]),
        .library(
            name: "CommonEffects",
            targets: ["CommonEffects"]),
        .library(
            name: "ActomatonUI-shim",
            targets: ["CommonEffects", "CommonInterfaces"]) // Re-export shim: `CommonInterfaces` provides the `Never`-pinned `Effect`/`Reducer` aliases.
    ],
    dependencies: [
        .package(url: "https://github.com/Actomaton/Actomaton", branch: "main"),
        .package(url: "https://github.com/nicklockwood/VectorMath", from: "0.4.1"),
    ],
    targets: [
        .target(
            name: "CommonInterfaces", // `Never`-pinned `Effect`/`Reducer` typealias shim.
            dependencies: [.product(name: "ActomatonUI", package: "Actomaton")]),
        .target(
            name: "CommonEffects",
            dependencies: [.product(name: "ActomatonUI", package: "Actomaton")]),
        .target(
            name: "Counter",
            dependencies: [
                "CommonInterfaces",
            ]),
        .target(
            name: "SyncCounters",
            dependencies: [
                "CommonInterfaces",
                "Counter",
            ]),
        .target(
            name: "Todo",
            dependencies: [
                "CommonInterfaces",
            ]),
        .target(
            name: "StateDiagram",
            dependencies: [
                "CommonInterfaces",
            ]),
        .target(
            name: "Stopwatch",
            dependencies: [
                "CommonInterfaces",
            ]),
        .target(
            name: "Downloader",
            dependencies: [
                "CommonInterfaces",
            ]),
        .target(
            name: "ColorFilter",
            dependencies: [
                "CommonInterfaces",
            ]),
        .target(
            name: "HttpBin",
            dependencies: [
                "CommonInterfaces",
            ]),
        .target(
            name: "GitHub",
            dependencies: [
                "CommonInterfaces",
            ]),
        .target(
            name: "ElemCellAutomaton",
            dependencies: [
                "CommonInterfaces",
                "CanvasPlayer",
            ]),
        .target(
            name: "GameOfLife",
            dependencies: [
                "CommonInterfaces",
                "CanvasPlayer",
                "Geometry",
            ]),
        .target(
            name: "Physics",
            dependencies: [
                "CommonInterfaces",
                "CanvasPlayer",
                "Geometry",
                "VectorMath",
            ]),
        .target(
            name: "Geometry", // Portable, CoreGraphics-free geometry (Point / Size).
            dependencies: []),
        .target(
            name: "CanvasPlayer", // Geometry-free canvas + timer player state machine.
            dependencies: [
                "CommonInterfaces",
                "Geometry",
            ]),
    ]
)
