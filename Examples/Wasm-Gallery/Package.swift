// swift-tools-version:6.3
import PackageDescription

// Thin runnable harness: the WASM UI lives in the `GalleryWasm` package (peer of
// `GalleryApple`). This executable's `@main` just mounts `GalleryWasm.WasmGallery.run()`.
let package = Package(
    name: "Wasm-Gallery",
    platforms: [.macOS(.v26)],
    dependencies: [
        .package(path: "../../GalleryWasm"),
    ],
    targets: [
        .executableTarget(
            name: "WasmGalleryApp",
            dependencies: [
                .product(name: "GalleryWasm", package: "GalleryWasm"),
            ]
        )
    ]
)
