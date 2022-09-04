// swift-tools-version:5.6
import PackageDescription
let package = Package(
    name: "Tokamak-Gallery",
    platforms: [.macOS(.v11), .iOS(.v13)],
    products: [
        .executable(name: "Tokamak-Gallery", targets: ["Tokamak-Gallery"])
    ],
    dependencies: [
        .package(url: "https://github.com/TokamakUI/Tokamak", from: "0.10.0"),
        .package(url: "https://github.com/Actomaton/Actomaton", branch: "wip/Tokamak")
    ],
    targets: [
        .target(
            name: "Counter",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak"),
                .product(name: "ActomatonUI", package: "Actomaton"),
            ]),
        .executableTarget(
            name: "Tokamak-Gallery",
            dependencies: [
                "Counter"
            ])
    ]
)
