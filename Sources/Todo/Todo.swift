import Foundation
import ActomatonUI

// MARK: - Action

public enum Action: Sendable
{
    case updateNewText(String)
    case createTodo
    case updateText(Item.ID, String)
    case toggleCompleted(Item.ID)
    case updateDisplayMode(DisplayMode)
    case toggleEdit
    case delete(IndexSet)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    fileprivate var items: [Item] = [
        .init(id: -1, text: "🍎 Buy Apple", isCompleted: false),
        .init(id: -2, text: "🏃 Run 5 km", isCompleted: false),
        .init(id: -3, text: "🤖 Learn Actomaton", isCompleted: true),
    ]

    public var newText: String = ""

    public var displayMode: DisplayMode = .all

    public var isEditing: Bool = false

    fileprivate var nextItemID: Item.ID = 1

    public var visibleItems: [Item]
    {
        self.items.filter(self.displayMode.filter)
    }

    public init() {}
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .init { action, state, _ in
        switch action {
        case let .updateNewText(text):
            state.newText = text

        case .createTodo:
            guard !state.newText.isEmpty else { return .empty }
            state.items.append(Item(id: state.nextItemID, text: state.newText))
            state.newText = ""
            state.nextItemID += 1

        case let .updateText(id, text):
            guard let index = state.items.firstIndex(where: { $0.id == id }) else { return .empty }
            state.items[index].text = text

        case let .toggleCompleted(id):
            guard let index = state.items.firstIndex(where: { $0.id == id }) else { return .empty }
            state.items[index].isCompleted.toggle()

        case let .updateDisplayMode(displayMode):
            state.displayMode = displayMode

        case .toggleEdit:
            state.isEditing.toggle()

        case let .delete(indexes):
            let visibleIDs = indexes.map { state.visibleItems[$0].id }
            let itemIndexes = state.items.enumerated()
                .filter { visibleIDs.contains($0.element.id) }
                .map { $0.offset }
            state.items.remove(atOffsets: IndexSet(itemIndexes))
        }

        return .empty
    }
}

// MARK: - Data Models

public struct Item: Identifiable, Equatable, Sendable
{
    public var id: ID
    public var text: String = ""
    public var isCompleted: Bool = false

    public typealias ID = Int
}

public enum DisplayMode: Int, CaseIterable, Equatable, Sendable
{
    case all
    case active
    case completed

    /// Workaround getter/setter to allow `Store.Proxy` to access to `rawValue` as `Int`
    /// since `SwiftUI.Picker` seems to only work for `Int`.
    public var intValue: Int
    {
        get { self.rawValue }
        set { assertionFailure("Should be replaced by `Store.Proxy.stateBinding`") }
    }

    fileprivate var filter: (Item) -> Bool
    {
        switch self {
        case .all:          return { _ in true }
        case .active:       return { !$0.isCompleted }
        case .completed:    return { $0.isCompleted }
        }
    }
}

// MARK: - @unchecked Sendable

// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.
extension IndexSet: @unchecked Sendable {}
