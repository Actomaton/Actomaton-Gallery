import SwiftUI
import ActomatonStore

public protocol Example
{
    var exampleTitle: String { get }
    var exampleIcon: Image { get }

    @MainActor
    func build() -> UIViewController
}

extension Example
{
    public var exampleTitle: String
    {
        let title = String(describing: self)
        if let index = title.range(of: "Example")?.lowerBound { // trim "-Example()"
            return String(title.prefix(upTo: index))
        }
        else {
            return title
        }
    }
}
