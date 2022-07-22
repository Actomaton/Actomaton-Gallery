struct Board: Equatable
{
    /// - Note: Dictionary structure is for future survival counting.
    fileprivate(set) var cells: [Point: Unit] = [:]

    init(cells: [Point] = [])
    {
        self.cells = .init(uniqueKeysWithValues: cells.map { (Point(x: $0.x, y: $0.y), .init()) })
    }

    subscript (x: Int, y: Int) -> Bool
    {
        get {
            self.cells[Point(x: x, y: y)] != nil
        }
        set {
            self.cells[Point(x: x, y: y)] = newValue ? Unit() : nil
        }
    }

    var liveCellPoints: [Point]
    {
        self.cells.map { $0.key }
    }

    struct Point: Hashable
    {
        let x: Int
        let y: Int

        static var zero: Size { .init(width: 0, height: 0) }
    }

    struct Size: Equatable, CustomStringConvertible
    {
        let width: Int
        let height: Int

        var description: String
        {
            "\(width) × \(height)"
        }

        static var zero: Size { .init(width: 0, height: 0) }
    }

    struct Unit: Equatable {}
}
