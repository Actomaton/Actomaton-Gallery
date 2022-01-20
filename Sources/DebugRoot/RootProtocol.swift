import ActomatonStore

// MARK: - RootStateProtocol

/// Protocol for DebugRoot to access to Root's debug flags.
/// - Note: This protocol allows DebugRoot not to hold duplicated flags on their side.
public protocol RootStateProtocol
{
    var usesTimeTravel: Bool { get }
}

extension RootStateProtocol
{
    var usesTimeTravel: Bool { false }
}

// MARK: - RootViewProtocol

@MainActor
public protocol RootViewProtocol
{
    associatedtype Action: Sendable
    associatedtype State: RootStateProtocol & Equatable & Sendable

    init(store: Store<Action, State>.Proxy)
}
