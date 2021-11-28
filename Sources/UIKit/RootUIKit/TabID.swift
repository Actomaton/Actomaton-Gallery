import Foundation

public enum TabID: Equatable
{
    case uiKit
    case swiftUIHosting
    case settings
    case other(UUID)

    static let protectedTabIDs: [TabID] = [.settings]
}
