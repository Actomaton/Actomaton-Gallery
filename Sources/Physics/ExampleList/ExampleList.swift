import Foundation

@MainActor
let worldExampleList: [Example] = [
    GravityUniverseExample(),
    GravitySurfaceExample(),
    SpringExample(),
    SpringPendulumExample(),
    CollisionExample(),
    GaltonBoardExample(),
]

@MainActor
let pendulumObjectWorldExampleList: [Example] = [
    PendulumExample(),
    DoublePendulumExample()
]
