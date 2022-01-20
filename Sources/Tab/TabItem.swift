import SwiftUI
import ActomatonStore

public struct TabItem<InnerState, ID>: Equatable, Identifiable, Sendable
    where InnerState: Equatable & Sendable, ID: Hashable & Sendable
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

// MARK: - @unchecked Sendable

// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.
extension Image: @unchecked Sendable {}
