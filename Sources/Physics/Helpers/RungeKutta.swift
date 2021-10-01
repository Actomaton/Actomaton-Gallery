import VectorMath

/// Runge–Kutta 4th-order method solving `dx/dt = f(x)` .
/// https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods
func rungeKutta(dt: Scalar, f: (_ x: Scalar, _ t: Scalar) -> Scalar, x: Scalar, t: Scalar) -> Scalar
{
    let t2 = dt / 2

    let k1 = f(x, t)
    let k2 = f(x + t2 * k1, t + t2)
    let k3 = f(x + t2 * k2, t + t2)
    let k4 = f(x + dt * k3, t + dt)
    return x + dt * (k1 + 2 * k2 + 2 * k3 + k4) / 6
}

/// Runge–Kutta for `Bob`.
func rungeKutta(dt: Scalar, f: ([Bob]) -> [ΔBob], bobs: [Bob]) -> [Bob]
{
    bobs.enumerated().map { i, bob in
        var bob = bob
        bob.angle = rungeKutta(dt: dt, f: { angle, _ in f(bobs)[i].dθdt }, x: bob.angle, t: 0)
        bob.angleVelocity = rungeKutta(dt: dt, f: { angle, _ in f(bobs)[i].dωdt }, x: bob.angleVelocity, t: 0)
        bob.angleAcceleration = f(bobs)[i].dωdt * bob.rodLength * bob.mass
        return bob
    }
}
