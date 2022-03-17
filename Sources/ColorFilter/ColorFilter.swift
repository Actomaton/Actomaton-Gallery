import Foundation
import CoreGraphics
import Actomaton

// MARK: - Action

/// - Note:
///   This example uses `directStateBinding`, so `Action` will not run,
///   and will not be part of `TimeTravel`-able action.
public enum Action: Sendable {}

// MARK: - State

public struct State: Equatable, Sendable
{
    /// - Note: 0 (0 degree) to 1 (360 degrees).
    public var hue: CGFloat = 1

    /// - Note: 0 (gray) to 100% (original).
    public var saturation: CGFloat = 1

    /// - Note: A value between 0 (no effect) and 1 (full white brightening), -1 (full black)
    public var brightness: CGFloat = 0

    /// - Note: The intensity of color contrast to apply. negative values invert colors in addition to applying contrast.
    public var contrast: CGFloat = 1

    public init() {}
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Reducer

/// - Note: This example uses `directStateBinding`, so `Reducer` will not run.
public var reducer: Reducer<Action, State, Environment>
{
    .empty
}
