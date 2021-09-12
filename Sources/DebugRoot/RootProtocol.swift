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

public protocol RootViewProtocol
{
    associatedtype Action
    associatedtype State: RootStateProtocol & Equatable

    init(store: Store<Action, State>.Proxy)
}
