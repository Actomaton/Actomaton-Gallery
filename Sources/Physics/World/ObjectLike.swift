import Foundation
import CoreGraphics
import VectorMath

public protocol ObjectLike
{
    var id: ObjectLikeID { get }

    var mass: Scalar { get }
    var position: Vector2 { get }
    var velocity: Vector2 { get }
    var force: Vector2 { get }

    var circleRect: CGRect { get }
    var circleTouchRect: CGRect { get }
}

public typealias ObjectLikeID = AnyHashable
