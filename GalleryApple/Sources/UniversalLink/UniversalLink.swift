import Foundation

/// Universal Link routes.
public enum Route
{
    /// e.g. "/"
    case home

    /// e.g. "/counter?count=3"
    case counter(count: Int)

    /// e.g. "/physics"
    case physicsRoot

    /// e.g. "/physics/gravity-universe"
    /// - Warning: Due to SwiftUI `NavigationView` limitation, this only works when ``physicsRoot`` is visible.
    case physicsGravityUniverse

    /// e.g. "/tab?index=2"
    case tab(index: Int)

    /// Naive parser using `URLComponents`.
    public init?(url: URL)
    {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        let queryItems = urlComponents.queryItems ?? []

        print("[UniversalLink] url.pathComponents", url.pathComponents)
        print("[UniversalLink] queryItems", queryItems)

        switch url.pathComponents {
        case ["/"]:
            self = .home

        case ["/", "counter"]:
            let count = queryItems.first(where: { $0.name == "count" })
                .flatMap { $0.value }
                .flatMap(Int.init) ?? 0

            self = .counter(count: count)

        case ["/", "physics"]:
            self = .physicsRoot

        case ["/", "physics", "gravity-universe"]:
            self = .physicsGravityUniverse

        case ["/", "tab"]:
            let index = queryItems.first(where: { $0.name == "index" })
                .flatMap { $0.value }
                .flatMap(Int.init)

            guard let index = index else { return nil }
            self = .tab(index: index)

        default:
            return nil
        }
    }
}
