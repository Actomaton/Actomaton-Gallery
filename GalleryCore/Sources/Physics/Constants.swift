import Foundation
import Geometry
import VectorMath

let maxObjectCount: Int = 1024

/// World canvas rect where `Object` can live.
let worldRect = Rect(
    x: -Double(tooFar),
    y: -Double(tooFar),
    width: Double(tooFar * 2),
    height: Double(tooFar * 2)
)

private let tooFar: Scalar = 1_000
