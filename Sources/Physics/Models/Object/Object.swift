import Foundation
import CoreGraphics
import VectorMath

public struct Object: ObjectLike, Equatable
{
    public let id: ObjectLikeID = UUID()

    public internal(set) var mass: Mass
    public internal(set) var position: Vector2
    public internal(set) var velocity: Vector2
    public internal(set) var force: Vector2

    public internal(set) var radius: Scalar

    public init(
        mass: Object.Mass = 1,
        position: Vector2 = .zero,
        velocity: Vector2 = .zero,
        force: Vector2 = .zero,
        radius: Scalar = 10
    )
    {
        self.mass = mass
        self.position = position
        self.velocity = velocity
        self.force = force
        self.radius = radius
    }

    public var circleRect: CGRect
    {
        let origin = position - Vector2(radius, radius)
        let diameter = radius * 2
        return CGRect(x: origin.x, y: origin.y, width: diameter, height: diameter)
    }

    /// Expands circle's touchable area if too small (at least 28 x 28).
    public var circleTouchRect: CGRect
    {
        self.circleRect
            .insetBy(
                dx: -max(self.circleRect.width / 2, 14),
                dy: -max(self.circleRect.height / 2, 14)
            )
    }
}

// MARK: - Types

extension Object
{
    public typealias Mass = Scalar
}
