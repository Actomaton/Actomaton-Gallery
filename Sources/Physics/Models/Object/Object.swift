import SwiftUI
import VectorMath

public enum Object: _ObjectLike, Equatable
{
    case circle(CircleObject)
    case line(LineObject)

    public var id: ObjectLikeID
    {
        switch self {
        case let .circle(circle):
            return circle.id
        case let .line(line):
            return line.id
        }
    }

    public var mass: Scalar
    {
        get {
            switch self {
            case let .circle(circle):
                return circle.mass
            case let .line(line):
                return line.mass
            }
        }
        set {
            switch self {
            case var .circle(circle):
                circle.mass = newValue
                self = .circle(circle)
            case var .line(line):
                line.mass = newValue
                self = .line(line)
            }
        }
    }

    public var position: Vector2
    {
        get {
            switch self {
            case let .circle(circle):
                return circle.position
            case let .line(line):
                return line.position
            }
        }
        set {
            switch self {
            case var .circle(circle):
                circle.position = newValue
                self = .circle(circle)
            case var .line(line):
                line.position = newValue
                self = .line(line)
            }
        }
    }

    public var velocity: Vector2
    {
        get {
            switch self {
            case let .circle(circle):
                return circle.velocity
            case let .line(line):
                return line.velocity
            }
        }
        set {
            switch self {
            case var .circle(circle):
                circle.velocity = newValue
                self = .circle(circle)
            case var .line(line):
                line.velocity = newValue
                self = .line(line)
            }
        }
    }

    public var force: Vector2
    {
        get {
            switch self {
            case let .circle(circle):
                return circle.force
            case let .line(line):
                return line.force
            }
        }
        set {
            switch self {
            case var .circle(circle):
                circle.force = newValue
                self = .circle(circle)
            case var .line(line):
                line.force = newValue
                self = .line(line)
            }
        }
    }

    public func makeView(absolutePosition: CGPoint) -> AnyView
    {
        switch self {
        case let .circle(circle):
            return AnyView(circle.makeView(absolutePosition: absolutePosition))
        case let .line(line):
            return AnyView(line.makeView(absolutePosition: absolutePosition))
        }
    }

    public var touchableRect: CGRect
    {
        switch self {
        case let .circle(circle):
            return circle.touchableRect
        case let .line(line):
            return line.touchableRect
        }
    }

    public var isStatic: Bool
    {
        switch self {
        case let .circle(circle):
            return circle.isStatic
        case let .line(line):
            return line.isStatic
        }
    }
}
