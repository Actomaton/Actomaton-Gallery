import AVFoundation
import Foundation

extension CMTimeRange: CustomStringConvertible
{
    public var description: String
    {
        "\(round(start.seconds * 10) / 10)s ~ \(round(end.seconds * 10) / 10)s"
    }
}

extension String: Identifiable
{
    public var id: String
    {
        self
    }
}

extension String
{
    /// https://stackoverflow.com/questions/39488488/unescaping-backslash-in-swift/39489337
    var unescaped: String
    {
        let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\"]
        var current = self
        for entity in entities {
            let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
            let description = String(descriptionCharacters)
            current = current.replacingOccurrences(of: description, with: entity)
        }
        return current
    }
}
