import CommonInterfaces

// MARK: - Action

/// - Note:
///   The Apple `ColorFilterView` uses direct-state-binding via `Store.Proxy.$state`, so it does not
///   send these actions. They exist for action-driven consumers (e.g. the WASM `MealyDriver` page and
///   `TimeTravel`), letting the same reducer drive the state without two-way binding.
public enum Action: Sendable
{
    case setHue(Double)
    case setSaturation(Double)
    case setBrightness(Double)
    case setContrast(Double)
    case reset
}

// MARK: - State

public struct State: Equatable, Sendable
{
    /// - Note: 0 (0 degree) to 1 (360 degrees).
    public var hue: Double = 1

    /// - Note: 0 (gray) to 100% (original).
    public var saturation: Double = 1

    /// - Note: A value between 0 (no effect) and 1 (full white brightening), -1 (full black)
    public var brightness: Double = 0

    /// - Note: The intensity of color contrast to apply. negative values invert colors in addition to applying contrast.
    public var contrast: Double = 1

    public init() {}
}

// MARK: - Environment

public typealias Environment = ()

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .init { action, state, _ in
        switch action {
        case let .setHue(value):
            state.hue = value
        case let .setSaturation(value):
            state.saturation = value
        case let .setBrightness(value):
            state.brightness = value
        case let .setContrast(value):
            state.contrast = value
        case .reset:
            state = State()
        }
        return .empty
    }
}
