import Foundation

public struct Pattern: Identifiable, Equatable, Sendable
{
    public let title: String
    public let cells: [Board.Point]

    public init(title: String, cells: [Board.Point])
    {
        self.title = title
        self.cells = cells
    }

    private var size: Board.Size
    {
        self.cells.reduce(into: Board.Size(width: 0, height: 0)) { result, cell in
            result = Board.Size(width: max(result.width, cell.x), height: max(result.height, cell.y))
        }
    }

    public var id: String { self.title }

    public func makeBoard(offset: Board.Point) -> Board
    {
        let cells = self.cells
            // Ignore cells that overflow negatively. Positive overflow is clipped by renderers / game size.
            .compactMap { cell -> Board.Point? in
                let x = cell.x + offset.x
                if x < 0 { return nil }

                let y = cell.y + offset.y
                if y < 0 { return nil }

                return Board.Point(x: x, y: y)
            }

        return Board(cells: cells)
    }

    public func makeBoard(size: Board.Size) -> Board
    {
        let offset = Board.Point(
            x: (size.width - self.size.width) / 2,
            y: (size.height - self.size.height) / 2
        )
        return self.makeBoard(offset: offset)
    }

    /// Parses a plain-text Game of Life pattern.
    public static func parsePlainText(string: String) throws -> [Board.Point]
    {
        let lines = string.split { $0.isNewline }.filter { !$0.hasPrefix("!") }

        var cells: [Board.Point] = []

        for (row, line) in lines.enumerated() {
            for (column, character) in line.enumerated() where character == "O" {
                cells.append(Board.Point(x: column, y: row))
            }
        }

        return cells
    }

    /// Parses a Run-Length-Encoded Game of Life pattern.
    public static func parseRunLengthEncoded(string: String) throws -> [Board.Point]
    {
        let lines = string
            .split { $0.isNewline }
            .filter { !$0.hasPrefix("#") }

        guard lines.count >= 2 else { throw ParseError(message: "`lines.count >= 2` failed.") }

        let body = lines.dropFirst().joined()

        var cells: [Board.Point] = []
        var column = 0
        var row = 0
        var runLength = 0

        for character in body {
            if let digit = character.wholeNumberValue {
                runLength = runLength * 10 + digit
                continue
            }

            let count = max(runLength, 1)
            runLength = 0

            switch character {
            case "b":
                column += count

            case "o":
                for deltaX in 0 ..< count {
                    cells.append(Board.Point(x: column + deltaX, y: row))
                }
                column += count

            case "$":
                row += count
                column = 0

            case "!":
                return cells

            default:
                if character.isWhitespace {
                    continue
                }
                throw ParseError(message: "Unexpected RLE character: \(character)")
            }
        }

        return cells
    }

    public static func parseRunLengthEncoded(url: URL) throws -> Pattern
    {
        let text = try String(contentsOf: url, encoding: .utf8)

        let assetName = url.deletingPathExtension().lastPathComponent
        let cells = try parseRunLengthEncoded(string: text)

        return Pattern(
            title: assetName,
            cells: cells
        )
    }

    private struct ParseError: Swift.Error
    {
        let message: String
    }

    // MARK: - Presets

    public static var defaultPatternNames: [String]
    {
        [
            "glider", "glidersbythedozen", "gosperglidergun", "circleoffire", "pentadecathlon", "trafficlight",
            "acorn", "herschel", "switchengine", "noahsark"
        ]
    }

    public static let empty = Pattern(title: "(Empty)", cells: [])

    public static let presets: [Pattern] = [
        .glider,
        .lightweightSpaceship,
        .gosperGliderGun,
        .pulsar,
        .pentadecathlon,
        .acorn,
        .dieHard,
        .rPentomino,
        .empty,
    ]

    public static let glider: Pattern = {
        let string = """
            x = 3, y = 3, rule = B3/S23
            bob$2bo$3o!
            """
        return makeRunLengthEncodedPreset(title: "glider", string: string)
    }()

    public static let lightweightSpaceship: Pattern = {
        let string = """
            x = 5, y = 4, rule = B3/S23
            bo2bo$o4b$o3bo$4o!
            """
        return makeRunLengthEncodedPreset(title: "lwss", string: string)
    }()

    public static let gosperGliderGun: Pattern = {
        let string = """
            x = 36, y = 9, rule = B3/S23
            24bo11b$22bobo11b$12b2o6b2o12b2o$11bo3bo4b2o12b2o$2o8bo5bo3b2o14b$2o8bo3bob2o4bobo11b$10bo5bo7bo11b$11bo3bo20b$12b2o!
            """
        return makeRunLengthEncodedPreset(title: "gosperglidergun", string: string)
    }()

    public static let pulsar: Pattern = {
        let string = """
            x = 13, y = 13, rule = B3/S23
            2b3o3b3o2b2$o4bobo4bo$o4bobo4bo$o4bobo4bo$2b3o3b3o2b2$2b3o3b3o2b$o4bobo4bo$o4bobo4bo$o4bobo4bo2$2b3o3b3o!
            """
        return makeRunLengthEncodedPreset(title: "pulsar", string: string)
    }()

    public static let pentadecathlon: Pattern = {
        let string = """
            x = 10, y = 3, rule = B3/S23
            2bo4bo2b$2ob4ob2o$2bo4bo!
            """
        return makeRunLengthEncodedPreset(title: "pentadecathlon", string: string)
    }()

    public static let acorn: Pattern = {
        let string = """
            x = 7, y = 3, rule = B3/S23
            bo5b$3bo3b$2o2b3o!
            """
        return makeRunLengthEncodedPreset(title: "acorn", string: string)
    }()

    public static let dieHard: Pattern = {
        let string = """
            x = 8, y = 3, rule = B3/S23
            6bob$2o6b$bo3b3o!
            """
        return makeRunLengthEncodedPreset(title: "diehard", string: string)
    }()

    public static let rPentomino: Pattern = {
        let string = """
            x = 3, y = 3, rule = B3/S23
            b2o$2ob$bo!
            """
        return makeRunLengthEncodedPreset(title: "rpentomino", string: string)
    }()

    private static func makeRunLengthEncodedPreset(title: String, string: String) -> Pattern
    {
        Pattern(title: title, cells: try! parseRunLengthEncoded(string: string))
    }
}
