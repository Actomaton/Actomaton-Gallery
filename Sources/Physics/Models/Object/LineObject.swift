import SwiftUI
import VectorMath

public struct LineObject: _ObjectLike, Equatable
{
    public let id: ObjectLikeID = UUID()

    public internal(set) var startPosition: Vector2
    public internal(set) var endPosition: Vector2
    public internal(set) var width: Scalar
    public internal(set) var isFinalized: Bool

    public init(
        startPosition: Vector2 = .zero,
        endPosition: Vector2 = .zero,
        width: Scalar = 10,
        isFinalized: Bool = true
    )
    {
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.width = width
        self.isFinalized = isFinalized
    }

    public var mass: Scalar
    {
        get { Scalar.infinity }
        set {}
    }

    public var position: Vector2
    {
        get { (startPosition + endPosition) / 2 }
        set {}
    }

    public var velocity: Vector2
    {
        get { .zero }
        set {}
    }

    public var force: Vector2
    {
        get { .zero }
        set {}
    }

    public func makeView(absolutePosition: CGPoint) -> some SwiftUI.View
    {
        Path { path in
            path.move(to: CGPoint(x: startPosition.x, y: startPosition.y))
            path.addLine(to: CGPoint(x: endPosition.x, y: endPosition.y))
        }
        .stroke(lineWidth: CGFloat(width))
        .fill(Color.red)
    }

    private var visibleRect: CGRect
    {
        .zero
    }

    public var touchableRect: CGRect
    {
        .zero
    }
}
