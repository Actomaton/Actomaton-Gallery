import Darwin

// Presets for initial objects
extension Object
{
    // Orbit: v = sqrt(G * M / R)
    static let orbitingObjects: [Object] = [
        Object(mass: 1000, position: .init(180, 200), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 + 50, 200), velocity: .init(0, -4.47)),
        Object(mass: 1, position: .init(180, 200 - 100), velocity: .init(-3.16, 0)),
        Object(mass: 1, position: .init(180, 200 + 150), velocity: .init(2.58, 0)),
    ]

    // Like a billiard.
    static let collidingObjects: [Object] = [
        Object(mass: 1, position: .init(180, 400), velocity: .init(0, -10)),
        Object(mass: 1, position: .init(180, 200), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 - 10, 200 - 10 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 + 10, 200 - 10 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 +  0, 200 - 20 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 - 20, 200 - 20 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 + 20, 200 - 20 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 - 10, 200 - 30 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 - 30, 200 - 30 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 + 10, 200 - 30 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 + 30, 200 - 30 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 +  0, 200 - 40 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 - 20, 200 - 40 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 - 40, 200 - 40 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 + 20, 200 - 40 * sqrt(3)), velocity: .init(0, 0)),
        Object(mass: 1, position: .init(180 + 40, 200 - 40 * sqrt(3)), velocity: .init(0, 0)),
    ]
}
