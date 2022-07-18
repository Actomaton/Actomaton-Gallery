import SwiftUI
import ActomatonUI

public protocol Example: Sendable
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

#if swift(>=5.7)
public typealias AnyExample = any Example
#else
public typealias AnyExample = Example
#endif

func examplesAreEqual(_ examples1: [AnyExample], _ examples2: [AnyExample]) -> Bool
{
    examples1.map(\.exampleTitle) == examples2.map(\.exampleTitle)
}
