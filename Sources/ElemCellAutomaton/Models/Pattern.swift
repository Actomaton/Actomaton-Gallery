import Foundation

public struct Pattern: Identifiable, Equatable, Sendable
{
    let title: String
    let rule: UInt8 // e.g. Rule 110 (0b01101110)

    public init(rule: UInt8)
    {
        self.title = "Rule \(rule)"
        self.rule = rule
    }

    var binaryDescription: String
    {
        rule.binaryDescription
    }

    private var size: Board.Size
    {
        Board.Size(width: 8, height: 1)
    }

    public var id: String { self.title }

    func makeBoard(offsetX: Int) -> Board
    {
        let cells = (0 ..< 8).reversed()
            .map { i -> Bool in
                guard (rule & (1 << i)) != 0 else { return false }
                return true
            }

        if offsetX <= 0 {
            return Board(cells: cells, pattern: self)
        }

        var adjustedCells = [Bool](repeating: false, count: offsetX)
        adjustedCells.append(contentsOf: cells)
        return Board(cells: adjustedCells, pattern: self)
    }

    func makeBoard(size: Board.Size) -> Board
    {
        return self.makeBoard(offsetX: (size.width - self.size.width) / 2)
    }
}

// MARK: - Private

extension FixedWidthInteger {
    /// Returns a binary string representation padded with leading zeros to match the bit width.
    fileprivate var binaryDescription: String {
        let binary = String(self, radix: 2)
        let padded = String(repeating: "0", count: Self.bitWidth - binary.count) + binary
        return padded
    }
}
