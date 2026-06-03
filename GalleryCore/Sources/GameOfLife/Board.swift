public struct Board: Equatable, Sendable
{
    /// Dictionary storage keeps sparse boards cheap while leaving room for neighbor-count indexing.
    fileprivate(set) var cells: [Point: Unit] = [:]

    public init(cells: [Point] = [])
    {
        self.cells = .init(uniqueKeysWithValues: cells.map { (Point(x: $0.x, y: $0.y), Unit()) })
    }

    public subscript (x: Int, y: Int) -> Bool
    {
        get {
            self.cells[Point(x: x, y: y)] != nil
        }
        set {
            self.cells[Point(x: x, y: y)] = newValue ? Unit() : nil
        }
    }

    public var liveCellPoints: [Point]
    {
        self.cells.keys.sorted {
            if $0.y == $1.y {
                return $0.x < $1.x
            }
            return $0.y < $1.y
        }
    }

    public struct Point: Hashable, Sendable
    {
        public let x: Int
        public let y: Int

        public init(x: Int, y: Int)
        {
            self.x = x
            self.y = y
        }

        public static let zero = Point(x: 0, y: 0)
    }

    public struct Size: Equatable, CustomStringConvertible, Sendable
    {
        public let width: Int
        public let height: Int

        public init(width: Int, height: Int)
        {
            self.width = width
            self.height = height
        }

        public var description: String
        {
            "\(width) × \(height)"
        }

        public static let zero = Size(width: 0, height: 0)
    }

    struct Unit: Equatable, Sendable {}
}
