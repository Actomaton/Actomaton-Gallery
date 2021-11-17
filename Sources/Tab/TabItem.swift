import SwiftUI
import ActomatonStore

public struct TabItem<InnerState, ID>: Equatable, Identifiable
    where InnerState: Equatable, ID: Hashable
{
    public var id: ID

    public var state: InnerState

    public var tabItemTitle: String
    public var tabItemIcon: Image

    public init(
        id: ID,
        state: InnerState,
        tabItemTitle: String,
        tabItemIcon: Image
    ) {
        self.id = id
        self.state = state
        self.tabItemTitle = tabItemTitle
        self.tabItemIcon = tabItemIcon
    }
}
