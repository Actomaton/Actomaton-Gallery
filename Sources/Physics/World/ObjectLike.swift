import SwiftUI
import VectorMath

public protocol ObjectLike: Sendable
{
    associatedtype View: SwiftUI.View

    var id: ObjectLikeID { get }

    var mass: Scalar { get }

    /// Center position of the object.
    /// - Note: This value may be relative to the previous object via `Example.absolutePosition()`.
    var position: Vector2 { get }

    var velocity: Vector2 { get }
    var force: Vector2 { get }

    func makeView(absolutePosition: CGPoint) -> View

    var touchableRect: CGRect { get }

    var isStatic: Bool { get }
}

protocol _ObjectLike: ObjectLike
{
    var mass: Scalar { get set }
    var position: Vector2 { get set }
    var velocity: Vector2 { get set }
    var force: Vector2 { get set }
}

public typealias ObjectLikeID = AnyHashable
public typealias Mass = Scalar
