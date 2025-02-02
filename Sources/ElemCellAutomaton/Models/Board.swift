struct Board: Equatable
{
    fileprivate(set) var cells: [[Bool]] = []

    var pattern: Pattern

    /// Initial empty leading cells count.
    private let initialOffsetX: Int

    /// Rule 0-255 contains 8 cells.
    private let initialCellCount = 8

    /// Additional empty leading cells count to make entire cells longer to mitigate edge calculation. (Larger value is better)
    private let additionalOffsetX: Int = 1000

    init(cells: [Bool], pattern: Pattern)
    {
        var adjustedCells = [Bool](repeating: false, count: additionalOffsetX)
        adjustedCells.append(contentsOf: cells)

        self.cells = [adjustedCells]
        self.pattern = pattern
        self.initialOffsetX = adjustedCells.count - initialCellCount
        print("pattern = \(pattern.binaryDescription)")
    }

    subscript (x: Int, y: Int) -> Bool
    {
        let x = x + additionalOffsetX
        guard y < self.cells.count else { return false }
        guard x < self.cells[y].count else { return false }
        return self.cells[y][x]
    }

    var liveCellPoints: [Point]
    {
        self.cells.enumerated()
            .flatMap { y, row in
                row.enumerated().compactMap { x, elem in
                    if elem {
                        let x = x - additionalOffsetX
                        return Point(x: x, y: y)
                    } else {
                        return nil
                    }
                }
            }
    }
}

// MARK: - Run next tick

extension Board {
    // https://en.wikipedia.org/wiki/Elementary_cellular_automaton
    mutating func tick() {
        var newRow = [Bool]()
        let currentRow = self.cells[cells.count - 1]
        let currentRowCount = currentRow.count

        if currentRowCount == 0 {
            self.cells.append(newRow)
            return
        }

        /// Check Rule `0b␣␣␣␣␣␣␣0` which has `000 -> 0` transition rule.
        let threeEmptyCellIsEmpty = self.pattern.rule & 1 == 0

        let newRowCount: Int = if threeEmptyCellIsEmpty {
            currentRowCount + 1
        } else {
            (additionalOffsetX + initialOffsetX) * 2 + initialCellCount
        }

        for i in 0 ..< newRowCount {
            let currentLeft = i == 0
                ? (currentRow[currentRow.endIndex - 1] == true ? 1 : 0)
                : (currentRow[safe: i - 1] == true ? 1 : 0)
            let currentMid = currentRow[safe: i] == true ? 1 : 0
            let currentRight = currentRow[safe: i + 1] == true ? 1 : 0
            let inputPattern = (currentLeft << 2 | currentMid << 1 | currentRight) // 0 to 7
            newRow.append((self.pattern.rule & (1 << inputPattern)) != 0)
        }
        self.cells.append(newRow)
    }

    mutating func trimOldCellsToFit(maxHeight: Int) {
        let removingCount = self.cells.count - maxHeight
        guard removingCount > 0 else { return }

        self.cells.removeFirst(removingCount)
    }
}

// MARK: - Types

extension Board {
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
}
