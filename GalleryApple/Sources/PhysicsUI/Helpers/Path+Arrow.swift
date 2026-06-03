import SwiftUI

extension Path
{
    /// Makes a single arrow path.
    /// https://stackoverflow.com/questions/48625763/how-to-draw-a-directional-arrow-head
    static func arrowPath(
        start: CGPoint,
        end: CGPoint,
        pointerLength: CGFloat,
        arrowAngle: CGFloat
    ) -> Path
    {
        Path {
            let startEndAngle = atan((end.y - start.y) / (end.x - start.x))
                + ((end.x - start.x) < 0 ? CGFloat(Double.pi) : 0)

            if startEndAngle.isNaN { return }

            let arrowLine1 = CGPoint(
                x: end.x + pointerLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle),
                y: end.y - pointerLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle)
            )

            let arrowLine2 = CGPoint(
                x: end.x + pointerLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle),
                y: end.y - pointerLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle)
            )

            $0.move(to: start)
            $0.addLine(to: end)
            $0.addLine(to: arrowLine1)
            $0.move(to: end)
            $0.addLine(to: arrowLine2)
        }
    }
}
