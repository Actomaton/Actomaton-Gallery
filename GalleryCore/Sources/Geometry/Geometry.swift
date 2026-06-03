// Portable, CoreGraphics-free geometry primitives shared across the platform-agnostic
// gallery cores. Mirrors `CGPoint` / `CGSize` so the same Elm-architecture logic can run
// on Apple platforms (bridged to CoreGraphics in GalleryApple) and on WebAssembly, where
// CoreGraphics is unavailable.

// MARK: - Point

public struct Point: Equatable, Sendable
{
    public var x: Double
    public var y: Double

    public init(x: Double = 0, y: Double = 0)
    {
        self.x = x
        self.y = y
    }

    public static let zero = Point(x: 0, y: 0)
}

// MARK: - Size

public struct Size: Equatable, Sendable
{
    public var width: Double
    public var height: Double

    public init(width: Double = 0, height: Double = 0)
    {
        self.width = width
        self.height = height
    }

    public static let zero = Size(width: 0, height: 0)
}

// MARK: - Rect

public struct Rect: Equatable, Sendable
{
    public var origin: Point
    public var size: Size

    public init(origin: Point = .zero, size: Size = .zero)
    {
        self.origin = origin
        self.size = size
    }

    public init(x: Double = 0, y: Double = 0, width: Double = 0, height: Double = 0)
    {
        self.init(
            origin: Point(x: x, y: y),
            size: Size(width: width, height: height)
        )
    }

    public var minX: Double { origin.x }
    public var minY: Double { origin.y }
    public var maxX: Double { origin.x + size.width }
    public var maxY: Double { origin.y + size.height }

    public static let zero = Rect()

    public func contains(_ point: Point) -> Bool
    {
        point.x >= minX
            && point.x <= maxX
            && point.y >= minY
            && point.y <= maxY
    }

    public func insetBy(dx: Double, dy: Double) -> Rect
    {
        Rect(
            x: origin.x + dx,
            y: origin.y + dy,
            width: size.width - dx * 2,
            height: size.height - dy * 2
        )
    }
}
