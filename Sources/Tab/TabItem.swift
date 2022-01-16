import SwiftUI
import ActomatonStore

public struct TabItem<InnerState, ID>: Equatable, Identifiable
    where InnerState: Equatable, ID: Hashable
{
    public var id: ID

    public var inner: InnerState

    public var tabItemTitle: String
    public var tabItemIcon: Image

    public init(
        id: ID,
        inner: InnerState,
        tabItemTitle: String,
        tabItemIcon: Image
    ) {
        self.id = id
        self.inner = inner
        self.tabItemTitle = tabItemTitle
        self.tabItemIcon = tabItemIcon
    }
}
