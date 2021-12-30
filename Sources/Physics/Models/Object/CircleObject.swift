import SwiftUI
import VectorMath

public struct CircleObject: _ObjectLike, Equatable
{
    public let id: ObjectLikeID = UUID()

    public internal(set) var mass: Mass
    public internal(set) var position: Vector2
    public internal(set) var velocity: Vector2
    public internal(set) var force: Vector2

    public internal(set) var radius: Scalar

    public init(
        mass: Mass = 1,
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

    public func makeView(absolutePosition: CGPoint) -> some SwiftUI.View
    {
        Circle()
            .position(absolutePosition)
            .frame(width: visibleRect.width, height: visibleRect.height)
            .foregroundColor(Color.green)
            .contrast(1 - 0.2 * log10(Double(mass)))
    }

    private var visibleRect: CGRect
    {
        let origin = position - Vector2(radius, radius)
        let diameter = radius * 2
        return CGRect(x: origin.x, y: origin.y, width: diameter, height: diameter)
    }

    /// Expands circle's touchable area if too small (at least 28 x 28).
    public var touchableRect: CGRect
    {
        self.visibleRect
            .insetBy(
                dx: -max(self.visibleRect.width / 2, 14),
                dy: -max(self.visibleRect.height / 2, 14)
            )
    }
}
