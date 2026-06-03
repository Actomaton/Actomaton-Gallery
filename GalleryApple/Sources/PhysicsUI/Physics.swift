// SwiftUI `Physics` facade over the platform-agnostic `Physics`.
//
// All of the Elm-architecture logic (`PhysicsRoot` / `World` / `Object` / `Bob` /
// `PhysicsExampleID`, reducers, presets) now lives in `GalleryCore`'s `Physics`
// using portable `Geometry` types, and is shared verbatim with `GalleryWasm`.
//
// This module only adds the SwiftUI rendering layer (`PhysicsRootView` / `WorldView` /
// `makeView` extensions) on top, bridging CoreGraphics `CGPoint` / `CGSize` <-> the
// portable `Geometry.Point` / `Size` carried by the core's state.
//
// Re-export `Physics` so existing consumers (`Home` / `Root` / UIKit /
// `LiveEnvironments`) keep working with just `import Physics`.
@_exported import Physics
