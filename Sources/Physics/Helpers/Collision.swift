import Foundation
import CoreGraphics
import VectorMath

// MARK: - Manifold

/// Collision manifold as the result of collision detection.
private struct Manifold
{
    /// Depth of penetrated length.
    var overlap: Scalar

    /// Normal vector of the collision surface.
    var normal: Vector2

    init(overlap: Scalar, normal: Vector2)
    {
        self.overlap = overlap
        self.normal = normal
    }
}

// MARK: - Collision Detection

/// Circle-to-clrcle collision detection.
private func detectCirclesCollision(circle1: CircleObject, circle2: CircleObject) -> Manifold?
{
    let posDiff = circle1.position - circle2.position
    let posDiffNormal = posDiff.normalized()
    let overlap = circle1.radius + circle2.radius - posDiff.length

    guard overlap > 0 else { return nil }

    return Manifold(overlap: overlap, normal: posDiffNormal)
}

/// Line-to-clrcle collision detection.
private func detectLineCircleCollision(line: LineObject, circle: CircleObject) -> Manifold?
{
    let fromCenter = circle.position - line.startPosition
    let toCenter = circle.position - line.endPosition
    let fromTo = line.endPosition - line.startPosition

    let innerProd = fromCenter.dot(fromTo)

    if innerProd < 0 {
        guard pow(circle.radius, 2) > fromCenter.lengthSquared else { return nil }
        return Manifold(overlap: circle.radius - fromCenter.length, normal: fromCenter.normalized())
    }
    else if innerProd > fromTo.lengthSquared {
        guard pow(circle.radius, 2) > toCenter.lengthSquared else { return nil }
        return Manifold(overlap: circle.radius - toCenter.length, normal: toCenter.normalized())
    }
    else {
        /// Distance of line and center of the circle.
        let distance = fromTo.cross(fromCenter) / fromTo.length
        let overlap = circle.radius - abs(distance) + line.width / 2

        guard overlap > 0 else { return nil }

        if distance >= 0 {
            // Rotate `fromTo` -90 deg clockwise.
            return Manifold(overlap: overlap, normal: Vector2(fromTo.y, -fromTo.x).normalized())
        }
        else {
            // Rotate `fromTo` 90 deg clockwise.
            return Manifold(overlap: overlap, normal: Vector2(-fromTo.y, fromTo.x).normalized())
        }
    }
}

// MARK: - Object Collision Resolution

/// Line-to-clrcle collision detection.
@discardableResult
func resolveCircleCollision(circles: inout [CircleObject], at1 i: Int, at2 j: Int) -> Bool
{
    let obj = circles[i]
    let other = circles[j]

    guard let manifold = detectCirclesCollision(circle1: obj, circle2: other) else { return false }

    _resolveCollision(objects: &circles, at1: i, at2: j, manifold: manifold)

    return true
}

/// Evaluates `manifold` to modify `objects` velocity and position.
private func _resolveCollision<Obj>(objects: inout [Obj], at1 i: Int, at2 j: Int, manifold: Manifold)
    where Obj: _ObjectLike
{
    let obj1 = objects[i]
    let obj2 = objects[j]

    let overlap = manifold.overlap
    let normal = manifold.normal

    let (weightRatio1, weightRatio2) = weightRatios(obj1.mass, obj2.mass)

    // 2-objects collision https://en.wikipedia.org/wiki/Elastic_collision
    // NOTE: Formula is derived from conservation of kinetic energy and conservation of momentum.
    let coeff = (obj1.velocity - obj2.velocity).dot(normal) * 2

    objects[i].velocity = obj1.velocity - normal * weightRatio2 * coeff
    objects[j].velocity = obj2.velocity + normal * weightRatio1 * coeff

    // Sliding
    objects[i].position = obj1.position + normal * weightRatio2 * overlap
    objects[j].position = obj2.position - normal * weightRatio1 * overlap
}

/// Objects collision resolution.
func resolveCollision(objects: inout [Object], at1 i: Int, at2 j: Int)
{
    switch (objects[i], objects[j]) {
    case let (.circle(circle1), .circle(circle2)):
        var circles = [circle1, circle2]
        if resolveCircleCollision(circles: &circles, at1: 0, at2: 1) {
            objects[i] = .circle(circles[0])
            objects[j] = .circle(circles[1])
        }

    case let (.line(line), .circle(circle)):
        guard let manifold = detectLineCircleCollision(line: line, circle: circle) else { break }

        _resolveCollision(objects: &objects, at1: i, at2: j, manifold: manifold)

    case (.circle, .line):
        resolveCollision(objects: &objects, at1: j, at2: i)

    default:
        break
    }
}

// MARK: - Wall Collision Resolution

/// Circle-to-wall collision resolution.
func resolveCircleWallCollision(circle: inout CircleObject, boardSize: CGSize)
{
    let restitution: Float = 0.8
    let friction: Float = 0.0005

    // Flip `velocity.x` if reached at the edge of `canvasSize`.
    // WARNING: No continuous collision detection.
    if circle.position.x - circle.radius < 0 {
        circle.velocity.x = abs(circle.velocity.x) * restitution
        circle.position.x = circle.radius // sliding
    }
    else if circle.position.x + circle.radius > Scalar(boardSize.width) {
        circle.velocity.x = -abs(circle.velocity.x) * restitution
        circle.position.x = Scalar(boardSize.width) - circle.radius // sliding
    }

    // Flip `velocity.y` if reached at the edge of `canvasSize`.
    if circle.position.y - circle.radius < 0 {
        circle.velocity.y = abs(circle.velocity.y) * restitution
        circle.position.y = circle.radius // sliding
    }
    else if circle.position.y + circle.radius > Scalar(boardSize.height) {
        circle.velocity.y = -abs(circle.velocity.y) * restitution
        circle.position.y = Scalar(boardSize.height) - circle.radius // sliding
    }

    // Friction as opposite direction of velocity.
    circle.force = circle.force - circle.velocity.normalized() * friction
}

/// Object-to-wall collision resolution.
func resolveWallCollision(object: inout Object, boardSize: CGSize)
{
    switch object {
    case var .circle(circle):
        resolveCircleWallCollision(circle: &circle, boardSize: boardSize)
        object = .circle(circle)

    default:
        break
    }
}

// MARK: - Helpers

private func weightRatios(_ mass1: Scalar, _ mass2: Scalar) -> (Scalar, Scalar)
{
    switch (mass1.isInfinite, mass2.isInfinite) {
    case (true, true):
        return (0.5, 0.5)

    case (true, false):
        return (1, 0)

    case (false, true):
        return (0, 1)

    case (false, false):
        return (mass1 / (mass1 + mass2), mass2 / (mass1 + mass2))
    }
}
