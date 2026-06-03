import Geometry
import VectorMath

extension Point
{
    init(_ vector: Vector2)
    {
        self.init(x: Double(vector.x), y: Double(vector.y))
    }
}

extension Vector2
{
    init(_ point: Point)
    {
        self.init(Scalar(point.x), Scalar(point.y))
    }
}

extension Vector2: @retroactive @unchecked Sendable {}
