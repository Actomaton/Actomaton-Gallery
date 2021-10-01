import Foundation

@MainActor
let worldExampleList: [Example] = [
    GravityUniverseExample(),
    GravitySurfaceExample(),
    SpringExample(),
    SpringPendulumExample(),
    CollisionExample(),
]

@MainActor
let pendulumObjectWorldExampleList: [Example] = [
    PendulumExample(),
    DoublePendulumExample()
]
