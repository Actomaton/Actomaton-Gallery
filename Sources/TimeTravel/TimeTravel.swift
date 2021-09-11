import Foundation
import ActomatonStore

// MARK: - Action

public enum Action<InnerAction>
{
    case timeTravelStepper(diff: Int)
    case timeTravelSlider(sliderValue: Double)
    case _didTimeTravel
    case resetHistories

    case inner(InnerAction)
}

// MARK: - State

public struct State<InnerState: Equatable>: Equatable
{
    public var inner: InnerState

    fileprivate var histories: [InnerState] = []

    public fileprivate(set) var timeTravellingIndex: Int = 0

    /// Workaround flag for avoiding SwiftUI iOS navigation binding issue
    /// where `isActive = false` binding is called during time-travelling.
    fileprivate var isTimeTravelling: Bool = false

    public init(inner: InnerState)
    {
        self.inner = inner
        self.histories.append(inner)
    }

    public var timeTravellingSliderRange: ClosedRange<Double>
    {
        let count = self.histories.count

        // NOTE: `0 ... 0` is not allowed in `Slider`.
        return count > 1
            ? 0 ... Double(count - 1)
            : -1 ... 0
    }

    public var timeTravellingSliderValue: Double
    {
        get { Double(timeTravellingIndex) }
        set { assertionFailure("Should be replaced by `Store.Proxy.stateBinding`") }
    }

    public var canTimeTravel: Bool
    {
        self.histories.count > 1
    }

    mutating func appendHistory(_ state: InnerState)
    {
        // Ignore same state.
        guard self.histories.last != state else { return }

        self.histories.removeSubrange((self.timeTravellingIndex + 1)...)
        self.histories.append(state)
        self.timeTravellingIndex += 1
    }
}

// MARK: - Environment

public struct Environment<InnerEnvironment>
{
    let inner: InnerEnvironment

    public init(inner: InnerEnvironment)
    {
        self.inner = inner
    }
}

// MARK: - Reducer

/// - Important: This reducer needs to be called after `InnerState` has changed.
public func reducer<InnerAction, InnerState, InnerEnvironment>()
    -> Reducer<Action<InnerAction>, State<InnerState>, Environment<InnerEnvironment>>
{
    func tryTimeTravel(state: inout State<InnerState>, newIndex: Int, environment: Environment<InnerEnvironment>)
        -> Effect<Action<InnerAction>>
    {
        guard !state.histories.isEmpty && newIndex >= 0 && newIndex < state.histories.count else {
            return .empty
        }

        // Load history.
        state.inner = state.histories[newIndex]

        // NOTE: Modify other states after history is loaded.
        state.timeTravellingIndex = newIndex
        state.isTimeTravelling = true

        // Workaround effect for changing to `isTimeTravelling = false` after delay.
        return Effect {
            await Task.sleep(UInt64(100_000_000)) // 0.1 sec
            return Action._didTimeTravel
        }
    }

    return .init { action, state, environment in
        switch action {
        case let .timeTravelSlider(sliderValue):
            guard sliderValue >= 0 else { return .empty }

            let newIndex = Int(sliderValue)
            return tryTimeTravel(state: &state, newIndex: newIndex, environment: environment)

        case let .timeTravelStepper(diff):
            guard diff != 0 else { return .empty }

            let newIndex = state.timeTravellingIndex + diff
            return tryTimeTravel(state: &state, newIndex: newIndex, environment: environment)

        case ._didTimeTravel:
            state.isTimeTravelling = false

        case .resetHistories:
            state.histories.removeAll()
            state.histories.append(state.inner)
            state.timeTravellingIndex = 0

        default:
            // IMPORTANT:
            // Guard `appendHistory` while `isTimeTravelling` to avoid SwiftUI iOS navigation binding issue
            // where `isActive = false` binding is called during time-travelling.
            guard !state.isTimeTravelling else {
                return .empty
            }

            state.appendHistory(state.inner)
        }

        return .empty
    }
}
