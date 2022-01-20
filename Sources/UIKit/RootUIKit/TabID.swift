import Foundation

public enum TabID: Equatable, Sendable
{
    case uiKit
    case swiftUIHosting
    case settings
    case other(UUID)

    static let protectedTabIDs: [TabID] = [.settings]
}
