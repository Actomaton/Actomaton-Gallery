import Foundation
import Geometry
import VectorMath

public struct CircleObject: _ObjectLike, Equatable
{
    public let id: ObjectLikeID = UUID()

    public internal(set) var mass: Mass
    public internal(set) var position: Vector2
    public internal(set) var velocity: Vector2
    public internal(set) var force: Vector2

    public internal(set) var radius: Scalar

    public let isStatic: Bool

    public init(
        mass: Mass = 1,
        position: Vector2 = .zero,
        velocity: Vector2 = .zero,
        force: Vector2 = .zero,
        radius: Scalar = 10,
        isStatic: Bool = false
    )
    {
        self.mass = mass
        self.position = position
        self.velocity = velocity
        self.force = force
        self.radius = radius
        self.isStatic = isStatic
    }

    private var visibleRect: Rect
    {
        let origin = position - Vector2(radius, radius)
        let diameter = radius * 2
        return Rect(
            x: Double(origin.x),
            y: Double(origin.y),
            width: Double(diameter),
            height: Double(diameter)
        )
    }

    /// Expands circle's touchable area if too small (at least 28 x 28).
    public var touchableRect: Rect
    {
        self.visibleRect
            .insetBy(
                dx: -Double(max(self.visibleRect.size.width / 2, 14)),
                dy: -Double(max(self.visibleRect.size.height / 2, 14))
            )
    }
}
