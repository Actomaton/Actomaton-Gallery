import ActomatonStore

// MARK: - RootActionProtocol

/// Protocol for DebugRoot to detect debugToggle action from Root.
public protocol RootActionProtocol
{
    var debugToggle: Bool? { get }
}

extension RootActionProtocol
{
    var debugToggle: Bool? { nil }
}

// MARK: - RootViewProtocol

public protocol RootViewProtocol
{
    associatedtype Action: RootActionProtocol
    associatedtype State: Equatable

    init(store: Store<Action, State>.Proxy)
}
