import VectorMath
import CoreGraphics

extension CGRect
{
    init(x: Scalar, y: Scalar, width: Scalar, height: Scalar)
    {
        self.init(x: Double(x), y: Double(y), width: Double(width), height: Double(height))
    }
}

extension CGPoint
{
    init(x: Scalar, y: Scalar)
    {
        self.init(x: Double(x), y: Double(y))
    }
}
