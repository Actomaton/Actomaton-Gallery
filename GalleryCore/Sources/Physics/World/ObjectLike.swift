import Foundation
import Geometry
import VectorMath

public protocol ObjectLike: Sendable
{
    var id: ObjectLikeID { get }

    var mass: Scalar { get }

    /// Center position of the object.
    /// - Note: This value may be relative to the previous object via `Example.absolutePosition()`.
    var position: Vector2 { get }

    var velocity: Vector2 { get }
    var force: Vector2 { get }

    var touchableRect: Rect { get }

    var isStatic: Bool { get }
}

protocol _ObjectLike: ObjectLike
{
    var mass: Scalar { get set }
    var position: Vector2 { get set }
    var velocity: Vector2 { get set }
    var force: Vector2 { get set }
}

public typealias ObjectLikeID = UUID
public typealias Mass = Scalar
