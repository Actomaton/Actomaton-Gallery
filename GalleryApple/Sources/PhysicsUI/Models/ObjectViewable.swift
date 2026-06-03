import SwiftUI
import VectorMath
import Physics

/// SwiftUI rendering for a physics object.
///
/// The geometry-free object models (`CircleObject` / `LineObject` / `Object` / `Bob`)
/// live in `Physics`; this Apple-side protocol re-attaches their SwiftUI views so
/// `WorldView` can render any `Obj` generically (the WASM gallery renders the same models
/// imperatively onto a `<canvas>` instead).
@MainActor
protocol ObjectViewable: ObjectLike
{
    associatedtype RenderedView: View

    @ViewBuilder
    func makeView(absolutePosition: CGPoint) -> RenderedView
}

extension CircleObject: ObjectViewable
{
    func makeView(absolutePosition: CGPoint) -> some View
    {
        let diameter = CGFloat(radius * 2)

        return Circle()
            .position(absolutePosition)
            .frame(width: diameter, height: diameter)
            .foregroundColor(Color.green)
            .contrast(1 - 0.2 * log10(Double(mass)))
    }
}

extension Bob: ObjectViewable
{
    func makeView(absolutePosition: CGPoint) -> some View
    {
        let diameter = CGFloat(radius * 2)

        return Circle()
            .position(absolutePosition)
            .frame(width: diameter, height: diameter)
            .foregroundColor(Color.green)
            .contrast(1 - 0.2 * log10(Double(mass)))
    }
}

extension LineObject: ObjectViewable
{
    func makeView(absolutePosition: CGPoint) -> some View
    {
        Path { path in
            path.move(to: CGPoint(x: startPosition.x, y: startPosition.y))
            path.addLine(to: CGPoint(x: endPosition.x, y: endPosition.y))
        }
        .stroke(lineWidth: CGFloat(width))
        .fill(Color.red)
    }
}

extension Object: ObjectViewable
{
    func makeView(absolutePosition: CGPoint) -> AnyView
    {
        switch self {
        case let .circle(circle):
            return AnyView(circle.makeView(absolutePosition: absolutePosition))
        case let .line(line):
            return AnyView(line.makeView(absolutePosition: absolutePosition))
        }
    }
}
