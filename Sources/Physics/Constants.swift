import Foundation
import CoreGraphics
import VectorMath

let maxObjectCount: Int = 1024

/// Simulated delta time per tick.
let delta_t: Scalar = 1

/// World canvas rect where `Object` can live.
let worldRect = CGRect(x: -tooFar, y: -tooFar, width: tooFar * 2, height: tooFar * 2)

private let tooFar: CGFloat = 1_000
