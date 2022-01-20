import Foundation

public struct Pattern: Identifiable, Equatable, Sendable
{
    let title: String
    let cells: [Board.Point]

    private var size: Board.Size
    {
        self.cells.reduce(into: Board.Size(width: 0, height: 0)) { result, cell in
            result = Board.Size(width: max(result.width, cell.x), height: max(result.height, cell.y))
        }
    }

    public var id: String { self.title }

    func makeBoard(offset: Board.Point) -> Board
    {
        let cells = self.cells
            // Ignore cells that overflows the board size.
            // TODO: Board size should rather be auto-scaled.
            .compactMap { cell -> Board.Point? in
                let x = cell.x + offset.x
                if x < 0 { return nil }

                let y = cell.y + offset.y
                if y < 0 { return nil }

                return Board.Point(x: x, y: y)
            }

        return Board(cells: cells)
    }

    func makeBoard(size: Board.Size) -> Board
    {
        let offset = Board.Point(
            x: (size.width - self.size.width) / 2,
            y: (size.height - self.size.height) / 2
        )
        return self.makeBoard(offset: offset)
    }

    /// Parses plain-text Game-of-Life pattern file
    /// e.g. https://www.conwaylife.com/wiki/Plaintext
    static func parsePlainText(string: String) throws -> [Board.Point]
    {
        let lines = string.split { $0.isNewline }.filter { !$0.hasPrefix("!") }

        var cells: [Board.Point] = []

        for (row, line) in lines.enumerated() {
            for (col, char) in line.enumerated() where char == "O"  {
                cells.append(Board.Point(x: col, y: row))
            }
        }

        return cells
    }

    /// Parses Run-Length-Encoded Game-of-Life pattern file.
    /// e.g. https://www.conwaylife.com/wiki/Run_Length_Encoded
    static func parseRunLengthEncoded(string: String) throws -> [Board.Point]
    {
        let lines = string
            .split { $0.isNewline }
            .filter { !$0.hasPrefix("#") }

        guard lines.count >= 2 else { throw ParseError(message: "`lines.count >= 2` failed.") }

        var body = lines.dropFirst().joined()

        var cells: [Board.Point] = []
        var col = 0
        var row = 0

        while true {
            if body.first == "!" || body.first == nil { body = String(body.dropFirst()); break }
            if body.first == "$" { body = String(body.dropFirst()); row += 1; col = 0; continue }

            let num = Scanner(string: body).scanInt() ?? 1
            body = String(body.drop(while: ("0" ... "9").contains))

            guard let char = Scanner(string: body).scanCharacter() else {
                throw ParseError(message: "Parsing either `b` or `o` failed.")
            }

            body = String(body.dropFirst())

            if char == "o" {
                for dx in 0 ..< num {
                    cells.append(Board.Point(x: col + dx, y: row))
                }
            }

            col += num
        }

        return cells
    }

    static func parseRunLengthEncoded(url: URL) throws -> Pattern
    {
        let text = try String(contentsOf: url)

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

    static var defaultPatternNames: [String]
    {
        [
            "glider", "glidersbythedozen", "gosperglidergun", "circleoffire", "pentadecathlon", "trafficlight",
            "acorn", "herschel", "switchengine", "noahsark"
        ]
    }

    public static let empty = Pattern(title: "(Empty)", cells: [])

    public static let glider: Pattern = {
        let string = """
            "x = 3, y = 3, rule = B3/S23
            bob$2bo$3o!"
            """
        return Pattern(title: "glider", cells: try! parseRunLengthEncoded(string: string))
    }()
}
