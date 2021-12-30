import SwiftUI
import VectorMath

/// Pendulum's weight object.
public struct Bob: Equatable
{
    public let id: ObjectLikeID = UUID()

    public internal(set) var mass: Mass
    public internal(set) var rodLength: Scalar
    public internal(set) var angle: Scalar
    public internal(set) var angleVelocity: Scalar
    public internal(set) var angleAcceleration: Scalar

    public internal(set) var radius: Scalar

    public init(
        mass: Bob.Mass = 1,
        rodLength: Scalar,
        angle: Scalar = .zero,
        angleVelocity: Scalar = .zero,
        radius: Scalar = 10
    )
    {
        self.mass = mass
        self.rodLength = rodLength
        self.angle = angle
        self.angleVelocity = angleVelocity
        self.angleAcceleration = .zero
        self.radius = radius
    }
}

// MARK: - ObjectLike

extension Bob: ObjectLike
{
    /// - Note: This position is a **relative position** from previous object's position.
    public var position: Vector2
    {
        Vector2(rodLength * sin(angle), rodLength * cos(angle))
    }

    public var velocity: Vector2
    {
        tangentNorm * rodLength * angleVelocity // rω
    }

    public var force: Vector2
    {
        tangentNorm * rodLength * angleAcceleration * mass // mrω'
    }

    public func makeView(absolutePosition: CGPoint) -> some SwiftUI.View
    {
        Circle()
            .position(absolutePosition)
            .frame(width: visibleRect.width, height: visibleRect.height)
            .foregroundColor(Color.green)
            .contrast(1 - 0.2 * log10(Double(mass)))
    }

    /// - Note: Using **relative position** from previous object's position.
    private var visibleRect: CGRect
    {
        let origin = position - Vector2(radius, radius)
        let diameter = radius * 2
        return CGRect(x: origin.x, y: origin.y, width: diameter, height: diameter)
    }

    /// Expands circle's touchable area if too small (at least 28 x 28).
    /// - Note: Using **relative position** from previous object's position. 
    public var touchableRect: CGRect
    {
        self.visibleRect
            .insetBy(
                dx: -max(self.visibleRect.width / 2, 14),
                dy: -max(self.visibleRect.height / 2, 14)
            )
    }

    public var isStatic: Bool
    {
        false
    }

    fileprivate var tangentNorm: Vector2
    {
        position.normalized().rotated(by: -.halfPi)
    }
}

// MARK: - Types

extension Bob
{
    public typealias ID = UUID
    public typealias Mass = Scalar
}

/// 1st-order differentiation of `Bob`'s `angle` and `angleVelocity`.
public struct ΔBob
{
    /// dθ/dt
    public var dθdt: Scalar

    /// dω/dt
    public var dωdt: Scalar

    public init(dθdt: Scalar, dωdt: Scalar)
    {
        self.dθdt = dθdt
        self.dωdt = dωdt
    }

    public static var empty: ΔBob
    {
        .init(dθdt: 0, dωdt: 0)
    }
}
